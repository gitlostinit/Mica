import SwiftUI
import MicaCore

struct SearchResultsList: View {
    @Environment(AppState.self) var state
    let results: [SearchResult]
    let isSearching: Bool

    var body: some View {
        Group {
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if results.isEmpty {
                ContentUnavailableView.search
            } else {
                List(results) { result in
                    Button {
                        if let note = state.index.notes.first(where: { $0.url == result.url }) {
                            state.selectedNote = note
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(result.relativePath)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            if !result.snippet.isEmpty {
                                Text(result.snippet)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
