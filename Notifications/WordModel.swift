//
//  WordModel.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import Foundation

// MARK: - Data Model
struct Word: Codable {
    let word: String
    let meaning: String
}

enum WordDefinitionStyle {
    case standard
    case concise
    case flashcard
}

// MARK: - Word Service
class WordService {
    static let shared = WordService()
    
    private var standardWords: [Word] = []
    private var conciseWords: [Word] = []
    private var flashcardWords: [Word] = []
    private var isStandardWordsLoaded = false
    private var isConciseWordsLoaded = false
    private var isFlashcardWordsLoaded = false
    
    private init() {}
    
    func loadWords(style: WordDefinitionStyle = .standard) -> [Word]? {
        switch style {
        case .standard:
            if isStandardWordsLoaded {
                return standardWords
            }
            
            if let words = loadWordsFromFile(filename: "words") {
                standardWords = words
                isStandardWordsLoaded = true
                return words
            }
            return nil
            
        case .concise:
            if isConciseWordsLoaded {
                return conciseWords
            }
            
            if let words = loadWordsFromFile(filename: "short_words") {
                conciseWords = words
                isConciseWordsLoaded = true
                return words
            }
            
            // Fall back to standard words if concise not available
            return loadWords(style: .standard)
            
        case .flashcard:
            if isFlashcardWordsLoaded {
                return flashcardWords
            }
            
            if let words = loadWordsFromFile(filename: "words_flashcard") {
                flashcardWords = words
                isFlashcardWordsLoaded = true
                return words
            }
            
            // Fall back to concise words if flashcard not available
            return loadWords(style: .concise)
        }
    }
    
    private func loadWordsFromFile(filename: String) -> [Word]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Could not find \(filename).json in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([Word].self, from: data)
            return words
        } catch {
            print("Error loading words from \(filename).json: \(error)")
            return nil
        }
    }
    
    func getRandomWords(count: Int, style: WordDefinitionStyle = .standard) -> [Word]? {
        guard let words = loadWords(style: style), !words.isEmpty else {
            return nil
        }
        
        let shuffled = words.shuffled()
        let numberOfWords = min(count, shuffled.count)
        return Array(shuffled.prefix(numberOfWords))
    }
}

// MARK: - Personalized Quiz Service
class PersonalizedQuizService {
    static let shared = PersonalizedQuizService()
    
    private init() {
        loadWrongWordsFromStorage()
    }
    
    // Dictionary to track words that need practice
    // Key: word, Value: streak (0-3)
    private var wrongWords: [String: Int] = [:]
    
    // Dictionary to track how many times each word was answered incorrectly
    // This count is never reset, even when a word is mastered
    private var wrongCountTracker: [String: Int] = [:]
    
    // MARK: - Public Methods
    
    // Mark a word as wrong (add to practice list)
    func markWordAsWrong(_ word: String) {
        // Reset streak to 0
        wrongWords[word] = 0
        
        // Increment wrong count
        wrongCountTracker[word] = (wrongCountTracker[word] ?? 0) + 1
        
        // Save to storage
        saveWrongWordsToStorage()
    }
    
    // Mark a word as correct (increment streak)
    func markWordAsCorrect(_ word: String) {
        // If word is not in wrong words, do nothing
        guard let currentStreak = wrongWords[word] else { return }
        
        // Increment streak
        let newStreak = currentStreak + 1
        
        // If streak reaches 3, remove from wrong words
        if newStreak >= 3 {
            wrongWords.removeValue(forKey: word)
            // Note: We keep the word in wrongCountTracker to maintain history
        } else {
            wrongWords[word] = newStreak
        }
        
        // Save to storage
        saveWrongWordsToStorage()
    }
    
    // Reset streak for a word (when user gets it wrong again)
    func resetWordStreak(_ word: String) {
        // Reset streak to 0
        wrongWords[word] = 0
        
        // Increment wrong count
        wrongCountTracker[word] = (wrongCountTracker[word] ?? 0) + 1
        
        // Save to storage
        saveWrongWordsToStorage()
    }
    
    // Check if there are enough words for a personalized quiz
    func hasEnoughWordsForPersonalizedQuiz() -> Bool {
        return wrongWords.count >= 5
    }
    
    // Get all wrong words for quiz
    func getWrongWordsForQuiz() -> [String] {
        return Array(wrongWords.keys)
    }
    
    // Get current streak for a word
    func getStreakForWord(_ word: String) -> Int {
        return wrongWords[word] ?? 0
    }
    
    // Get wrong count for a word
    func getWrongCountForWord(_ word: String) -> Int {
        return wrongCountTracker[word] ?? 0
    }
    
    // Get all wrong words with their counts and streaks
    func getAllWrongWordsWithCounts() -> [(word: String, wrongCount: Int, streak: Int)] {
        // Combine all words that have ever been wrong
        var allWrongWordsList: [(word: String, wrongCount: Int, streak: Int)] = []
        
        // Add all words from wrongCountTracker
        for (word, count) in wrongCountTracker {
            let streak = wrongWords[word] ?? 0
            allWrongWordsList.append((word: word, wrongCount: count, streak: streak))
        }
        
        // Sort by wrong count (descending)
        return allWrongWordsList.sorted { $0.wrongCount > $1.wrongCount }
    }
    
    // Get words currently in practice (not mastered)
    func getWordsCurrentlyInPractice() -> [(word: String, wrongCount: Int, streak: Int)] {
        var practiceWordsList: [(word: String, wrongCount: Int, streak: Int)] = []
        
        for (word, streak) in wrongWords {
            let count = wrongCountTracker[word] ?? 0
            practiceWordsList.append((word: word, wrongCount: count, streak: streak))
        }
        
        // Sort by wrong count (descending)
        return practiceWordsList.sorted { $0.wrongCount > $1.wrongCount }
    }
    
    // Add a word back to practice
    func addWordBackToPractice(_ word: String) {
        // Only add if the word has a history of being wrong
        if wrongCountTracker[word] != nil {
            // Add with streak of 0
            wrongWords[word] = 0
            saveWrongWordsToStorage()
        }
    }
    
    // MARK: - Private Methods
    
    private func saveWrongWordsToStorage() {
        let defaults = UserDefaults.standard
        
        // Save wrong words dictionary
        if let encoded = try? JSONEncoder().encode(wrongWords) {
            defaults.set(encoded, forKey: "wrongWords")
        }
        
        // Save wrong count tracker
        if let encoded = try? JSONEncoder().encode(wrongCountTracker) {
            defaults.set(encoded, forKey: "wrongCountTracker")
        }
    }
    
    private func loadWrongWordsFromStorage() {
        let defaults = UserDefaults.standard
        
        // Load wrong words dictionary
        if let savedWrongWords = defaults.object(forKey: "wrongWords") as? Data {
            if let decodedWrongWords = try? JSONDecoder().decode([String: Int].self, from: savedWrongWords) {
                wrongWords = decodedWrongWords
            }
        }
        
        // Load wrong count tracker
        if let savedWrongCountTracker = defaults.object(forKey: "wrongCountTracker") as? Data {
            if let decodedWrongCountTracker = try? JSONDecoder().decode([String: Int].self, from: savedWrongCountTracker) {
                wrongCountTracker = decodedWrongCountTracker
            }
        }
    }
} 