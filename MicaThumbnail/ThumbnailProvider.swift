import QuickLookThumbnailing
import AppKit
import MicaCore

@objc(ThumbnailProvider)
class ThumbnailProvider: QLThumbnailProvider {

    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        guard let raw = try? String(contentsOf: request.fileURL, encoding: .utf8) else {
            handler(nil, nil)
            return
        }

        let (_, body) = FrontmatterParser.parse(raw)
        let preview = String(body.prefix(600))
        let size = request.maximumSize

        let reply = QLThumbnailReply(contextSize: size) { ctx -> Bool in
            NSGraphicsContext.saveGraphicsState()
            defer { NSGraphicsContext.restoreGraphicsState() }

            // Background
            NSColor.textBackgroundColor.setFill()
            NSBezierPath(rect: CGRect(origin: .zero, size: size)).fill()

            // Purple top bar
            NSColor.purple.withAlphaComponent(0.8).setFill()
            NSBezierPath(rect: CGRect(x: 0, y: size.height - 8, width: size.width, height: 8)).fill()

            // Filename
            let name = request.fileURL.deletingPathExtension().lastPathComponent
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: size.width * 0.08),
                .foregroundColor: NSColor.labelColor
            ]
            NSAttributedString(string: name, attributes: titleAttr)
                .draw(in: CGRect(x: 8, y: size.height - 28, width: size.width - 16, height: 20))

            // Body preview
            let bodyAttr: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: size.width * 0.055),
                .foregroundColor: NSColor.secondaryLabelColor
            ]
            NSAttributedString(string: preview, attributes: bodyAttr)
                .draw(in: CGRect(x: 8, y: 8, width: size.width - 16, height: size.height - 40))

            return true
        }

        handler(reply, nil)
    }
}
