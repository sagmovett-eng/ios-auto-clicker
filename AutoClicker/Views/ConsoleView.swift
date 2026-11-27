import SwiftUI

/// 运行控制台（FR3/FR4）：选择脚本、启动/暂停/停止、节拍进度、三击引导
struct ConsoleView: View {
    @EnvironmentObject var store: ScriptStore
    @State private var selectedScriptId: UUID?

    private var selectedScript: Script? {
        store.scripts.first { $0.id == selectedScriptId }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Select script") {
                    if store.scripts.isEmpty {
                        Text("No scripts yet, create one on the Capture tab").foregroundStyle(.secondary)
                    } else {
                        Picker("Script", selection: $selectedScriptId) {
                            ForEach(store.scripts) { s in
                                Text(s.name).tag(Optional(s.id))
                            }
                        }
                    }
                }

                if let script = selectedScript {
                    Section("Run status") {
                        HStack {
                            Text("Status")
                            Spacer()
                            Text(store.runState.displayName)
                                .foregroundStyle(store.runState == .running ? .green : .secondary)
                        }
                        HStack {
                            Text("Rounds done")
                            Spacer()
                            Text("\(store.currentRound)/\(script.params.isInfinite ? "∞" : "\(script.params.repeatCount)")")
                        }
                        HStack {
                            Text("Elapsed time")
                            Spacer()
                            Text(timeString(store.elapsedSeconds))
                        }
                        if let s = store.activeScript {
                            HStack {
                                Text("Current script")
                                Spacer()
                                Text(s.name).foregroundStyle(.secondary)
                            }
                        }
                        if !UIAccessibility.isSwitchControlRunning {
                            Label("Switch Control is off: real taps will not run. Set it up on the Guide tab first", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }

                    Section("Controls") {
                        HStack(spacing: 12) {
                            if store.runState == .running || store.runState == .paused {
                                Button(store.runState == .paused ? "Resume" : "Pause") {
                                    if store.runState == .paused { store.resume() } else { store.pause() }
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Stop", role: .destructive) {
                                    store.stop()
                                }
                                .buttonStyle(.bordered)
                            } else {
                                Button("Start") {
                                    store.start(script: script)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(!ParamValidator.validate(script).isEmpty)
                            }
                        }
                    }
                }

                Section("How it works") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This tool does not inject into the system. Real taps are performed by a Switch Control custom gesture.")
                        Text("1. Finish the 5-step setup on the Guide tab.")
                        Text("2. Return to the target app and triple-click the side button to enable Switch Control.")
                        Text("3. Switch back here and tap Start; the console counts rounds by script timing.")
                        Text("4. Triple-click the side button again to stop, or tap Stop here.")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Run Console")
            .onAppear {
                if selectedScriptId == nil { selectedScriptId = store.scripts.first?.id }
            }
            .onDisappear {
                if store.runState == .paused {
                    store.stop()
                }
            }
        }
    }

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
