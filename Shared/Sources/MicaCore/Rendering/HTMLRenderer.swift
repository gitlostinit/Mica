import Foundation
import Markdown

/// Converts preprocessed Obsidian markdown to HTML.
public final class HTMLRenderer {

    public init() {}

    public func render(_ document: Document) -> String {
        renderChildren(of: document)
    }

    // MARK: - Node dispatch

    private func renderNode(_ node: any Markup) -> String {
        switch node {
        case let n as Document:         return renderChildren(of: n)
        case let n as Heading:          return renderHeading(n)
        case let n as Paragraph:        return "<p>\(renderChildren(of: n))</p>\n"
        case let n as Text:             return esc(n.string)
        case let n as Strong:           return "<strong>\(renderChildren(of: n))</strong>"
        case let n as Emphasis:         return "<em>\(renderChildren(of: n))</em>"
        case let n as Strikethrough:    return "<del>\(renderChildren(of: n))</del>"
        case let n as InlineCode:       return "<code>\(esc(n.code))</code>"
        case let n as CodeBlock:        return renderCodeBlock(n)
        case let n as BlockQuote:       return renderBlockQuote(n)
        case let n as Link:             return renderLink(n)
        case let n as Image:            return renderImage(n)
        case let n as UnorderedList:    return "<ul>\n\(renderChildren(of: n))</ul>\n"
        case let n as OrderedList:      return "<ol>\n\(renderChildren(of: n))</ol>\n"
        case let n as ListItem:         return "<li>\(renderChildren(of: n))</li>\n"
        case let n as HTMLBlock:        return n.rawHTML
        case let n as InlineHTML:       return n.rawHTML
        case is ThematicBreak:          return "<hr />\n"
        case is SoftBreak:              return " "
        case is LineBreak:              return "<br />"
        default:                        return renderChildren(of: node)
        }
    }

    private func renderChildren(of node: any Markup) -> String {
        var out = ""
        for child in node.children { out += renderNode(child) }
        return out
    }

    // MARK: - Specific renderers

    private func renderHeading(_ h: Heading) -> String {
        let l = h.level
        let content = renderChildren(of: h)
        return "<h\(l)>\(content)</h\(l)>\n"
    }

    private func renderCodeBlock(_ block: CodeBlock) -> String {
        let lang = block.language ?? ""
        let cls = lang.isEmpty ? "" : " class=\"language-\(lang)\""
        return "<pre><code\(cls)>\(esc(block.code))</code></pre>\n"
    }

    private func renderBlockQuote(_ quote: BlockQuote) -> String {
        // Extract raw text from first paragraph to detect callout syntax
        if let firstPara = quote.children.first(where: { $0 is Paragraph }) as? Paragraph {
            let rawText = firstPara.children
                .compactMap { ($0 as? Text)?.string }
                .joined()
            let lines = rawText.components(separatedBy: "\n")
            let syntheticLines = ["> \(lines.first ?? "")"] + lines.dropFirst().map { "> \($0)" }
            if let callout = CalloutParser.parse(blockquoteLines: syntheticLines) {
                return renderCallout(callout)
            }
        }
        return "<blockquote>\(renderChildren(of: quote))</blockquote>\n"
    }

    private func renderLink(_ link: Link) -> String {
        let dest = link.destination ?? ""
        let label = renderChildren(of: link)
        if dest.hasPrefix("mica://note/") {
            let encoded = dest.dropFirst("mica://note/".count)
            let name = encoded.removingPercentEncoding ?? String(encoded)
            return "<a class=\"wikilink\" href=\"\(dest)\">\(esc(name))</a>"
        }
        return "<a href=\"\(esc(dest))\">\(label)</a>"
    }

    private func renderImage(_ image: Image) -> String {
        "<img src=\"\(esc(image.source ?? ""))\" alt=\"\(esc(image.title ?? ""))\" />"
    }

    private func renderCallout(_ callout: Callout) -> String {
        let title = callout.title ?? callout.type.rawValue.capitalized
        return """
        <div class="callout" style="border-left-color:\(callout.type.colorHex)" data-type="\(callout.type.rawValue)">
          <div class="callout-title" style="color:\(callout.type.colorHex)">
            <span class="callout-icon" data-sf="\(callout.type.sfSymbol)"></span>
            <span>\(esc(title))</span>
          </div>
          <div class="callout-body">\(callout.body)</div>
        </div>\n
        """
    }

    // MARK: - Helpers

    private func esc(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
