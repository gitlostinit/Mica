import SwiftUI
import MicaCore

struct BacklinkPanel: View {
    @Environment(AppState.self) var state
    @Environment(\.dismiss) var dismiss
    let note: NoteFile
    let backlinks: [NoteFile]

    var body: some View {
        NavigationStack {
            List(backlinks) { link in
                Button {
                    state.selectedNote = link
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(link.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(link.relativePath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Backlinks (\(backlinks.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
