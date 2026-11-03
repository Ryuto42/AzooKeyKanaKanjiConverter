import Foundation
import SwiftUtils

extension DicdataStore {
    /// English words spelled by the roman keystrokes starting at `leftIndex`
    /// (`kyouhagoogledekensaku` → `Google`), as nodes ending at each input index
    /// they reach. A proper noun is offered wherever it is spelled; a common word
    /// where the keystrokes don't read as plain kana (`hello` → `へっぉ`), or read
    /// as kana that is no word, for a word of some length or the whole input
    /// (`issue` → `いっすえ`): `make` and `name` are まけ and なめ far more often.
    func englishWordDicdata(
        composingText: ComposingText,
        leftIndex: Int,
        rightIndexRange: Range<Int>,
        inputToSurface: [Int: Int],
        state: DicdataStoreState
    ) -> [(element: DicdataElement, endIndex: Int)] {
        let input = composingText.input
        guard leftIndex < input.count, Self.romanLetter(input[leftIndex]) != nil else {
            return []
        }
        // A word starts where the keystrokes start a kana, not in the middle of one.
        guard let surfaceStart = inputToSurface[leftIndex] else {
            return []
        }
        let surface = Array(composingText.convertTarget)
        var typed = ""
        var result: [(element: DicdataElement, endIndex: Int)] = []
        for i in leftIndex ..< min(input.count, leftIndex + Self.maxEnglishWordLength) {
            guard let letter = Self.romanLetter(input[i]) else {
                break
            }
            typed.append(letter)
            guard rightIndexRange.contains(i),
                  let entry = KashikoWordData.englishWords[typed.lowercased()],
                  let surfaceEnd = inputToSurface[i + 1], surfaceStart < surfaceEnd else {
                continue
            }
            let ruby = String(surface[surfaceStart ..< surfaceEnd]).toKatakana()
            guard entry.proper || ruby.contains(where: { $0.isASCII && $0.isLetter }) || (
                (typed.count >= Self.minMeaninglessReadingLength || (leftIndex == 0 && i + 1 == input.count))
                    && !self.isWord(ruby: ruby, state: state)
            ) else {
                continue
            }
            // Typed with capitals is kept as typed; otherwise the usual spelling (`github` → `GitHub`).
            let word = typed != typed.lowercased() ? typed : (entry.spelling ?? typed)
            let value: PValue = entry.proper ? -9 : -11
            result.append((DicdataElement(word: word, ruby: ruby, cid: CIDData.固有名詞.cid, mid: MIDData.英単語.mid, value: value), i))
            // The word's katakana loanword too (`meeting` → `ミーティング`), for when it was meant in Japanese.
            if let katakana = Self.katakanaForEnglish[typed.lowercased()] {
                result.append((DicdataElement(word: katakana, ruby: ruby, cid: CIDData.一般名詞.cid, mid: MIDData.一般.mid, value: value - 6), i))
            }
        }
        return result
    }

    /// Nodes for a katakana reading that the dictionary doesn't spell this way:
    /// the Latin spelling of a loanword (`テンプレート` → `template`) and a counted
    /// quantity in digits (`ニゲン` → `2限`, `ニモジ` → `2文字`).
    func loanwordAndCountDicdata(ruby: String) -> [DicdataElement] {
        var result: [DicdataElement] = []
        if let english = KashikoWordData.loanwords[ruby] {
            result.append(DicdataElement(word: english, ruby: ruby, cid: CIDData.固有名詞.cid, mid: MIDData.英単語.mid, value: -16))
        }
        result.append(contentsOf: self.countDicdata(ruby: ruby).map(\.element))
        return result
    }

    /// `ruby` read as a number and a counter, written in digits, with the
    /// counter's surface: best first.
    func countDicdata(ruby: String) -> [(element: DicdataElement, counter: String)] {
        var result: [(element: DicdataElement, counter: String)] = []
        let chars = Array(ruby)
        // The longest number first: `ジュウニカイ` is 12階, not 10 followed by `ニカイ`.
        for split in stride(from: chars.count - 1, to: 0, by: -1) {
            guard let counters = KashikoWordData.counters[String(chars[split...])] else {
                continue
            }
            let digits = self.getJapaneseNumberDicdata(head: String(chars[..<split]))
                .map(\.word)
                .first { $0.allSatisfy(\.isASCII) && $0.allSatisfy(\.isNumber) }
            guard let digits else {
                continue
            }
            var value: PValue = -12
            for counter in counters {
                result.append((DicdataElement(word: digits + counter, ruby: ruby, cid: CIDData.数.cid, mid: MIDData.小さい数字.mid, value: value), counter))
                value -= 1
            }
            break
        }
        return result
    }

    /// Words written in kanji whose reading begins with the unvoiced kana where
    /// `ruby` begins with a voiced one: the second half of a compound the
    /// dictionary doesn't list (`ヨガケ` is 夜 + 駆け, read `ガケ`).
    func rendakuDicdata(ruby: String, state: DicdataStoreState) -> [DicdataElement] {
        guard (2 ... Self.maxRendakuWordLength).contains(ruby.count), let first = ruby.first, let plain = Self.unvoiced[first] else {
            return []
        }
        let query = String(plain) + ruby.dropFirst()
        let indices = self.perfectMatchingSearch(query: String(plain), charIDs: query.map(self.character2charId), state: state)
        return self.getDicdataFromLoudstxt3(identifier: String(plain), indices: indices, state: state)
            .filter { $0.word.first.map(Self.isKanji) ?? false }
            .map {
                DicdataElement(word: $0.word, ruby: ruby, lcid: $0.lcid, rcid: $0.rcid, mid: $0.mid, value: $0.value() - 3)
            }
    }

    private func isWord(ruby: String, state: DicdataStoreState) -> Bool {
        guard let first = ruby.first else {
            return false
        }
        return !self.perfectMatchingSearch(query: String(first), charIDs: ruby.map(self.character2charId), state: state).isEmpty
    }

    private static let maxEnglishWordLength = 20
    private static let minMeaninglessReadingLength = 5
    private static let maxRendakuWordLength = 6

    static func romanLetter(_ element: ComposingText.InputElement) -> Character? {
        guard element.inputStyle != .direct else {
            return nil
        }
        let character: Character? = switch element.piece {
        case .character(let c): c
        case .key(intention: _, input: let c, modifiers: _): c
        case .compositionSeparator: nil
        }
        return character.flatMap { $0.isASCII && $0.isLetter ? $0 : nil }
    }

    /// The katakana loanword for an English word (`meeting` → `ミーティング`), if the table has one.
    static func katakanaLoanword(english: String) -> String? {
        katakanaForEnglish[english.lowercased()]
    }

    private static let katakanaForEnglish: [String: String] = Dictionary(
        KashikoWordData.loanwords.map { ($0.value.lowercased(), $0.key) },
        uniquingKeysWith: { first, _ in first }
    )

    private static let unvoiced: [Character: Character] = Dictionary(
        uniqueKeysWithValues: zip("ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ", "カキクケコサシスセソタチツテトハヒフヘホハヒフヘホ")
    )

    private static func isKanji(_ character: Character) -> Bool {
        character.unicodeScalars.first.map { (0x4E00 ... 0x9FFF).contains($0.value) || (0x3400 ... 0x4DBF).contains($0.value) } ?? false
    }
}
