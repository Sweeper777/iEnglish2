import NaturalLanguage

func detectedLangauge(for string: String) -> String? {
    if #available(iOS 12.0, *) {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)
        return recognizer.dominantLanguage?.rawValue
    } else {
        return NSLinguisticTagger.dominantLanguage(for: string)
    }
}
