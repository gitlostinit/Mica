import XCTest
@testable import MicaCore

final class FrontmatterParserTests: XCTestCase {

    func testStripsYAMLFrontmatter() {
        let raw = """
        ---
        title: My Note
        tags: [swift, obsidian]
        ---
        # Hello
        World
        """
        let (fm, body) = FrontmatterParser.parse(raw)
        XCTAssertEqual(fm.title, "My Note")
        XCTAssertEqual(fm.tags, ["swift", "obsidian"])
        XCTAssertTrue(body.contains("# Hello"))
        XCTAssertFalse(body.contains("---"))
    }

    func testNoFrontmatter() {
        let raw = "# Just a note\nNo frontmatter here."
        let (fm, body) = FrontmatterParser.parse(raw)
        XCTAssertNil(fm.title)
        XCTAssertTrue(fm.tags.isEmpty)
        XCTAssertEqual(body, raw)
    }
}

final class WikilinkPreprocessorTests: XCTestCase {

    func testConvertsWikilinks() {
        let raw = "See [[Other Note]] for details."
        let result = WikilinkPreprocessor.process(raw)
        XCTAssertTrue(result.contains("mica://note/"))
        XCTAssertTrue(result.contains("Other Note"))
    }

    func testConvertsHighlights() {
        let raw = "This is ==highlighted== text."
        let result = WikilinkPreprocessor.process(raw)
        XCTAssertTrue(result.contains("<mark>highlighted</mark>"))
    }

    func testWikilinkWithAlias() {
        let raw = "See [[Other Note|the note]]."
        let result = WikilinkPreprocessor.process(raw)
        XCTAssertTrue(result.contains("the note"))
        XCTAssertTrue(result.contains("mica://note/"))
    }
}
