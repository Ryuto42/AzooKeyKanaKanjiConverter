import Foundation
import SwiftUtils

extension KanaKanjiConverter {
    private static let kanjiDigits: [Character] = Array("〇一二三四五六七八九")
    private static let daijiDigits: [Character] = Array("零壱弐参四五六七八九")
    private static let kanjiRanks: [String] = ["", "十", "百", "千"]
    private static let daijiRanks: [String] = ["", "拾", "百", "阡"]
    private static let kanjiBigRanks: [String] = ["", "万", "億", "兆", "京", "垓", "秭"]
    private static let daijiBigRanks: [String] = ["", "萬", "億", "兆", "京", "垓", "秭"]
    private static let capitalRomanNumerals: [String] = ["Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ", "Ⅺ", "Ⅻ"]
    private static let smallRomanNumerals: [String] = ["ⅰ", "ⅱ", "ⅲ", "ⅳ", "ⅴ", "ⅵ", "ⅶ", "ⅷ", "ⅸ", "ⅹ", "ⅺ", "ⅻ"]
    private static let circledNumbers: [String] = Array("⓪①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿").map(String.init)

    /// 4桁ごとに区切って漢数字にする。`digits`は先頭に0を含まないASCII数字列。
    private static func kanjiNumeral(_ digits: [Int], isDaiji: Bool) -> String? {
        let numerals = isDaiji ? daijiDigits : kanjiDigits
        let ranks = isDaiji ? daijiRanks : kanjiRanks
        let bigRanks = isDaiji ? daijiBigRanks : kanjiBigRanks
        guard !digits.isEmpty else {
            return String(numerals[0])
        }
        guard digits.count <= bigRanks.count * 4 else {
            return nil
        }
        var result = ""
        var end = digits.count
        var bigRankIndex = 0
        while end > 0 {
            let start = max(0, end - 4)
            var segment = ""
            for (i, digit) in digits[start ..< end].enumerated() where digit != 0 {
                let rank = end - start - 1 - i
                // 通常の漢数字では「十」「百」「千」の前の「一」を省略する
                if isDaiji || rank == 0 || digit != 1 {
                    segment.append(numerals[digit])
                }
                segment += ranks[rank]
            }
            if !segment.isEmpty {
                result = segment + bigRanks[bigRankIndex] + result
            }
            end = start
            bigRankIndex += 1
        }
        return result
    }

    func numberStyleCandidates(_ inputData: ComposingText) -> [Candidate] {
        let target = inputData.convertTarget
        guard !target.isEmpty,
              target.unicodeScalars.allSatisfy({ ("0" ... "9").contains($0) || ("０" ... "９").contains($0) }) else {
            return []
        }
        let halfwidth = target.applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? target
        let isHalfwidth = halfwidth == target
        let number = UInt64(halfwidth)

        var texts: [String] = []
        if isHalfwidth {
            texts.append(target.applyingTransform(.fullwidthToHalfwidth, reverse: true) ?? target)
        } else {
            texts.append(halfwidth)
        }

        let digits = halfwidth.drop(while: { $0 == "0" }).compactMap(\.wholeNumberValue)
        if let kanji = Self.kanjiNumeral(digits, isDaiji: false) {
            texts.append(kanji)
        }
        if let daiji = Self.kanjiNumeral(digits, isDaiji: true) {
            texts.append(daiji)
        }
        if let number {
            if let n = Int(exactly: number) {
                if (1 ... Self.capitalRomanNumerals.count).contains(n) {
                    texts.append(Self.capitalRomanNumerals[n - 1])
                    texts.append(Self.smallRomanNumerals[n - 1])
                }
                if n < Self.circledNumbers.count {
                    texts.append(Self.circledNumbers[n])
                }
            }
            texts.append("0x" + String(number, radix: 16))
            texts.append("0" + String(number, radix: 8))
            texts.append("0b" + String(number, radix: 2))
        }

        let ruby = target.toKatakana()
        return texts.enumerated().map { (index, text) in
            let value: PValue = -10 - PValue(index)
            return Candidate(
                text: text,
                value: value,
                composingCount: .inputCount(inputData.input.count),
                lastMid: MIDData.一般.mid,
                data: [DicdataElement(word: text, ruby: ruby, cid: CIDData.固有名詞.cid, mid: MIDData.一般.mid, value: value)]
            )
        }
    }
}
