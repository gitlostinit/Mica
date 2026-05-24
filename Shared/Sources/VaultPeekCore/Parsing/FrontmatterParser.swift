import Foundation
import Yams

public struct Frontmatter: Sendable {
    public let title: String?
    public let tags: [String]
    public let properties: [(key: String, value: String)]
    public let bodyRange: Range<String.Index>

    public static let empty = Frontmatter(title: nil, tags: [], properties: [], bodyRange: "".startIndex..<"".endIndex)
}

public enum FrontmatterParser {

    public static func parse(_ raw: String) -> (frontmatter: Frontmatter, body: String) {
        guard raw.hasPrefix("---") else {
            let range = raw.startIndex..<raw.endIndex
            return (Frontmatter(title: nil, tags: [], properties: [], bodyRange: range), raw)
        }

        let lines = raw.components(separatedBy: "\n")
        var closingIndex: Int?
        for (i, line) in lines.enumerated() where i > 0 {
            if line.trimmingCharacters(in: .whitespaces) == "---" {
                closingIndex = i
                break
            }
        }

        guard let end = closingIndex else {
            let range = raw.startIndex..<raw.endIndex
            return (Frontmatter(title: nil, tags: [], properties: [], bodyRange: range), raw)
        }

        let yamlLines = lines[1..<end].joined(separator: "\n")
        let bodyLines = lines[(end + 1)...].joined(separator: "\n")

        var title: String?
        var tags: [String] = []
        var properties: [(key: String, value: String)] = []

        if let yaml = try? Yams.load(yaml: yamlLines) as? [String: Any] {
            title = yaml["title"] as? String
            if let t = yaml["tags"] as? [String] { tags = t }
            else if let t = yaml["tags"] as? String { tags = [t] }
            for (k, v) in yaml where k != "tags" {
                properties.append((key: k, value: "\(v)"))
            }
        }

        let bodyStart = bodyLines.startIndex
        let fm = Frontmatter(title: title, tags: tags, properties: properties, bodyRange: bodyStart..<bodyLines.endIndex)
        return (fm, bodyLines)
    }
}
