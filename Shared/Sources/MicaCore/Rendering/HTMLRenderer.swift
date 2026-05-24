import Foundation
import Markdown

/// Converts preprocessed Obsidian markdown to HTML for the Quick Look extension.
public struct HTMLRenderer: MarkupVisitor {

    public typealias Result = String

    public init() {}

    public func render(_ document: Document) -> String {
        visit(document)
    }

    public func defaultVisit(_ markup: any Markup) -> String {
        markup.children.map { visit($0) }.joined()
    }

    public mutating func visitDocument(_ document: Document) -> String {
        document.children.map { visit($0) }.joined()
    }

    public mutating func visitHeading(_ heading: Heading) -> String {
        let level = heading.level
        let content = heading.children.map { visit($0) }.joined()
        return "<h\(level)>\(content)</h\(level)>\n"
    }

    public mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        let content = paragraph.children.map { visit($0) }.joined()
        return "<p>\(content)</p>\n"
    }

    public mutating func visitText(_ text: Text) -> String {
        escapeHTML(text.string)
    }

    public mutating func visitStrong(_ strong: Strong) -> String {
        "<strong>\(strong.children.map { visit($0) }.joined())</strong>"
    }

    public mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        "<em>\(emphasis.children.map { visit($0) }.joined())</em>"
    }

    public mutating func visitStrikethrough(_ s: Strikethrough) -> String {
        "<del>\(s.children.map { visit($0) }.joined())</del>"
    }

    public mutating func visitInlineCode(_ code: InlineCode) -> String {
        "<code>\(escapeHTML(code.code))</code>"
    }

    public mutating func visitCodeBlock(_ block: CodeBlock) -> String {
        let lang = block.language ?? ""
        let cls = lang.isEmpty ? "" : " class=\"language-\(lang)\""
        return "<pre><code\(cls)>\(escapeHTML(block.code))</code></pre>\n"
    }

    public mutating func visitBlockQuote(_ quote: BlockQuote) -> String {
        let lines = quote.debugDescription().components(separatedBy: "\n")
        if let callout = CalloutParser.parse(blockquoteLines: lines) {
            return renderCallout(callout)
        }
        let content = quote.children.map { visit($0) }.joined()
        return "<blockquote>\(content)</blockquote>\n"
    }

    public mutating func visitLink(_ link: Link) -> String {
        let dest = link.destination ?? ""
        let label = link.children.map { visit($0) }.joined()
        if dest.hasPrefix("mica://note/") {
            let encoded = dest.dropFirst("mica://note/".count)
            let name = encoded.removingPercentEncoding ?? String(encoded)
            return "<a class=\"wikilink\" href=\"\(dest)\">\(escapeHTML(name))</a>"
        }
        return "<a href=\"\(escapeHTML(dest))\">\(label)</a>"
    }

    public mutating func visitImage(_ image: Image) -> String {
        let src = image.source ?? ""
        let alt = image.title ?? ""
        return "<img src=\"\(escapeHTML(src))\" alt=\"\(escapeHTML(alt))\" />"
    }

    public mutating func visitUnorderedList(_ list: UnorderedList) -> String {
        "<ul>\n\(list.children.map { visit($0) }.joined())</ul>\n"
    }

    public mutating func visitOrderedList(_ list: OrderedList) -> String {
        "<ol>\n\(list.children.map { visit($0) }.joined())</ol>\n"
    }

    public mutating func visitListItem(_ item: ListItem) -> String {
        "<li>\(item.children.map { visit($0) }.joined())</li>\n"
    }

    public mutating func visitThematicBreak(_ br: ThematicBreak) -> String {
        "<hr />\n"
    }

    public mutating func visitSoftBreak(_ br: SoftBreak) -> String { " " }
    public mutating func visitLineBreak(_ br: LineBreak) -> String { "<br />" }

    public mutating func visitHTMLBlock(_ block: HTMLBlock) -> String { block.rawHTML }
    public mutating func visitInlineHTML(_ html: InlineHTML) -> String { html.rawHTML }

    // MARK: - Callouts

    private func renderCallout(_ callout: Callout) -> String {
        let title = callout.title ?? callout.type.rawValue.capitalized
        let color = callout.type.colorHex
        let icon = callout.type.sfSymbol
        return """
        <div class="callout" style="border-left-color:\(color)" data-type="\(callout.type.rawValue)">
          <div class="callout-title" style="color:\(color)">
            <span class="callout-icon" data-sf="\(icon)"></span>
            <span>\(escapeHTML(title))</span>
          </div>
          <div class="callout-body">\(callout.body)</div>
        </div>\n
        """
    }

    // MARK: - Helpers

    private func escapeHTML(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
