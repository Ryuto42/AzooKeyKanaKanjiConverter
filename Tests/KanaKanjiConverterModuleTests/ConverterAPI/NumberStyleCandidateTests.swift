@testable import KanaKanjiConverterModule
import XCTest

final class NumberStyleCandidateTests: XCTestCase {
    private func makeDirectInput(direct input: String) -> ComposingText {
        ComposingText(
            convertTargetCursorPosition: input.count,
            input: input.map { .init(character: $0, inputStyle: .direct) },
            convertTarget: input
        )
    }

    private func texts(_ input: String) -> [String] {
        KanaKanjiConverter.withoutDictionary()
            .numberStyleCandidates(makeDirectInput(direct: input))
            .map(\.text)
    }

    func testNumberStyleCandidates() {
        XCTAssertEqual(texts("1"), ["１", "一", "壱", "Ⅰ", "ⅰ", "①", "0x1", "01", "0b1"])
        XCTAssertEqual(texts("12"), ["１２", "十二", "壱拾弐", "Ⅻ", "ⅻ", "⑫", "0xc", "014", "0b1100"])
        XCTAssertEqual(texts("123"), ["１２３", "百二十三", "壱百弐拾参", "0x7b", "0173", "0b1111011"])
        XCTAssertEqual(texts("2026"), ["２０２６", "二千二十六", "弐阡弐拾六", "0x7ea", "03752", "0b11111101010"])
    }

    func testKanjiNumerals() {
        XCTAssertTrue(texts("0").contains("〇"))
        XCTAssertTrue(texts("0").contains("零"))
        XCTAssertTrue(texts("10000").contains("一万"))
        XCTAssertTrue(texts("10000").contains("壱萬"))
        XCTAssertTrue(texts("10001").contains("一万一"))
        XCTAssertTrue(texts("12345678").contains("千二百三十四万五千六百七十八"))
    }

    func testFullwidthInput() {
        XCTAssertEqual(texts("１２３").first, "123")
        XCTAssertTrue(texts("５０").contains("㊿"))
        XCTAssertFalse(texts("５１").contains("㊿"))
    }

    func testInvalidInput() {
        XCTAssertTrue(texts("").isEmpty)
        XCTAssertTrue(texts("1a").isEmpty)
        XCTAssertTrue(texts("1.5").isEmpty)
        XCTAssertTrue(texts("-12").isEmpty)
    }

    func testVeryLargeNumberSkipsRadix() {
        let result = texts("99999999999999999999")
        XCTAssertFalse(result.contains { $0.hasPrefix("0x") })
    }
}
