import SwiftUI
import MicaCore

struct MainView: View {
    @Environment(AppState.self) var state
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false

    var body: some View {
        NavigationSplitView {
            SidebarView(searchText: $searchText, searchResults: $searchResults, isSearching: $isSearching)
        } detail: {
            if let note = state.selectedNote {
                NoteView(note: note)
            } else {
                ContentUnavailableView(
                    "No Note Selected",
                    systemImage: "doc.text",
                    description: Text("Pick a note from the sidebar.")
                )
            }
        }
        .onChange(of: searchText) { _, q in
            guard !q.isEmpty else { searchResults = []; isSearching = false; return }
            isSearching = true
            Task {
                searchResults = (try? await state.search.search(query: q)) ?? []
                isSearching = false
            }
        }
    }
}

private struct SidebarView: View {
    @Environment(AppState.self) var state
    @Binding var searchText: String
    @Binding var searchResults: [SearchResult]
    @Binding var isSearching: Bool

    var body: some View {
        Group {
            if !searchText.isEmpty {
                SearchResultsList(results: searchResults, isSearching: isSearching)
            } else {
                FileBrowserView()
            }
        }
        .searchable(text: $searchText, prompt: "Search vault")
        .navigationTitle(state.index.notes.isEmpty ? "Mica" : "Vault")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    state.access.close()
                } label: {
                    Image(systemName: "eject")
                }
            }
        }
    }
}
