import SwiftUI

@main
struct AutoClickerApp: App {
    @StateObject private var store = ScriptStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var store: ScriptStore

    var body: some View {
        Group {
            if !store.safetyAck.accepted {
                SafetyNoticeView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            store.bootstrap()
        }
    }
}

struct MainTabView: View {
    @State private var selected: Tab = .scripts

    enum Tab: Hashable {
        case scripts, capture, console, help
    }

    var body: some View {
        TabView(selection: $selected) {
            ScriptListView()
                .tabItem { Label("Scripts", systemImage: "list.bullet.rectangle") }
                .tag(Tab.scripts)

            CaptureView()
                .tabItem { Label("Capture", systemImage: "hand.tap") }
                .tag(Tab.capture)

            ConsoleView()
                .tabItem { Label("Run", systemImage: "play.circle") }
                .tag(Tab.console)

            WizardView()
                .tabItem { Label("Guide", systemImage: "questionmark.circle") }
                .tag(Tab.help)
        }
    }
}
