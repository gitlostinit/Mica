import Foundation

/// Manages security-scoped access to a user-selected iCloud vault folder.
@Observable
public final class VaultAccess {

    public private(set) var rootURL: URL?
    public private(set) var isLoaded = false

    private let bookmarkKey = "vaultBookmark"

    public init() {}

    public func restore() throws {
        guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return }
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: data,
            options: [],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        if isStale {
            UserDefaults.standard.removeObject(forKey: bookmarkKey)
            return
        }
        guard url.startAccessingSecurityScopedResource() else { return }
        rootURL = url
        isLoaded = true
    }

    public func open(url: URL) throws {
        let data = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(data, forKey: bookmarkKey)
        guard url.startAccessingSecurityScopedResource() else {
            throw VaultError.accessDenied
        }
        rootURL = url
        isLoaded = true
    }

    public func close() {
        rootURL?.stopAccessingSecurityScopedResource()
        rootURL = nil
        isLoaded = false
    }
}

public enum VaultError: LocalizedError {
    case accessDenied
    case notAVault

    public var errorDescription: String? {
        switch self {
        case .accessDenied: "Could not access the selected folder."
        case .notAVault: "No Markdown files found. Is this an Obsidian vault?"
        }
    }
}
