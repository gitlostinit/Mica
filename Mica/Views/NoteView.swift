import SwiftUI
import WebKit
import MicaCore
import Markdown

struct NoteView: View {
    let note: NoteFile
    @Environment(AppState.self) var state
    @State private var showBacklinks = false

    var backlinks: [NoteFile] {
        state.index.backlinks[note.url] ?? []
    }

    var body: some View {
        NoteWebView(note: note) { target in
            if let resolved = state.index.resolve(wikilink: target, from: note.url) {
                state.selectedNote = resolved
            }
        }
        .navigationTitle(note.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !backlinks.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showBacklinks = true
                    } label: {
                        Image(systemName: "arrow.turn.up.left")
                        Text("\(backlinks.count)")
                    }
                }
            }
        }
        .sheet(isPresented: $showBacklinks) {
            BacklinkPanel(note: note, backlinks: backlinks)
                .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - WebView

struct NoteWebView: UIViewRepresentable {
    let note: NoteFile
    let onWikilink: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onWikilink: onWikilink) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .scrollableAxes
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.currentNote = note
        let html = buildHTML()
        // baseURL gives WebKit implicit access to sibling files (images) in same folder
        webView.loadHTMLString(html, baseURL: note.url.deletingLastPathComponent())
    }

    private func buildHTML() -> String {
        guard let raw = try? String(contentsOf: note.url, encoding: .utf8) else {
            return HTMLTemplate.wrap("<p>Could not load note.</p>", title: note.name)
        }
        let (fm, body) = FrontmatterParser.parse(raw)
        let preprocessed = WikilinkPreprocessor.process(body)
        let doc = Document(parsing: preprocessed)
        let renderer = HTMLRenderer()
        let html = renderer.render(doc)
        let title = fm.title ?? note.name
        return HTMLTemplate.wrap(frontmatterHTML(fm) + html, title: title)
    }

    private func frontmatterHTML(_ fm: Frontmatter) -> String {
        guard !fm.tags.isEmpty && !fm.properties.isEmpty else { return "" }
        var html = "<div class=\"frontmatter\">"
        if !fm.tags.isEmpty {
            html += "<div class=\"fm-tags\">"
            html += fm.tags.map { "<span class=\"tag\">#\($0)</span>" }.joined(separator: " ")
            html += "</div>"
        }
        html += "</div>"
        return html
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onWikilink: (String) -> Void
        var currentNote: NoteFile?

        init(onWikilink: @escaping (String) -> Void) {
            self.onWikilink = onWikilink
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = action.request.url else { decisionHandler(.allow); return }
            if url.scheme == "mica", url.host == "note" {
                let target = String(url.path.dropFirst()).removingPercentEncoding ?? ""
                onWikilink(target)
                decisionHandler(.cancel)
            } else if action.navigationType == .linkActivated {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
}
