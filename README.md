# Mica

Free, native Obsidian vault viewer for iOS and macOS.

- **iOS app** — open any iCloud Obsidian vault, read-only, no subscription required
- **macOS Quick Look extension** — render `.md` files in Finder with full Obsidian flavor

## Features

- `[[wikilinks]]` with backlink panel
- Callouts (`> [!NOTE]`, all 13 types)
- YAML frontmatter property display
- `==highlights==`, inline `#tags`
- Full-text search (FTS5)
- Image embeds `![[image.png]]`
- Dark mode, Dynamic Type, iPad sidebar

## Architecture

```
Mica/               iOS app target
MicaQuickLook/      macOS Quick Look Preview Extension
MicaThumbnail/      macOS Finder thumbnail extension
Shared/                  Swift Package — shared rendering core
  Sources/MicaCore/
    Parsing/             Markdown AST, wikilink resolver, frontmatter
    Rendering/           SwiftUI visitors, callout renderer, HTML generator
    Vault/               iCloud access, file index, backlink index, FTS5 search
```

## Roadmap

- [ ] v1: iOS vault viewer MVP
- [ ] v1: macOS Quick Look extension
- [ ] v1.1: Graph view
- [ ] v1.1: LaTeX + syntax highlighting
- [ ] v1.1: CoreSpotlight integration

## Building

Requires Xcode 16+, iOS 17+ deployment target, macOS 14+ for the extension.

Open `Mica.xcodeproj` and select the scheme you want to build.
