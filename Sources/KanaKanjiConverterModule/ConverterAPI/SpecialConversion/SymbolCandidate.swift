import Foundation
import SwiftUtils

extension KanaKanjiConverter {
    private struct SymbolTable: Sendable {
        /// 読み(ひらがな) → 記号
        var byReading: [String: [String]] = [:]
        /// 入力された記号 → 関連する記号
        var variants: [String: [String]] = [:]

        init() {
            for line in SymbolData.readings.split(separator: "\n") {
                let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
                byReading[fields[0]] = Array(fields.dropFirst())
            }
            for line in SymbolData.variants.split(separator: "\n") {
                let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
                variants[fields[0]] = Array(fields.dropFirst())
            }
        }
    }

    private static let symbolTable = SymbolTable()

    /// 読みに対応する記号(`かぎかっこ` → `「」`)と、入力された記号の関連記号(`「` → `『`、`。。。` → `…`)を返す関数
    func symbolCandidates(_ inputData: ComposingText) -> [Candidate] {
        let target = inputData.convertTarget
        if target.isEmpty {
            return []
        }
        let table = Self.symbolTable
        let symbols = (table.byReading[target] ?? []) + (table.variants[target] ?? [])
        let ruby = target.toKatakana()
        var seen: Set<String> = [target]
        var results: [Candidate] = []
        for symbol in symbols where seen.insert(symbol).inserted {
            let value: PValue = -15 - PValue(results.count)
            results.append(
                Candidate(
                    text: symbol,
                    value: value,
                    composingCount: .inputCount(inputData.input.count),
                    lastMid: MIDData.一般.mid,
                    data: [DicdataElement(word: symbol, ruby: ruby, cid: .zero, mid: MIDData.一般.mid, value: value)],
                    isLearningTarget: false
                )
            )
        }
        return results
    }
}
