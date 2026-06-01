# Mica

A native, free, open-source markdown viewer for iOS and macOS.

Mica reads `.md` files and renders them beautifully. That's it. No editor, no sync, no account, no subscription, no vendor lock-in. Just a fast, native viewer for the markdown you already have. Open source under the LICENSE in this repo.

## What it is

- **macOS Quick Look extension** — preview any `.md` file from Finder with a spacebar tap, rendered the way it was meant to look
- **macOS Finder thumbnail extension** — see the actual rendered content as the file thumbnail, not a generic text icon
- **iOS app** — open any folder of markdown (from iCloud Drive, Files, or any storage provider) and read it with a real reading layout

## What it isn't

- Not an editor. Mica doesn't write to your files.
- Not tied to any one source app. It doesn't require Obsidian, Bear, Logseq, iA Writer, Notion exports, or any other tool. If it's `.md`, Mica reads it.
- Not a sync service. Your files stay wherever you keep them.
- Not paid. There's nothing to upgrade.

## Supported markdown features

Mica renders the markdown features people actually use, including the ones that have become de-facto standards beyond CommonMark:

- Headings, paragraphs, lists, code blocks, tables, blockquotes
- `[[wikilinks]]` resolved across the folder you open, with a backlink panel
- Callout blocks (`> [!NOTE]`, `> [!WARNING]`, etc. — all 13 standard types)
- YAML frontmatter properties rendered above the body
- `==highlights==` and inline `#tags`
- Image embeds, both `![[image.png]]` wiki-style and standard `![]()` syntax
- Full-text search across the folder using SQLite FTS5
- Dark mode, Dynamic Type, iPad split view

## Where it works

| Surface | Platform | What it does |
| -- | -- | -- |
| Quick Look | macOS | Press spacebar on a `.md` file in Finder — rendered preview |
| Finder thumbnails | macOS | The file icon shows a tiny rendered preview |
| Mica.app | iOS | Open a folder of markdown, read it like a book |

## Architecture

```
Mica/               iOS app target
MicaMac/            macOS app target
MicaQuickLook/      macOS Quick Look Preview Extension
MicaThumbnail/      macOS Finder thumbnail extension
Shared/             Swift Package — shared rendering core
  Sources/MicaCore/
    Parsing/        Markdown AST, wikilink resolver, frontmatter parser
    Rendering/      SwiftUI visitors, callout renderer, HTML generator
    Vault/          iCloud access, file index, backlink index, FTS5 search
```

Everything that touches markdown lives in the shared `MicaCore` package. The platform targets are thin wrappers — UI on iOS, extension hosts on macOS — so the rendering behavior is identical across every surface.

## Roadmap

- [ ] v1.0 — iOS reader MVP + macOS Quick Look + Finder thumbnail
- [ ] v1.1 — Graph view of wikilinks
- [ ] v1.1 — LaTeX math + syntax highlighting in code blocks
- [ ] v1.1 — CoreSpotlight integration for system-wide search

## Building

Requires Xcode 16+, iOS 17+ deployment target, macOS 14+ for the extensions.

Open `Mica.xcodeproj` and pick the scheme you want to build.

## Why "Mica"

Mica is a mineral that splits into thin, perfectly flat sheets. That's the goal — markdown files should look like the clean, layered documents they are, on every surface where you encounter them.

## License

Open source. See `LICENSE` for the legal version. Contributions welcome — file an issue or open a PR.

## Contact

For questions, feedback, or anything else: contactanthony@weddle.tv
