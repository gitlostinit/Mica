import SwiftUI

@main
struct MicaMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.purple)
            Text("Mica Quick Look")
                .font(.title2.bold())
            Text("Select any .md file in Finder and press Space\nto preview your Obsidian notes.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .frame(width: 380, height: 260)
    }
}
