import SwiftUI

/// 五步配置向导（FR0.2）+ 帮助信息
struct WizardView: View {
    @EnvironmentObject var store: ScriptStore
    @State private var progress: GuideProgress?
    @State private var selectedScriptId: UUID?

    private var selectedScript: Script? {
        store.scripts.first { $0.id == selectedScriptId }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Select target script") {
                    if store.scripts.isEmpty {
                        Text("No scripts yet, create one first").foregroundStyle(.secondary)
                    } else {
                        Picker("Script", selection: $selectedScriptId) {
                            ForEach(store.scripts) { s in
                                Text(s.name).tag(Optional(s.id))
                            }
                        }
                        .onChange(of: selectedScriptId) { newId in
                            if let id = newId {
                                progress = store.scripts.first { $0.id == id }.flatMap { s in
                                    GuideProgress(scriptId: s.id)
                                }
                            }
                        }
                    }
                }

                if let p = progress {
                    Section("5-step setup guide (\(stepsDone(p))/5)") {
                        stepRow(index: 0, text: "Confirm points and parameters", done: p.steps[0])
                        stepRow(index: 1, text: "Open Settings > Accessibility > Switch Control", done: p.steps[1])
                        stepRow(index: 2, text: "In Switch Control, record a custom gesture", done: p.steps[2])
                        stepRow(index: 3, text: "Set scanning mode and loop count (loop on recommended)", done: p.steps[3])
                        stepRow(index: 4, text: "Triple-click the side button to enable, switch to the target screen and run", done: p.steps[4])

                        Button(stepsDone(p) == 5 ? "Restart" : "Mark all done") {
                            toggleStep()
                        }
                    }
                }

                Section("FAQ") {
                    DisclosureGroup("Why can the app not tap by itself?") {
                        Text("The iOS sandbox and App Store review forbid third-party apps from simulating system input, so there is no global accessibility tap like on Android. This tool uses the native Switch Control feature instead: no jailbreak needed.")
                            .font(.caption)
                    }
                    DisclosureGroup("Which iOS versions are supported?") {
                        Text("Installable on iOS 16+. Native accessibility path: iOS 16+. Proxy mode: iOS 17+ (signed IPA required). Shortcuts support: iOS 16+.")
                            .font(.caption)
                    }
                    DisclosureGroup("What signing options exist?") {
                        Text("Free personal signing must be renewed every 7 days. Developer signing costs $99/year and lasts one year. Proxy mode is distributed outside the App Store.")
                            .font(.caption)
                    }
                    DisclosureGroup("Stopped halfway?") {
                        Text("Background running is limited: the script stops and notifies you after 30 seconds in the background. Keep the app in the foreground or follow the system prompt.")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Setup Guide")
            .onAppear {
                if selectedScriptId == nil { selectedScriptId = store.scripts.first?.id }
                refreshProgress()
            }
            .onChange(of: store.scripts) { _ in refreshProgress() }
        }
    }

    private func refreshProgress() {
        guard let id = selectedScriptId else { return }
        progress = GuideProgress(scriptId: id)
    }

    private func stepsDone(_ p: GuideProgress) -> Int {
        p.steps.filter { $0 }.count
    }

    private func stepRow(index: Int, text: String, done: Bool) -> some View {
        HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : .secondary)
            Text(text)
                .strikethrough(done)
                .foregroundStyle(done ? .secondary : .primary)
        }
        .contentShape(Rectangle())
        .onTapGesture { toggleStep(index) }
    }

    private func toggleStep(_ index: Int? = nil) {
        guard var p = progress else { return }
        if let index {
            p.steps[index].toggle()
        } else if stepsDone(p) < 5 {
            p.steps = [true, true, true, true, true]
        } else {
            p.steps = [false, false, false, false, false]
        }
        p.updatedAt = Date()
        progress = p
    }
}
