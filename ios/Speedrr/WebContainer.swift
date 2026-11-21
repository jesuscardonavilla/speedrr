import SwiftUI
import WebKit

/// Serves the web app from the app's own "speedrr://app/" address.
/// A fixed address keeps localStorage (your plan, scores and streak) between launches and updates.
final class AppSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let requestURL = urlSchemeTask.request.url, let fileURL = AppFiles.currentURL else {
            urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let response = URLResponse(url: requestURL, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: "utf-8")
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
        } catch {
            urlSchemeTask.didFailWithError(error)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}

struct WebView: UIViewRepresentable {
    let updater: Updater

    func makeCoordinator() -> Coordinator { Coordinator(updater: updater) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(AppSchemeHandler(), forURLScheme: "speedrr")
        config.userContentController.add(context.coordinator, name: "speedrr")
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.965, green: 0.953, blue: 0.925, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor
        webView.scrollView.bounces = false
        webView.allowsLinkPreview = false
        context.coordinator.lastToken = updater.reloadToken
        webView.load(URLRequest(url: URL(string: "speedrr://app/index.html")!))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastToken != updater.reloadToken {
            context.coordinator.lastToken = updater.reloadToken
            webView.load(URLRequest(url: URL(string: "speedrr://app/index.html")!))
        }
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        let updater: Updater
        var lastToken = 0

        init(updater: Updater) { self.updater = updater }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            Task { @MainActor in
                await updater.check(force: true)
            }
        }
    }
}
