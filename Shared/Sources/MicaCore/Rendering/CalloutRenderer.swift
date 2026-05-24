import Foundation

public struct Callout: Equatable {
    public let type: CalloutType
    public let title: String?
    public let isCollapsible: Bool
    public let isExpanded: Bool
    public let body: String
}

public enum CalloutType: String, CaseIterable {
    case note, tip, important, warning, caution
    case abstract, summary, tldr
    case info, todo
    case success, check, done
    case question, help, faq
    case failure, fail, missing
    case danger, error
    case bug
    case example
    case quote, cite

    public var sfSymbol: String {
        switch self {
        case .note: return "pencil"
        case .tip, .important: return "lightbulb"
        case .warning, .caution: return "exclamationmark.triangle"
        case .abstract, .summary, .tldr: return "doc.plaintext"
        case .info: return "info.circle"
        case .todo: return "checkmark.circle"
        case .success, .check, .done: return "checkmark.seal"
        case .question, .help, .faq: return "questionmark.circle"
        case .failure, .fail, .missing: return "xmark.circle"
        case .danger, .error: return "bolt.trianglebadge.exclamationmark"
        case .bug: return "ant"
        case .example: return "list.bullet"
        case .quote, .cite: return "quote.opening"
        }
    }

    public var colorHex: String {
        switch self {
        case .note: return "#448AFF"
        case .tip, .important: return "#00BCD4"
        case .warning, .caution: return "#FF9100"
        case .abstract, .summary, .tldr: return "#00BFA5"
        case .info: return "#2196F3"
        case .todo: return "#2196F3"
        case .success, .check, .done: return "#4CAF50"
        case .question, .help, .faq: return "#9C27B0"
        case .failure, .fail, .missing: return "#F44336"
        case .danger, .error: return "#FF1744"
        case .bug: return "#F44336"
        case .example: return "#7E57C2"
        case .quote, .cite: return "#9E9E9E"
        }
    }
}

public enum CalloutParser {
    // Matches: > [!type]+ optional title
    private static let headerPattern = #/^>\s*\[!(\w+)\](\+|\-)?\s*(.*)$/#

    public static func parse(blockquoteLines lines: [String]) -> Callout? {
        guard let first = lines.first,
              let match = try? headerPattern.firstMatch(in: first) else { return nil }

        let rawType = String(match.1).lowercased()
        guard let calloutType = CalloutType(rawValue: rawType) else { return nil }

        let modifier = match.2.map(String.init)
        let isCollapsible = modifier != nil
        let isExpanded = modifier == "+"
        let title = String(match.3).isEmpty ? nil : String(match.3)

        let body = lines.dropFirst()
            .map { $0.hasPrefix("> ") ? String($0.dropFirst(2)) : String($0.dropFirst(min(2, $0.count))) }
            .joined(separator: "\n")

        return Callout(type: calloutType, title: title, isCollapsible: isCollapsible, isExpanded: isExpanded, body: body)
    }
}
