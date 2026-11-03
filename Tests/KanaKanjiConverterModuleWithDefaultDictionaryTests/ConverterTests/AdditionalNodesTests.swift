import Foundation
@testable import KanaKanjiConverterModule
@testable import KanaKanjiConverterModuleWithDefaultDictionary
import XCTest

final class AdditionalNodesTests: XCTestCase {
    private func candidates(_ input: String, inputStyle: InputStyle) -> [String] {
        let converter = KanaKanjiConverter.withDefaultDictionary()
        var composingText = ComposingText()
        composingText.insertAtCursorPosition(input, inputStyle: inputStyle)
        return converter.requestCandidates(composingText, options: requestOptions()).mainResults.map(\.text)
    }

    func testEnglishWordsInsideRomajiStayEnglish() {
        XCTAssertTrue(candidates("kyouhagoogledekensaku", inputStyle: .roman2kana).prefix(3).contains { $0.contains("Google") })
        XCTAssertTrue(candidates("zoomdekaigi", inputStyle: .roman2kana).prefix(3).contains { $0.contains("Zoom") })
        // A common word whose keystrokes read as kana that is no word.
        XCTAssertTrue(candidates("githubnoissue", inputStyle: .roman2kana).prefix(3).contains { $0.contains("GitHubのissue") })
    }

    func testCommonWordsReadingAsJapaneseStayJapanese() {
        XCTAssertFalse(candidates("makewoshita", inputStyle: .roman2kana).prefix(3).contains { $0.contains("make") })
    }

    func testLoanwordsOfferTheirLatinSpelling() {
        XCTAssertTrue(candidates("てんぷれーと", inputStyle: .direct).contains("template"))
    }

    func testCountedQuantitiesOfferDigits() {
        XCTAssertTrue(candidates("にげん", inputStyle: .direct).contains("2限"))
        XCTAssertTrue(candidates("てまえにもじより", inputStyle: .direct).contains { $0.contains("2文字") })
        // Only a stretch ending on the counter itself is read as a count.
        XCTAssertFalse(candidates("ここにかいた", inputStyle: .direct).contains { $0.contains("2回") || $0.contains("2階") })
    }

    func testVoicedSecondHalfOfACompoundIsLookedUpUnvoiced() {
        XCTAssertTrue(candidates("よがけ", inputStyle: .direct).contains { $0.hasSuffix("掛け") })
    }

    func testKanjiNumeralsWithACounterBecomeDigits() {
        let converter = KanaKanjiConverter.withDefaultDictionary()
        func rewrite(_ words: [(String, String)]) -> String? {
            let data = words.map { DicdataElement(word: $0.0, ruby: $0.1, cid: CIDData.一般名詞.cid, mid: MIDData.一般.mid, value: -10) }
            let candidate = Candidate(text: data.map(\.word).joined(), value: -10, composingCount: .inputCount(0), lastMid: 0, data: data)
            return converter.digitCountRewrite(of: candidate)?.text
        }
        XCTAssertEqual(rewrite([("二限", "ニゲン")]), "2限")
        XCTAssertEqual(rewrite([("五", "ゴ"), ("分", "フン"), ("待つ", "マツ")]), "5分待つ")
        XCTAssertEqual(rewrite([("二十五日", "ニジュウゴニチ")]), "25日")
        XCTAssertNil(rewrite([("二三日", "ニサンニチ")]))
        XCTAssertNil(rewrite([("一番", "イチバン")]))
        XCTAssertNil(rewrite([("一度", "イチド")]))
    }

    func testEnglishWordIsFollowedByItsOtherSpellings() {
        let result = candidates("github", inputStyle: .roman2kana)
        XCTAssertEqual(result.first, "GitHub")
        let github = result.firstIndex(of: "github")
        let broken = result.firstIndex { $0.contains("ゅb") }
        XCTAssertNotNil(github)
        XCTAssertTrue(broken.map { github! < $0 } ?? true)
        XCTAssertTrue(candidates("meeting", inputStyle: .roman2kana).prefix(3).contains("ミーティング"))
    }

    func testRomajiThatFormsNoKanaIsCorrectedByOneKeystroke() {
        let top = candidates("arigatpu", inputStyle: .roman2kana).first ?? ""
        XCTAssertFalse(top.contains { $0.isASCII && $0.isLetter }, top)
        XCTAssertTrue(["ありがとう", "有難う", "有り難う"].contains(top), top)
        // Typed English words and the last pending letter are not typos.
        XCTAssertEqual(candidates("kyouhagoogledekensaku", inputStyle: .roman2kana).first, "今日はGoogleで検索")
        XCTAssertTrue(candidates("kakunink", inputStyle: .roman2kana).first?.hasSuffix("k") ?? false)
    }

    func testLettersThatConvertOnlyToNonsenseAreOfferedAsTyped() {
        XCTAssertEqual(candidates("gitignore", inputStyle: .roman2kana).first, "gitignore")
        XCTAssertEqual(candidates("grep", inputStyle: .roman2kana).first, "grep")
        // Words that convert well stay converted.
        XCTAssertNotEqual(candidates("takahashi", inputStyle: .roman2kana).first, "takahashi")
        XCTAssertNotEqual(candidates("kaigi", inputStyle: .roman2kana).first, "kaigi")
    }

    func testSymbolsComeRightAfterTheTopAndDotsAreReplaced() {
        let providers: [any SpecialCandidateProvider] = [SymbolSpecialCandidateProvider()]
        XCTAssertEqual(candidates("かぎかっこ", inputStyle: .direct, providers: providers).dropFirst().first, "「」")
        XCTAssertEqual(candidates("。。。", inputStyle: .direct, providers: providers).first, "…")
    }

    func testTypedEnglishSpansAreFoundFromTheKeystrokes() {
        var composingText = ComposingText()
        composingText.insertAtCursorPosition("googlede", inputStyle: .roman2kana)
        let candidate = Candidate(
            text: "Googleで",
            value: 0,
            composingCount: .inputCount(composingText.input.count),
            lastMid: 0,
            data: [
                DicdataElement(word: "Google", ruby: "ゴオgェ", cid: CIDData.固有名詞.cid, mid: MIDData.英単語.mid, value: 0),
                DicdataElement(word: "で", ruby: "デ", cid: CIDData.一般名詞.cid, mid: MIDData.一般.mid, value: 0),
            ]
        )
        let spans = Kana2Kanji.typedEnglishSpans(in: candidate, inputData: composingText)
        XCTAssertEqual(spans.map(\.word), ["Google"])
        XCTAssertEqual(Kana2Kanji.zenzInput(composingText.convertTarget, replacing: spans, after: 0), "Googleで")
        // A prefix the model approved while the word was being typed is cut before the word.
        let constraint = Kana2Kanji.constraint(Kana2Kanji.PrefixConstraint(Array("ご".utf8)), keeping: spans, in: candidate)
        XCTAssertEqual(constraint.constraint, [])
    }

    func testLearnedWordIsFoundWhenItsLastKanaIsTyped() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let converter = KanaKanjiConverter.withDefaultDictionary()
        let options = requestOptions(learningType: .inputAndOutput, memoryDirectoryURL: directory)
        var sentence = ComposingText()
        sentence.insertAtCursorPosition("やいりさんに", inputStyle: .direct)
        let learned = try XCTUnwrap(converter.requestCandidates(sentence, options: options).mainResults.first { $0.text == "矢入さんに" })
        converter.updateLearningData(learned)
        converter.stopComposition()
        // Typed one kana at a time, the lattice is built incrementally.
        var word = ComposingText()
        var top: Candidate?
        for kana in ["や", "い", "り"] {
            word.insertAtCursorPosition(kana, inputStyle: .direct)
            top = converter.requestCandidates(word, options: options).mainResults.first
        }
        XCTAssertEqual(top?.text, "矢入")
        XCTAssertTrue(top?.data.contains { $0.metadata.contains(.isLearned) } ?? false)
    }

    private func candidates(_ input: String, inputStyle: InputStyle, providers: [any SpecialCandidateProvider]) -> [String] {
        let converter = KanaKanjiConverter.withDefaultDictionary()
        var composingText = ComposingText()
        composingText.insertAtCursorPosition(input, inputStyle: inputStyle)
        return converter.requestCandidates(composingText, options: requestOptions(providers: providers)).mainResults.map(\.text)
    }

    private func requestOptions(
        learningType: LearningType = .nothing,
        memoryDirectoryURL: URL = URL(fileURLWithPath: ""),
        providers: [any SpecialCandidateProvider] = []
    ) -> ConvertRequestOptions {
        ConvertRequestOptions(
            N_best: 10,
            requireJapanesePrediction: .disabled,
            requireEnglishPrediction: .disabled,
            keyboardLanguage: .ja_JP,
            learningType: learningType,
            memoryDirectoryURL: memoryDirectoryURL,
            sharedContainerURL: memoryDirectoryURL,
            textReplacer: .empty,
            specialCandidateProviders: providers,
            typoCorrectionMode: .disabled,
            metadata: nil
        )
    }
}
