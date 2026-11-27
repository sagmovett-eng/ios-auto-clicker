import SwiftUI

/// 首次启动安全须知（FR0.1）：10s 倒计时后确认
struct SafetyNoticeView: View {
    @EnvironmentObject var store: ScriptStore
    @State private var countdown = 10
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Notice")
                .font(.title2.bold())

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    bullet("This tool uses the native iOS Switch Control feature to perform system-level auto taps. No injection or jailbreak.")
                    bullet("For your own device, your own use, and lawful purposes only (e.g. test assistance, accessibility practice).")
                    bullet("Do not use for game boosting, bulk purchasing or any use that breaks platform rules or the law.")
                    bullet("Continuous tapping may trigger system safety prompts. Check the target screen before running.")
                    bullet("Background limits: the script stops and notifies you if the app stays in the background for over 30 seconds.")
                }
            }

            Button(action: {
                store.acceptSafety()
            }) {
                Text(countdown > 0 ? "I have read and agree (\(countdown)s)" : "I have read and agree")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(countdown > 0 ? Color.gray.opacity(0.4) : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(countdown > 0)
        }
        .padding()
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text).font(.subheadline)
        }
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if countdown > 1 {
                countdown -= 1
            } else {
                countdown = 0
                t.invalidate()
            }
        }
    }
}
