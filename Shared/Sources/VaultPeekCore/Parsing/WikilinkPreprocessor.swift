import Foundation

/// Converts Obsidian-specific syntax to CommonMark before AST parsing.
public enum WikilinkPreprocessor {

    /// Transforms raw Obsidian markdown into preprocessed markdown.
    /// - Wikilinks: [[Note]] → [Note](vaultpeek://note/Note)
    /// - Wikilinks with alias: [[Note|Alias]] → [Alias](vaultpeek://note/Note)
    /// - Highlights: ==text== → <mark>text</mark>
    /// - Inline tags left as-is (rendered by visitor)
    public static func process(_ raw: String) -> String {
        var result = raw
        result = convertWikilinks(result)
        result = convertHighlights(result)
        return result
    }

    private static func convertWikilinks(_ s: String) -> String {
        let pattern = #/\!\[\[([^\]]+)\]\]|\[\[([^\]\|]+)(?:\|([^\]]+))?\]\]/#
        return s.replacing(pattern) { match in
            let full = String(match.0)
            if full.hasPrefix("!") {
                // embed — leave for visitor to handle
                return full
            }
            let target = String(match.2 ?? Substring(""))
            let alias = match.3.map(String.init)
            let encoded = target.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? target
            let label = alias ?? target
            return "[\(label)](vaultpeek://note/\(encoded))"
        }
    }

    private static func convertHighlights(_ s: String) -> String {
        let pattern = #/==([^=]+)==/#
        return s.replacing(pattern) { match in
            "<mark>\(match.1)</mark>"
        }
    }
}
