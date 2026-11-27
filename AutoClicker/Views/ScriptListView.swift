import SwiftUI

/// 脚本列表（FR2 入口 / FR1.1）
struct ScriptListView: View {
    @EnvironmentObject var store: ScriptStore
    @State private var editingScript: Script?
    @State private var showDeleteConfirm: Script?

    var body: some View {
        NavigationStack {
            List {
                if store.scripts.isEmpty {
                    ContentUnavailablePlaceholder()
                } else {
                    ForEach(store.scripts) { script in
                        ScriptRow(script: script) { action in
                            switch action {
                            case .edit: editingScript = script
                            case .delete: showDeleteConfirm = script
                            }
                        }
                    }
                }
            }
            .navigationTitle("Auto Clicker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        let s = store.createScript()
                        editingScript = s
                    } label: {
                        Label("New", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $editingScript) { script in
                ScriptEditView(script: script)
            }
            .confirmationDialog("Delete script?", isPresented: Binding(
                get: { showDeleteConfirm != nil },
                set: { if !$0 { showDeleteConfirm = nil } }
            ), titleVisibility: .visible) {
                if let s = showDeleteConfirm {
                    Button("Delete", role: .destructive) {
                        store.deleteScript(s)
                        showDeleteConfirm = nil
                    }
                    Button("Cancel", role: .cancel) { showDeleteConfirm = nil }
                }
            }
        }
    }
}

enum ScriptRowAction {
    case edit, delete
}

struct ScriptRow: View {
    let script: Script
    let onAction: (ScriptRowAction) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(script.name).font(.headline)
                Text("\(script.activePoints.count) points · interval \(script.params.intervalMs)ms · \(script.params.isInfinite ? "infinite" : "\(script.params.repeatCount) times")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { onAction(.edit) } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
            Button { onAction(.delete) } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

struct ContentUnavailablePlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap").font(.largeTitle).foregroundStyle(.secondary)
            Text("No scripts yet").font(.headline)
            Text("Tap + at the top right, then record your first point on the Capture tab").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
