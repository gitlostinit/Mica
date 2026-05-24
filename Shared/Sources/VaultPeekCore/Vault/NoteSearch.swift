import Foundation
import GRDB

public struct SearchResult: Identifiable, Sendable {
    public let id: URL
    public let url: URL
    public let title: String
    public let relativePath: String
    public let snippet: String
}

/// FTS5-backed full-text search over vault notes.
public actor NoteSearch {

    private var db: DatabaseQueue?

    public init() {}

    public func setup(appSupportURL: URL) throws {
        let dbURL = appSupportURL.appendingPathComponent("VaultPeek.sqlite")
        db = try DatabaseQueue(path: dbURL.path)
        try db?.write { db in
            try db.execute(sql: """
                CREATE TABLE IF NOT EXISTS notes (
                    url TEXT PRIMARY KEY,
                    title TEXT,
                    path TEXT,
                    body TEXT,
                    modified REAL
                );
                CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
                    title, body,
                    content=notes, content_rowid=rowid,
                    tokenize='porter unicode61'
                );
                CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
                    INSERT INTO notes_fts(rowid, title, body) VALUES (new.rowid, new.title, new.body);
                END;
                CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes BEGIN
                    INSERT INTO notes_fts(notes_fts, rowid, title, body) VALUES('delete', old.rowid, old.title, old.body);
                    INSERT INTO notes_fts(rowid, title, body) VALUES (new.rowid, new.title, new.body);
                END;
            """)
        }
    }

    public func index(notes: [NoteFile]) async {
        guard let db else { return }
        await withTaskGroup(of: (NoteFile, String)?.self) { group in
            for note in notes {
                group.addTask {
                    guard let body = try? String(contentsOf: note.url, encoding: .utf8) else { return nil }
                    return (note, body)
                }
            }
            for await result in group {
                guard let (note, body) = result else { continue }
                let (_, cleanBody) = FrontmatterParser.parse(body)
                try? db.write { db in
                    try db.execute(
                        sql: "INSERT OR REPLACE INTO notes(url, title, path, body, modified) VALUES (?,?,?,?,?)",
                        arguments: [
                            note.url.path,
                            note.name,
                            note.relativePath,
                            cleanBody,
                            note.modifiedAt?.timeIntervalSince1970 ?? 0
                        ]
                    )
                }
            }
        }
    }

    public func search(query: String, limit: Int = 30) throws -> [SearchResult] {
        guard let db, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let safe = query.trimmingCharacters(in: .whitespaces) + "*"
        return try db.read { db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT n.url, n.title, n.path,
                       snippet(notes_fts, 1, '<b>', '</b>', '…', 20) AS snippet
                FROM notes_fts
                JOIN notes n ON n.rowid = notes_fts.rowid
                WHERE notes_fts MATCH ?
                ORDER BY rank
                LIMIT ?
            """, arguments: [safe, limit])
            return rows.compactMap { row -> SearchResult? in
                guard let path = row["url"] as? String,
                      let url = URL(string: "file://\(path)") else { return nil }
                return SearchResult(
                    id: url,
                    url: url,
                    title: row["title"] as? String ?? "",
                    relativePath: row["path"] as? String ?? "",
                    snippet: row["snippet"] as? String ?? ""
                )
            }
        }
    }
}
