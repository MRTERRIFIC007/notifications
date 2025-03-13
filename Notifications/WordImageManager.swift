import Foundation
import UIKit

class WordImageManager {
    
    // Singleton instance
    static let shared = WordImageManager()
    
    // Dictionary to store word-to-image mapping
    private var wordImageMapping: [String: String] = [:]
    
    // Default image to use when no image is found
    private let defaultImage = UIImage(named: "default")
    
    private init() {
        loadWordImageMapping()
    }
    
    /// Load the word-to-image mapping from the JSON file
    private func loadWordImageMapping() {
        guard let url = Bundle.main.url(forResource: "word_image_mapping", withExtension: "json") else {
            print("Error: Could not find word_image_mapping.json in the bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            wordImageMapping = try JSONDecoder().decode([String: String].self, from: data)
            print("Loaded image mapping for \(wordImageMapping.count) words")
        } catch {
            print("Error loading word image mapping: \(error)")
        }
    }
    
    /// Get the image for a given word
    /// - Parameter word: The word to get the image for
    /// - Returns: The image for the word, or a default image if not found
    func getImage(for word: String) -> UIImage {
        // Normalize the word (lowercase, trim)
        let normalizedWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if we have an image for this word
        if let imageName = wordImageMapping[normalizedWord] {
            // Try to load the image from the bundle
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        
        // Return default image if no image found
        return defaultImage ?? UIImage()
    }
    
    /// Check if a word has an associated image
    /// - Parameter word: The word to check
    /// - Returns: True if the word has an image, false otherwise
    func hasImage(for word: String) -> Bool {
        let normalizedWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return wordImageMapping[normalizedWord] != nil
    }
}

// Extension on Word model to easily get the image
extension Word {
    var image: UIImage {
        return WordImageManager.shared.getImage(for: word)
    }
    
    var hasImage: Bool {
        return WordImageManager.shared.hasImage(for: word)
    }
} 