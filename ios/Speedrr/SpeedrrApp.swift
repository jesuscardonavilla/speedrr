import SwiftUI

@main
struct SpeedrrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var updater = Updater()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.965, green: 0.953, blue: 0.925).ignoresSafeArea()
            WebView(updater: updater)
            if let message = updater.message {
                Text(message)
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.black.opacity(0.85)))
                    .foregroundColor(.white)
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: updater.message)
        .task { await updater.check(force: true) }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task { await updater.check(force: false) }
            }
        }
    }
}
