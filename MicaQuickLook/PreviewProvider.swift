import QuickLookUI
import MicaCore
import Markdown

@objc(PreviewProvider)
class PreviewProvider: QLPreviewProvider, QLPreviewingController {

    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let url = request.fileURL
        let raw = try String(contentsOf: url, encoding: .utf8)
        let (fm, body) = FrontmatterParser.parse(raw)
        let preprocessed = WikilinkPreprocessor.process(body)
        let doc = Document(parsing: preprocessed)
        let renderer = HTMLRenderer()
        let html = renderer.render(doc)
        let title = fm.title ?? url.deletingPathExtension().lastPathComponent
        let fullHTML = HTMLTemplate.wrap(html, title: title)

        let reply = QLPreviewReply(
            dataOfContentType: .html,
            contentSize: CGSize(width: 800, height: 1200)
        ) { _ in
            Data(fullHTML.utf8)
        }
        return reply
    }
}
