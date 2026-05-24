import Foundation

public struct NoteFile: Identifiable, Hashable, Sendable {
    public let id: URL
    public var url: URL { id }
    public let name: String
    public let relativePath: String
    public var modifiedAt: Date?

    public init(url: URL, relativePath: String, modifiedAt: Date?) {
        self.id = url
        self.name = url.deletingPathExtension().lastPathComponent
        self.relativePath = relativePath
        self.modifiedAt = modifiedAt
    }
}

/// In-memory index of all .md files and their wikilink relationships.
@Observable
public final class VaultIndex {

    public private(set) var notes: [NoteFile] = []
    // lowercased filename (no ext) → [NoteFile], for wikilink resolution
    private var byName: [String: [NoteFile]] = [:]
    // note URL → [NoteFile] that link to it
    public private(set) var backlinks: [URL: [NoteFile]] = [:]

    public init() {}

    public func build(root: URL) async {
        let files = await Task.detached(priority: .userInitiated) {
            Self.enumerate(root: root)
        }.value

        notes = files
        byName = Dictionary(grouping: files, by: { $0.name.lowercased() })
        backlinks = await Task.detached(priority: .userInitiated) {
            Self.buildBacklinks(files: files, root: root)
        }.value
    }

    public func resolve(wikilink: String, from source: URL) -> NoteFile? {
        let target = wikilink
            .components(separatedBy: "#").first?
            .components(separatedBy: "|").first?
            .trimmingCharacters(in: .whitespaces)
            .lowercased() ?? ""

        guard let candidates = byName[target], !candidates.isEmpty else { return nil }
        if candidates.count == 1 { return candidates[0] }

        // Prefer shortest path relative to source
        return candidates.min {
            let a = $0.relativePath.components(separatedBy: "/").count
            let b = $1.relativePath.components(separatedBy: "/").count
            return a < b
        }
    }

    // MARK: - Private

    private static func enumerate(root: URL) -> [NoteFile] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.contentModificationDateKey, .isHiddenKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var results: [NoteFile] = []
        for case let url as URL in enumerator {
            guard url.pathExtension.lowercased() == "md" else { continue }
            let rel = url.path.replacingOccurrences(of: root.path + "/", with: "")
            let modified = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
            results.append(NoteFile(url: url, relativePath: rel, modifiedAt: modified))
        }
        return results
    }

    private static func buildBacklinks(files: [NoteFile], root: URL) -> [URL: [NoteFile]] {
        let pattern = #/\[\[([^\]\|#]+)(?:[^\]]*)\]\]/#
        let index: [String: [NoteFile]] = Dictionary(grouping: files, by: { $0.name.lowercased() })
        var result: [URL: [NoteFile]] = [:]

        for file in files {
            guard let content = try? String(contentsOf: file.url, encoding: .utf8) else { continue }
            let matches = content.matches(of: pattern)
            for match in matches {
                let target = String(match.1).lowercased()
                guard let targets = index[target] else { continue }
                for t in targets {
                    result[t.url, default: []].append(file)
                }
            }
        }
        return result
    }
}
