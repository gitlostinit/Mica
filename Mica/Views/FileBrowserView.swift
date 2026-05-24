import SwiftUI
import MicaCore

struct FileBrowserView: View {
    @Environment(AppState.self) var state
    @State private var sortOrder = SortOrder.name

    enum SortOrder: String, CaseIterable {
        case name = "Name"
        case modified = "Modified"
    }

    var sortedNotes: [NoteFile] {
        switch sortOrder {
        case .name:
            state.index.notes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .modified:
            state.index.notes.sorted { ($0.modifiedAt ?? .distantPast) > ($1.modifiedAt ?? .distantPast) }
        }
    }

    // Group flat list by top-level folder
    var groups: [(folder: String, notes: [NoteFile])] {
        let grouped = Dictionary(grouping: sortedNotes) { note -> String in
            let parts = note.relativePath.components(separatedBy: "/")
            return parts.count > 1 ? parts[0] : ""
        }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (folder: $0.key, notes: $0.value) }
    }

    var body: some View {
        List(selection: Binding(
            get: { state.selectedNote },
            set: { state.selectedNote = $0 }
        )) {
            ForEach(groups, id: \.folder) { group in
                if group.folder.isEmpty {
                    ForEach(group.notes) { note in
                        NoteRow(note: note)
                    }
                } else {
                    Section(group.folder) {
                        ForEach(group.notes) { note in
                            NoteRow(note: note)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Picker("Sort", selection: $sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
    }
}

private struct NoteRow: View {
    let note: NoteFile

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(note.name)
                .font(.body)
            if let date = note.modifiedAt {
                Text(date, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .tag(note)
    }
}
