import Foundation
import CryptoKit

/// File locations for the web app. The saved copy (downloaded from GitHub)
/// wins over the copy bundled inside the app.
enum AppFiles {
    static var supportDir: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("speedrr", isDirectory: true)
    }
    static var cachedURL: URL { supportDir.appendingPathComponent("index.html") }
    static var bundledURL: URL? { Bundle.main.url(forResource: "index", withExtension: "html") }
    static var currentURL: URL? {
        if FileManager.default.fileExists(atPath: cachedURL.path) { return cachedURL }
        return bundledURL
    }
}

/// Downloads the latest web/index.html from GitHub and tells the web view to reload.
@MainActor
final class Updater: ObservableObject {
    static let remote = URL(string: "https://raw.githubusercontent.com/jesuscardonavilla/speedrr/main/web/index.html")!

    @Published var message: String? = nil
    @Published var reloadToken = 0
    private var lastCheck = Date.distantPast

    func check(force: Bool) async {
        if !force && Date().timeIntervalSince(lastCheck) < 60 { return }
        lastCheck = Date()

        var request = URLRequest(url: Self.remote, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200, looksLikeApp(data) else {
                if force { flash("Could not check for updates") }
                return
            }
            let newHash = sha(data)
            var oldHash: String? = nil
            if let url = AppFiles.currentURL, let old = try? Data(contentsOf: url) { oldHash = sha(old) }
            if newHash == oldHash {
                if force { flash("You're up to date") }
                return
            }
            try FileManager.default.createDirectory(at: AppFiles.supportDir, withIntermediateDirectories: true)
            try data.write(to: AppFiles.cachedURL, options: .atomic)
            reloadToken += 1
            flash("Updated to the latest version")
        } catch {
            if force { flash("Offline. Using the saved version.") }
        }
    }

    private func looksLikeApp(_ data: Data) -> Bool {
        guard data.count > 5000 else { return false }
        let head = String(decoding: data.prefix(2000), as: UTF8.self).lowercased()
        return head.contains("<!doctype html")
    }

    private func sha(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func flash(_ text: String) {
        message = text
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if message == text { message = nil }
        }
    }
}
