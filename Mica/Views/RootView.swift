import SwiftUI
import MicaCore

struct RootView: View {
    @Environment(AppState.self) var state

    var body: some View {
        Group {
            if state.access.isLoaded {
                MainView()
            } else {
                VaultPickerView()
            }
        }
        .task { await state.restoreVault() }
    }
}
