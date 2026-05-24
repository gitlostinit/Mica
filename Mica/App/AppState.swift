import SwiftUI
import MicaCore

@Observable
final class AppState {
    var access = VaultAccess()
    var index = VaultIndex()
    var search = NoteSearch()

    var selectedNote: NoteFile?
    var isPickerPresented = false
    var isLoading = false
    var loadError: String?

    func loadVault(url: URL) async {
        isLoading = true
        loadError = nil
        do {
            try access.open(url: url)
            guard let root = access.rootURL else { return }
            await index.build(root: root)

            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            ).first!.appendingPathComponent("Mica")
            try FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
            try await search.setup(appSupportURL: appSupport)
            await search.index(notes: index.notes)
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    func restoreVault() async {
        do { try access.restore() } catch {}
        guard let root = access.rootURL else { return }
        isLoading = true
        await index.build(root: root)
        isLoading = false
    }
}
