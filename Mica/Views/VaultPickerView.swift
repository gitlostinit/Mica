import SwiftUI

struct VaultPickerView: View {
    @Environment(AppState.self) var state

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 64))
                        .foregroundStyle(.purple)

                    Text("Mica")
                        .font(.largeTitle.bold())

                    Text("Free Obsidian vault viewer.\nNo subscription required.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let error = state.loadError {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button {
                    state.isPickerPresented = true
                } label: {
                    Label("Open Vault from iCloud Drive", systemImage: "icloud")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.purple)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)

                Spacer()

                Text("Select the folder that contains your Obsidian vault.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
            .padding()
            .fileImporter(
                isPresented: Binding(
                    get: { state.isPickerPresented },
                    set: { state.isPickerPresented = $0 }
                ),
                allowedContentTypes: [.folder]
            ) { result in
                switch result {
                case .success(let url):
                    Task { await state.loadVault(url: url) }
                case .failure(let error):
                    state.loadError = error.localizedDescription
                }
            }
            .overlay {
                if state.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("Indexing vault…")
                                .font(.headline)
                        }
                        .padding(32)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
        }
    }
}
