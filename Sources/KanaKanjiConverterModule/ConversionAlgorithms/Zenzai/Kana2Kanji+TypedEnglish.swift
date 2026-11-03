import Foundation
import SwiftUtils

extension Kana2Kanji {
    /// A stretch of `candidate` that is an English word spelled by the roman keystrokes typed for it
    /// (`google` typed inside `kyouhagoogledekensaku`), as positions in the convert target and in the text.
    struct TypedEnglishSpan: Equatable {
        var surface: Range<Int>
        var text: Range<Int>
        var word: String
    }

    static func typedEnglishSpans(in candidate: Candidate, inputData: ComposingText) -> [TypedEnglishSpan] {
        guard candidate.data.contains(where: { $0.mid == MIDData.英単語.mid }) else {
            return []
        }
        let surfaceToInput = Dictionary(
            inputData.inputIndexToSurfaceIndexMap().map { ($0.value, $0.key) },
            uniquingKeysWith: { min($0, $1) }
        )
        var result: [TypedEnglishSpan] = []
        var surface = 0
        var text = 0
        for element in candidate.data {
            let surfaceEnd = surface + element.ruby.count
            let textEnd = text + element.word.count
            if element.mid == MIDData.英単語.mid,
               element.word.allSatisfy({ $0.isASCII && $0.isLetter }),
               let inputStart = surfaceToInput[surface],
               let inputEnd = surfaceToInput[surfaceEnd],
               inputStart < inputEnd,
               inputEnd <= inputData.input.count {
                let typed = String(inputData.input[inputStart ..< inputEnd].compactMap(DicdataStore.romanLetter))
                if typed.count == inputEnd - inputStart, typed.lowercased() == element.word.lowercased() {
                    result.append(TypedEnglishSpan(surface: surface ..< surfaceEnd, text: text ..< textEnd, word: element.word))
                }
            }
            surface = surfaceEnd
            text = textEnd
        }
        return result
    }

    /// Stretches of `candidate` that are words the user has chosen before (learned or from the user dictionary)
    /// and are written otherwise than their kana, as positions in the convert target and in the text.
    static func userWordSpans(in candidate: Candidate) -> [TypedEnglishSpan] {
        var result: [TypedEnglishSpan] = []
        var surface = 0
        var text = 0
        for element in candidate.data {
            let surfaceEnd = surface + element.ruby.count
            let textEnd = text + element.word.count
            if !element.metadata.isDisjoint(with: [.isLearned, .isFromUserDictionary]), element.word.toKatakana() != element.ruby {
                result.append(TypedEnglishSpan(surface: surface ..< surfaceEnd, text: text ..< textEnd, word: element.word))
            }
            surface = surfaceEnd
            text = textEnd
        }
        return result
    }

    /// The input shown to the model with each typed English word in place of its broken kana (`キョウハGoogleデケンサク`),
    /// so that the model keeps the word instead of rewriting the kana. Spans inside the fixed prefix are left as they are.
    static func zenzInput(_ convertTarget: String, replacing spans: [TypedEnglishSpan], after fixedRubyCount: Int) -> String {
        var characters = Array(convertTarget)
        for span in spans.reversed() where span.surface.lowerBound >= fixedRubyCount && span.surface.upperBound <= characters.count {
            characters.replaceSubrange(span.surface, with: Array(span.word))
        }
        return String(characters)
    }

    /// `constraint` cut where it leaves the best unconstrained path, when that path has any of `spans` (typed English
    /// words, words the user has chosen), so that a prefix the model approved while
    /// the word was still being typed (`ぎて` for `git`, `矢入りの家` for `やいりのけ`) does not keep the word from forming.
    static func constraint(_ constraint: PrefixConstraint, keeping spans: [TypedEnglishSpan], in candidate: Candidate) -> PrefixConstraint {
        guard !spans.isEmpty, !Array(candidate.text.utf8).starts(with: constraint.constraint) else {
            return constraint
        }
        // The part of the constraint that agrees with the path, cut at a character.
        var kept: [UInt8] = []
        for character in candidate.text {
            let next = kept + Array(String(character).utf8)
            guard constraint.constraint.starts(with: next) else {
                break
            }
            kept = next
        }
        guard constraint.constraint.count > kept.count || constraint.hasEOS else {
            return constraint
        }
        if let fixedPrefix = constraint.fixedPrefix, fixedPrefix.byteCount > kept.count {
            return constraint
        }
        var cut = constraint
        cut.constraint = kept
        cut.hasEOS = false
        return cut
    }
}
