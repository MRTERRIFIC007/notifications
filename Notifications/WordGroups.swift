//
//  WordGroups.swift
//  Notifications
//
//  Created for GRE Vocabulary App
//

import Foundation

// MARK: - Word Group Structure
struct WordGroup: Codable {
    let groupId: Int
    let groupName: String
    let words: [String]
    let difficulty: GroupDifficulty
    var isCompleted: Bool = false
    var lastStudied: Date?
    
    enum CodingKeys: String, CodingKey {
        case groupId, groupName, words, difficulty, isCompleted, lastStudied
    }
}

// MARK: - Group Difficulty Levels
enum GroupDifficulty: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var description: String {
        switch self {
        case .beginner:
            return "Common GRE words for beginners"
        case .intermediate:
            return "Moderately challenging GRE vocabulary"
        case .advanced:
            return "Advanced GRE vocabulary for high scores"
        case .expert:
            return "Expert-level words for top percentile scores"
        }
    }
}

// MARK: - Word Group Service
class WordGroupService {
    static let shared = WordGroupService()
    
    private var wordGroups: [WordGroup] = []
    private var isInitialized = false
    
    private init() {
        loadWordGroups()
    }
    
    // MARK: - Public Methods
    
    /// Get all word groups
    func getAllWordGroups() -> [WordGroup] {
        if !isInitialized {
            createWordGroups()
        }
        return wordGroups
    }
    
    /// Get word groups by difficulty
    func getWordGroups(byDifficulty difficulty: GroupDifficulty) -> [WordGroup] {
        if !isInitialized {
            createWordGroups()
        }
        return wordGroups.filter { $0.difficulty == difficulty }
    }
    
    /// Get a specific word group by ID
    func getWordGroup(byId id: Int) -> WordGroup? {
        if !isInitialized {
            createWordGroups()
        }
        return wordGroups.first { $0.groupId == id }
    }
    
    /// Get the next incomplete group
    func getNextIncompleteGroup() -> WordGroup? {
        if !isInitialized {
            createWordGroups()
        }
        return wordGroups.first { !$0.isCompleted }
    }
    
    /// Mark a group as completed
    func markGroupAsCompleted(groupId: Int) {
        if let index = wordGroups.firstIndex(where: { $0.groupId == groupId }) {
            wordGroups[index].isCompleted = true
            wordGroups[index].lastStudied = Date()
            saveWordGroups()
        }
    }
    
    /// Reset a group's completion status
    func resetGroup(groupId: Int) {
        if let index = wordGroups.firstIndex(where: { $0.groupId == groupId }) {
            wordGroups[index].isCompleted = false
            saveWordGroups()
        }
    }
    
    /// Get words from a specific group
    func getWordsFromGroup(groupId: Int) -> [String]? {
        return getWordGroup(byId: groupId)?.words
    }
    
    /// Get Word objects for a specific group
    func getWordObjectsForGroup(groupId: Int) -> [Word]? {
        guard let wordStrings = getWordsFromGroup(groupId: groupId) else {
            return nil
        }
        
        guard let allWords = WordService.shared.loadWords() else {
            return nil
        }
        
        // Filter the words that belong to this group
        return allWords.filter { wordStrings.contains($0.word) }
    }
    
    /// Get completion progress (percentage of completed groups)
    func getCompletionProgress() -> Double {
        let completedCount = wordGroups.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(wordGroups.count)
    }
    
    // MARK: - Private Methods
    
    /// Create word groups from the word list
    private func createWordGroups() {
        guard let allWords = WordService.shared.loadWords() else {
            print("Failed to load words")
            return
        }
        
        // Extract just the word strings
        let wordStrings = allWords.map { $0.word }
        
        // Calculate how many groups we need (15 words per group)
        let groupSize = 15
        let numberOfGroups = Int(ceil(Double(wordStrings.count) / Double(groupSize)))
        
        // Create the groups
        var newGroups: [WordGroup] = []
        
        for i in 0..<numberOfGroups {
            let startIndex = i * groupSize
            let endIndex = min(startIndex + groupSize, wordStrings.count)
            let groupWords = Array(wordStrings[startIndex..<endIndex])
            
            // Determine difficulty based on group number
            let difficulty: GroupDifficulty
            if i < numberOfGroups / 4 {
                difficulty = .beginner
            } else if i < numberOfGroups / 2 {
                difficulty = .intermediate
            } else if i < (numberOfGroups * 3) / 4 {
                difficulty = .advanced
            } else {
                difficulty = .expert
            }
            
            let group = WordGroup(
                groupId: i + 1,
                groupName: "Group \(i + 1)",
                words: groupWords,
                difficulty: difficulty,
                isCompleted: false,
                lastStudied: nil
            )
            
            newGroups.append(group)
        }
        
        // Save the newly created groups
        wordGroups = newGroups
        isInitialized = true
        saveWordGroups()
    }
    
    /// Load word groups from UserDefaults
    private func loadWordGroups() {
        let defaults = UserDefaults.standard
        
        if let savedGroups = defaults.object(forKey: "wordGroups") as? Data {
            if let decodedGroups = try? JSONDecoder().decode([WordGroup].self, from: savedGroups) {
                wordGroups = decodedGroups
                isInitialized = true
                return
            }
        }
        
        // If we couldn't load from UserDefaults, create new groups
        createWordGroups()
    }
    
    /// Save word groups to UserDefaults
    private func saveWordGroups() {
        let defaults = UserDefaults.standard
        
        if let encoded = try? JSONEncoder().encode(wordGroups) {
            defaults.set(encoded, forKey: "wordGroups")
        }
    }
}

// MARK: - Extensions for UI
extension WordGroup {
    /// Get progress information for UI display
    var progressInfo: String {
        if let lastStudied = lastStudied {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return isCompleted ? "Completed on \(formatter.string(from: lastStudied))" : "Last studied on \(formatter.string(from: lastStudied))"
        } else {
            return "Not started yet"
        }
    }
    
    /// Get color for UI based on difficulty
    var difficultyColor: String {
        switch difficulty {
        case .beginner:
            return "green"
        case .intermediate:
            return "blue"
        case .advanced:
            return "orange"
        case .expert:
            return "red"
        }
    }
} 