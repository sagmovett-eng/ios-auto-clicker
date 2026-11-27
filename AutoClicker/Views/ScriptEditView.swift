import SwiftUI

/// 脚本编辑（FR2）：名称 / 参数 / 点位列表 / 校验 / 保存
struct ScriptEditView: View {
    @EnvironmentObject var store: ScriptStore
    @Environment(\.dismiss) private var dismiss

    @State private var script: Script
    @State private var name = ""
    @State private var intervalText = "500"
    @State private var holdText = "150"
    @State private var countText = "100"
    @State private var loopGapText = "0"
    @State private var isInfinite = false
    @State private var showErrors = false
    @State private var validationErrors: [String] = []

    init(script: Script) {
        _script = State(initialValue: script)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Up to 30 characters", text: $name)
                }

                Section("Points (\(script.activePoints.count)/20)") {
                    ForEach(script.activePoints) { point in
                        HStack {
                            Text(point.type.displayName)
                            Spacer()
                            Text(String(format: "(%.1f%%, %.1f%%)", point.xPercent, point.yPercent))
                                .foregroundStyle(.secondary)
                            if let dur = point.durationMs {
                                Text("\(Int(dur))ms").foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: removePoints)

                    NavigationLink("Add point (go to Capture tab)") {
                        CaptureRedirectNote()
                    }
                }

                Section("Run parameters") {
                    HStack {
                        Text("Tap interval (ms)")
                        TextField("100-60000", text: $intervalText).keyboardType(.numberPad)
                    }
                    HStack {
                        Text("Hold time (ms)")
                        TextField("50-10000", text: $holdText).keyboardType(.numberPad)
                    }
                    HStack {
                        Text("Repeat count")
                        TextField("1-99999", text: $countText)
                            .keyboardType(.numberPad)
                            .disabled(isInfinite)
                    }
                    HStack {
                        Text("Loop gap (s)")
                        TextField("0-600", text: $loopGapText).keyboardType(.numberPad)
                    }
                    Toggle("Infinite loop", isOn: $isInfinite)
                }

                if showErrors && !validationErrors.isEmpty {
                    Section {
                        ForEach(validationErrors, id: \.self) { err in
                            Label(err, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section {
                    Button("Save") { save() }
                        .frame(maxWidth: .infinity)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Edit Script")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { hydrate() }
        }
    }

    private func hydrate() {
        name = script.name
        intervalText = String(script.params.intervalMs)
        holdText = String(script.params.holdMs)
        countText = String(script.params.repeatCount)
        loopGapText = String(script.params.loopGapSec)
        isInfinite = script.params.isInfinite
    }

    private func removePoints(at offsets: IndexSet) {
        var pts = script.activePoints
        pts.remove(atOffsets: offsets)
        script.activePoints = pts
    }

    private func save() {
        var s = script
        s.name = String(name.prefix(30))
        s.params.intervalMs = ParamValidator.alignInterval(Int(intervalText) ?? 500)
        s.params.holdMs = ParamValidator.alignHold(Int(holdText) ?? 150)
        s.params.repeatCount = ParamValidator.clampCount(Int(countText) ?? 100)
        s.params.loopGapSec = ParamValidator.clampLoopGap(Int(loopGapText) ?? 0)
        s.params.isInfinite = isInfinite
        s.updatedAt = Date()

        let errors = ParamValidator.validate(s)
        if errors.isEmpty {
            store.updateScript(s)
            dismiss()
        } else {
            validationErrors = errors
            showErrors = true
        }
    }
}

/// 打点跳转引导（避免在编辑页嵌套打点页）
struct CaptureRedirectNote: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Capture points on the Capture tab:", systemImage: "hand.tap")
            Text("Overlay: tap the screen to record. Manual: enter percentages. Screenshot: pick an image and tap it.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Saving creates a new script; you can keep editing its parameters and points here.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
