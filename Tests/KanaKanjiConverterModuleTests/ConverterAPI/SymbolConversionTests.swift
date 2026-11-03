@testable import KanaKanjiConverterModule
import XCTest

final class SymbolConversionTests: XCTestCase {
    private func makeDirectInput(direct input: String) -> ComposingText {
        ComposingText(
            convertTargetCursorPosition: input.count,
            input: input.map { .init(character: $0, inputStyle: .direct) },
            convertTarget: input
        )
    }

    private func makeRomanInput(_ input: String) -> ComposingText {
        var composingText = ComposingText()
        composingText.insertAtCursorPosition(input, inputStyle: .roman2kana)
        return composingText
    }

    func testReadingCandidates() throws {
        let converter = KanaKanjiConverter.withoutDictionary()
        let kagikakko = converter.symbolCandidates(makeDirectInput(direct: "かぎかっこ")).map(\.text)
        XCTAssertTrue(kagikakko.contains("「」"))
        XCTAssertTrue(kagikakko.contains("『』"))

        let sankaku = converter.symbolCandidates(makeDirectInput(direct: "さんかく")).map(\.text)
        XCTAssertTrue(sankaku.contains("△"))
        XCTAssertTrue(sankaku.contains("▲"))

        XCTAssertTrue(converter.symbolCandidates(makeDirectInput(direct: "あいうえおかきくけこ")).isEmpty)
    }

    func testVariantCandidates() throws {
        let converter = KanaKanjiConverter.withoutDictionary()
        let open = converter.symbolCandidates(makeDirectInput(direct: "「")).map(\.text)
        XCTAssertEqual(open.first, "『")
        XCTAssertTrue(open.contains("【"))
        XCTAssertFalse(open.contains("「"))

        let close = converter.symbolCandidates(makeDirectInput(direct: "」")).map(\.text)
        XCTAssertTrue(close.contains("』"))

        let pair = converter.symbolCandidates(makeDirectInput(direct: "「」")).map(\.text)
        XCTAssertTrue(pair.contains("『』"))
    }

    func testRepeatedDotSubstitution() throws {
        let converter = KanaKanjiConverter.withoutDictionary()
        XCTAssertTrue(converter.symbolCandidates(makeDirectInput(direct: "。。。")).map(\.text).contains("…"))
        XCTAssertTrue(converter.symbolCandidates(makeDirectInput(direct: "...")).map(\.text).contains("…"))
        XCTAssertTrue(converter.symbolCandidates(makeDirectInput(direct: "・・・")).map(\.text).contains("…"))
        XCTAssertTrue(converter.symbolCandidates(makeDirectInput(direct: "。。")).map(\.text).contains("‥"))
    }

    func testEmojiShortcodeCandidates() throws {
        let converter = KanaKanjiConverter.withoutDictionary()
        let smile = converter.emojiShortcodeCandidates(makeRomanInput(":smile")).map(\.text)
        XCTAssertEqual(smile.first, "😄")
        XCTAssertTrue(smile.contains("😄"))

        let pien = converter.emojiShortcodeCandidates(makeRomanInput(":pien")).map(\.text)
        XCTAssertTrue(pien.contains("🥺"))

        let direct = converter.emojiShortcodeCandidates(makeDirectInput(direct: "：smile")).map(\.text)
        XCTAssertTrue(direct.contains("😄"))

        let fuzzy = converter.emojiShortcodeCandidates(makeRomanInput(":hlo")).map(\.text)
        XCTAssertTrue(fuzzy.contains("😇"))
    }

    func testEmojiShortcodeIgnoresOtherInput() throws {
        let converter = KanaKanjiConverter.withoutDictionary()
        XCTAssertTrue(converter.emojiShortcodeCandidates(makeRomanInput("smile")).isEmpty)
        XCTAssertTrue(converter.emojiShortcodeCandidates(makeRomanInput(":")).isEmpty)
        XCTAssertTrue(converter.emojiShortcodeCandidates(makeDirectInput(direct: ":あ")).isEmpty)
        XCTAssertLessThanOrEqual(converter.emojiShortcodeCandidates(makeRomanInput(":s")).count, 50)
    }
}
