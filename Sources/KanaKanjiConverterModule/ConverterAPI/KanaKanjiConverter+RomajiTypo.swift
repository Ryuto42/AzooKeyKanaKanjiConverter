import Foundation
import SwiftUtils

extension KanaKanjiConverter {
    /// The whole input read with one keystroke corrected, when the keystrokes as typed leave roman letters that
    /// form no kana in the middle of the input (`arigatpu` → `ありがtぷ`): a neighboring key on the keyboard,
    /// two keys swapped, a missing vowel or an extra key (`arigatou`, `shmasu` → `shimasu`). `nil` when the input
    /// reads fine, when the letters are an English word, or when no single correction reads fine.
    func romajiTypoCorrectedCandidate(_ inputData: ComposingText, top: Candidate?) -> Candidate? {
        guard inputData.isAtEndIndex,
              let style = inputData.input.first?.inputStyle, style != .direct,
              inputData.input.allSatisfy({ $0.inputStyle == style }) else {
            return nil
        }
        // 区切り（Spaceや末尾の`n`の確定）は末尾にだけあってよい
        let pieces = inputData.input.map(\.piece)
        let separators = pieces.reversed().prefix { $0 == .compositionSeparator }.count
        let typed = pieces.dropLast(separators).compactMap { piece -> Character? in
            switch piece {
            case .character(let c): c
            case .key(intention: _, input: let c, modifiers: _): c
            case .compositionSeparator: nil
            }
        }
        guard typed.count == pieces.count - separators,
              typed.allSatisfy({ $0.isASCII && ($0.isLetter || $0 == "-") }) else {
            return nil
        }
        guard let broken = Self.strayLetterInputIndex(inputData, top: top), broken < typed.count else {
            return nil
        }
        var best: (candidate: Candidate, score: PValue)?
        for (edited, penalty) in Self.singleEdits(of: typed, around: broken) {
            var corrected = ComposingText()
            corrected.insertAtCursorPosition(String(edited), inputStyle: style)
            if separators > 0 {
                corrected.insertAtCursorPosition([.init(piece: .compositionSeparator, inputStyle: style)])
            }
            guard Self.strayLetterInputIndex(corrected, top: nil) == nil, !corrected.convertTarget.isEmpty else {
                continue
            }
            let lattice = self.converter.kana2lattice_all(
                corrected,
                N_best: 1,
                needTypoCorrection: false,
                preprocessedLattice: nil,
                dicdataStoreState: self.dicdataStoreState
            )
            guard let candidate = lattice.result.getCandidateData().map(self.converter.processClauseCandidate).max(by: { $0.value < $1.value }) else {
                continue
            }
            // Per character, so that a shorter reading is not preferred for being short.
            let score = candidate.value / PValue(corrected.convertTarget.count) - penalty
            if best.map({ score > $0.score }) ?? true {
                best = (candidate, score)
            }
        }
        guard var candidate = best?.candidate else {
            return nil
        }
        candidate.composingCount = .inputCount(inputData.input.count)
        return candidate
    }

    /// The input index of the first roman letter left unconverted before the end of the input, outside the typed English words of `top`.
    private static func strayLetterInputIndex(_ inputData: ComposingText, top: Candidate?) -> Int? {
        let target = Array(inputData.convertTarget)
        guard let lastKana = target.lastIndex(where: { !($0.isASCII && $0.isLetter) }) else {
            return nil
        }
        let english = top.map { Kana2Kanji.typedEnglishSpans(in: $0, inputData: inputData).map(\.surface) } ?? []
        guard let stray = target[..<lastKana].indices.first(where: { index in
            target[index].isASCII && target[index].isLetter && !english.contains { $0.contains(index) }
        }) else {
            return nil
        }
        let map = inputData.inputIndexToSurfaceIndexMap()
        return map.filter { $0.value <= stray }.map(\.key).max()
    }

    /// Keystrokes with one correction near `index`, each with a penalty that keeps the least surprising correction ahead.
    private static func singleEdits(of typed: [Character], around index: Int) -> [([Character], PValue)] {
        var result: [([Character], PValue)] = []
        let positions = (max(0, index - 1) ... min(typed.count - 1, index + 2))
        for i in positions {
            for neighbor in neighboringKeys[typed[i]] ?? [] {
                var edited = typed
                edited[i] = neighbor
                result.append((edited, 0.6))
            }
            var deleted = typed
            deleted.remove(at: i)
            result.append((deleted, 0.8))
            for vowel in "aiueo" {
                var inserted = typed
                inserted.insert(vowel, at: i + 1)
                result.append((inserted, 0.8))
            }
            if i + 1 < typed.count {
                var swapped = typed
                swapped.swapAt(i, i + 1)
                result.append((swapped, 0.5))
            }
        }
        return result
    }

    private static let neighboringKeys: [Character: [Character]] = {
        let rows = ["qwertyuiop", "asdfghjkl", "zxcvbnm"].map(Array.init)
        var result: [Character: [Character]] = [:]
        for (r, row) in rows.enumerated() {
            for (c, key) in row.enumerated() {
                var neighbors: [Character] = []
                for (dr, dc) in [(0, -1), (0, 1), (-1, 0), (-1, 1), (1, -1), (1, 0)] {
                    let nr = r + dr
                    let nc = c + dc
                    if rows.indices.contains(nr), rows[nr].indices.contains(nc) {
                        neighbors.append(rows[nr][nc])
                    }
                }
                result[key] = neighbors
            }
        }
        return result
    }()

    /// The letters as typed, as a word, when the input is only roman letters and its best conversion is so unlikely
    /// that it reads as nonsense (`gitignore` → `義ちん之`): a word the dictionary doesn't have, typed in English.
    /// `nil` when the conversion reads well enough or the letters are an English word already.
    func typedLettersCandidate(_ inputData: ComposingText, top: Candidate?) -> Candidate? {
        guard let top, let style = inputData.input.first?.inputStyle, style != .direct, inputData.isAtEndIndex else {
            return nil
        }
        let pieces = inputData.input.map(\.piece)
        let separators = pieces.reversed().prefix { $0 == .compositionSeparator }.count
        let typed = String(pieces.dropLast(separators).compactMap { piece -> Character? in
            switch piece {
            case .character(let c): c
            case .key(intention: _, input: let c, modifiers: _): c
            case .compositionSeparator: nil
            }
        })
        guard typed.count == pieces.count - separators, typed.count >= Self.minTypedWordLength,
              typed.allSatisfy({ $0.isASCII && $0.isLetter }),
              top.text.lowercased() != typed.lowercased(),
              Kana2Kanji.typedEnglishSpans(in: top, inputData: inputData).isEmpty else {
            return nil
        }
        let perCharacter = top.value / PValue(max(1, inputData.convertTarget.count))
        guard perCharacter <= Self.nonsenseValuePerCharacter else {
            return nil
        }
        let element = DicdataElement(word: typed, ruby: inputData.convertTarget.toKatakana(), cid: CIDData.固有名詞.cid, mid: MIDData.英単語.mid, value: top.value)
        return Candidate(text: typed, value: top.value, composingCount: .inputCount(inputData.input.count), lastMid: MIDData.英単語.mid, data: [element])
    }

    private static let minTypedWordLength = 3
    /// これより1文字あたりの評価が低い変換は、読めない並びとみなす
    private static let nonsenseValuePerCharacter: PValue = -8
}
