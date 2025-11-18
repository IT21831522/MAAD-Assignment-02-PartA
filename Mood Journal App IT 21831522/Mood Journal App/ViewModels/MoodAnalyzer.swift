import Foundation
import NaturalLanguage
import CoreML
import Combine

final class MoodAnalyzer: ObservableObject {
    @Published var currentResult: MoodResult?
    @Published var isAnalyzing: Bool = false

    private var sentimentModel: NLModel?

    init() {
        loadModel()
    }

    private func loadModel() {
        if let url = Bundle.main.url(forResource: "SentimentPolarity", withExtension: "mlmodelc"),
           let compiledModel = try? NLModel(contentsOf: url) {
            self.sentimentModel = compiledModel
            return
        }
        sentimentModel = nil
    }

    func analyze(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isAnalyzing = true

        DispatchQueue.global(qos: .userInitiated).async {
            let result: MoodResult
            if let model = self.sentimentModel,
               let label = model.predictedLabel(for: text) {
                let score = self.estimateScore(for: label)
                result = MoodResult(label: label.capitalized, score: score)
            } else {
                let fallbackLabel = self.fallbackRuleBasedLabel(for: text)
                let score = self.estimateScore(for: fallbackLabel)
                result = MoodResult(label: fallbackLabel.capitalized, score: score)
            }

            DispatchQueue.main.async {
                self.currentResult = result
                self.isAnalyzing = false
            }
        }
    }

    private func estimateScore(for label: String) -> Double {
        switch label.lowercased() {
        case "positive": return 0.9
        case "negative": return 0.1
        default: return 0.5
        }
    }

    private func fallbackRuleBasedLabel(for text: String) -> String {
        let lower = text.lowercased()
        let positiveWords = ["happy", "great", "good", "excited", "grateful", "love"]
        let negativeWords = ["sad", "bad", "anxious", "angry", "tired", "upset"]

        var score = 0
        for word in positiveWords where lower.contains(word) { score += 1 }
        for word in negativeWords where lower.contains(word) { score -= 1 }

        if score > 0 { return "positive" }
        if score < 0 { return "negative" }
        return "neutral"
    }
}
