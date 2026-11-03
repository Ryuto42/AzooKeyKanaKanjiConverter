import Foundation
import SwiftUtils

extension KanaKanjiConverter {
    private struct EmojiShortcodeTable: Sendable {
        var emojis: [String] = []
        /// (ショートコード, `emojis`のインデックス)。データファイル中の順序を保つ
        var triggers: [(trigger: [UInt8], emojiIndex: Int)] = []

        init() {
            for line in EmojiShortcodeData.entries.split(separator: "\n") {
                let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
                emojis.append(String(fields[0]))
                for trigger in fields[1].split(separator: " ") {
                    triggers.append((Array(trigger.utf8), emojis.count - 1))
                }
            }
        }
    }

    private static let emojiShortcodeTable = EmojiShortcodeTable()
    private static let emojiShortcodeMaxCount = 50

    /// 並べ替え用のスコア。小さいほど良い。(最長の連続一致の長さ, 一致開始位置, ショートコードの長さ)
    private struct ShortcodeMatchScore: Comparable {
        var longestRun: Int
        var start: Int
        var length: Int

        static func < (lhs: Self, rhs: Self) -> Bool {
            (rhs.longestRun, lhs.start, lhs.length) < (lhs.longestRun, rhs.start, rhs.length)
        }
    }

    /// `query`が`target`の部分列になる配置のうち、最も良いものをスコアにして返す。
    private static func shortcodeMatchScore(query: [UInt8], target: [UInt8]) -> ShortcodeMatchScore? {
        var best: ShortcodeMatchScore?
        for start in target.indices where target[start] == query[0] {
            var queryIndex = 1
            var previous = start
            var run = 1
            var longest = 1
            for targetIndex in target.indices.dropFirst(start + 1) {
                if queryIndex >= query.count {
                    break
                }
                guard target[targetIndex] == query[queryIndex] else {
                    continue
                }
                run = targetIndex == previous + 1 ? run + 1 : 1
                longest = max(longest, run)
                previous = targetIndex
                queryIndex += 1
            }
            guard queryIndex == query.count else {
                continue
            }
            let score = ShortcodeMatchScore(longestRun: longest, start: start, length: target.count)
            if best.map({ score < $0 }) ?? true {
                best = score
            }
        }
        return best
    }

    /// `:smile`のようなSlack形式のショートコードから絵文字の候補を返す関数
    ///
    /// ローマ字入力でもかな変換前の入力を使うため、`inputData.input`から元の文字列を復元する。
    func emojiShortcodeCandidates(_ inputData: ComposingText) -> [Candidate] {
        var raw = ""
        for element in inputData.input {
            switch element.piece {
            case .character(let character):
                raw.append(character)
            case .key(let intention, let input, _):
                raw.append(intention ?? input)
            case .compositionSeparator:
                // Spaceで変換を始めたときに末尾に入る区切りは読まない
                continue
            }
        }
        guard let first = raw.first, first == ":" || first == "：" else {
            return []
        }
        let query = Array(raw.dropFirst().lowercased().utf8)
        guard !query.isEmpty, query.allSatisfy({ $0.isASCIILetter || $0.isASCIIDigit || $0 == UInt8(ascii: "_") || $0 == UInt8(ascii: "+") || $0 == UInt8(ascii: "-") }) else {
            return []
        }
        let table = Self.emojiShortcodeTable
        var scored: [(score: ShortcodeMatchScore, order: Int, emojiIndex: Int)] = []
        for (order, entry) in table.triggers.enumerated() {
            if let score = Self.shortcodeMatchScore(query: query, target: entry.trigger) {
                scored.append((score, order, entry.emojiIndex))
            }
        }
        scored.sort { ($0.score, $0.order) < ($1.score, $1.order) }

        let ruby = inputData.convertTarget.toKatakana()
        var seen: Set<Int> = []
        var results: [Candidate] = []
        for entry in scored where seen.insert(entry.emojiIndex).inserted {
            let emoji = table.emojis[entry.emojiIndex]
            let value: PValue = -15 - PValue(results.count)
            results.append(
                Candidate(
                    text: emoji,
                    value: value,
                    composingCount: .inputCount(inputData.input.count),
                    lastMid: MIDData.一般.mid,
                    data: [DicdataElement(word: emoji, ruby: ruby, cid: .zero, mid: MIDData.一般.mid, value: value)],
                    isLearningTarget: false
                )
            )
            if results.count >= Self.emojiShortcodeMaxCount {
                break
            }
        }
        return results
    }
}

private extension UInt8 {
    var isASCIILetter: Bool {
        (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(self)
    }

    var isASCIIDigit: Bool {
        (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(self)
    }
}
