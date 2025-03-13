//
//  FlashCardViewController.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit

class FlashCardViewController: UIViewController {
    
    // UI Elements
    private let cardImageView = UIImageView()
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let prevButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let cardView = UIView() // Container for the card content
    private let meaningTitleLabel = UILabel() // Label for "Meaning:" title
    private let progressView = UIProgressView()
    private let learnedButton = UIButton(type: .system)
    private let modeSegmentControl = UISegmentedControl(items: ["All Words", "Unlearned Only"])
    private let loadMoreButton = UIButton(type: .system)
    private let restartButton = UIButton(type: .system)
    private let viewLearnedWordsButton = UIButton(type: .system) // New button for viewing learned words
    private let takeQuizButton = UIButton(type: .system) // New button for taking a quiz
    
    // Flash card data
    private var allWords: [Word] = []
    private var displayWords: [Word] = []
    private var currentIndex = 0
    private var learnedWords = Set<String>()
    private var viewedWords = Set<String>() // Track words viewed today
    private var recentlyViewedWords: [String] = [] // Track words in the order they were viewed
    private var isUnlearnedMode = true
    private let batchSize = 10
    private var currentBatch = 1
    private var isLoadingMoreWords = false
    
    // Properties for daily learning
    var wordsToLearn: [String] = []
    var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set modal presentation style to full screen to ensure proper dismissal
        self.modalPresentationStyle = .fullScreen
        
        // Add this line to ensure the view controller can be dismissed properly
        self.isModalInPresentation = false
        
        setupUI()
        loadLearnedWordsFromStorage()
        loadViewedWordsFromStorage() // Load viewed words
        loadWords()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Card View (Container) - Now much larger and more prominent
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // Create a dedicated image container view with clean background
        let imageContainerView = UIView()
        imageContainerView.backgroundColor = .systemGray6
        imageContainerView.layer.cornerRadius = 15
        imageContainerView.clipsToBounds = true
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(imageContainerView)
        
        // Card Image View - with improved setup
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        cardImageView.image = UIImage(named: "default")
        cardImageView.backgroundColor = .clear
        cardImageView.clipsToBounds = true
        imageContainerView.addSubview(cardImageView)
        
        // Word Label - Larger and more prominent
        wordLabel.font = UIFont.boldSystemFont(ofSize: 32)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(wordLabel)
        
        // Meaning Title Label
        meaningTitleLabel.text = "Meaning:"
        meaningTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        meaningTitleLabel.textColor = .systemBlue
        meaningTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(meaningTitleLabel)
        
        // Meaning Label - Larger text
        meaningLabel.font = UIFont.systemFont(ofSize: 22)
        meaningLabel.textAlignment = .center
        meaningLabel.numberOfLines = 0
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(meaningLabel)
        
        // Progress View - More subtle
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        // Mode Segment Control - Moved to bottom for less distraction
        modeSegmentControl.selectedSegmentIndex = 1 // Default to "Unlearned Only"
        modeSegmentControl.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        modeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeSegmentControl)
        
        // Minimal Navigation Controls - Just essential buttons
        
        // Learned Button - Now a heart icon
        learnedButton.setImage(UIImage(systemName: "heart"), for: .normal)
        learnedButton.tintColor = .systemRed
        learnedButton.addTarget(self, action: #selector(learnedButtonTapped), for: .touchUpInside)
        learnedButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(learnedButton)
        
        // Menu Button - To access other features
        let menuButton = UIButton(type: .system)
        menuButton.setImage(UIImage(systemName: "ellipsis.circle.fill"), for: .normal)
        menuButton.tintColor = .systemBlue
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuButton)
        
        // Hide these buttons initially - they'll be shown in the menu
        loadMoreButton.isHidden = true
        restartButton.isHidden = true
        viewLearnedWordsButton.isHidden = true
        takeQuizButton.isHidden = true
        backButton.isHidden = true
        
        // Add swipe gestures for navigation
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        cardView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        cardView.addGestureRecognizer(swipeRight)
        
        // Add tap gesture for navigation by tapping left/right sides of screen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // Setup constraints - Simplified for cleaner UI
        NSLayoutConstraint.activate([
            // Card View - Now much larger
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75), // Much larger
            
            // Image Container View
            imageContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            imageContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            imageContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            imageContainerView.heightAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.5),
            
            // Card Image View
            cardImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            cardImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            cardImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            // Word Label
            wordLabel.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 20),
            wordLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            // Meaning Title Label
            meaningTitleLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 20),
            meaningTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            
            // Meaning Label
            meaningLabel.topAnchor.constraint(equalTo: meaningTitleLabel.bottomAnchor, constant: 10),
            meaningLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            meaningLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            meaningLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -20),
            
            // Progress View - Below card
            progressView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 15),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Learned Button - Top right of card
            learnedButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: -10),
            learnedButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 10),
            learnedButton.widthAnchor.constraint(equalToConstant: 44),
            learnedButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Menu Button - Bottom right
            menuButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            menuButton.widthAnchor.constraint(equalToConstant: 44),
            menuButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Mode Segment Control - Bottom of screen
            modeSegmentControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            modeSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modeSegmentControl.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -20),
        ])
    }
    
    private func loadWords() {
        // If we have specific words to learn, use those
        if !wordsToLearn.isEmpty {
            // Load the specific words
            guard let allLoadedWords = WordService.shared.loadWords() else {
                showAlert(title: "Error", message: "Failed to load words")
                return
            }
            
            // Filter to only include the words we want to learn
            allWords = allLoadedWords.filter { wordsToLearn.contains($0.word) }
            
            // If we couldn't find all the words, log a warning
            if allWords.count < wordsToLearn.count {
                print("Warning: Could not find all specified words to learn")
            }
        } else {
            // Load all words as usual
            guard let loadedWords = WordService.shared.loadWords() else {
                showAlert(title: "Error", message: "Failed to load words")
                return
            }
            allWords = loadedWords
        }
        
        // Shuffle the words for better learning
        allWords = allWords.shuffled()
        
        // Filter and display words
        filterAndDisplayWords()
    }
    
    private func filterAndDisplayWords() {
        if isUnlearnedMode {
            // Filter out learned words
            let unlearnedWords = allWords.filter { !learnedWords.contains($0.word) }
            
            // Take a batch of unlearned words
            let endIndex = min(currentBatch * batchSize, unlearnedWords.count)
            displayWords = Array(unlearnedWords[0..<endIndex])
            
            // Update load more button visibility - now hidden by default
            loadMoreButton.isHidden = true
        } else {
            // Take a batch of all words
            let endIndex = min(currentBatch * batchSize, allWords.count)
            displayWords = Array(allWords[0..<endIndex])
            
            // Update load more button visibility - now hidden by default
            loadMoreButton.isHidden = true
        }
        
        // Reset to first card if needed
        if currentIndex >= displayWords.count {
            currentIndex = max(0, displayWords.count - 1)
        }
        
        // Display current card
        displayCurrentCard()
    }
    
    private func displayCurrentCard() {
        // Update progress
        let progress = displayWords.isEmpty ? 0.0 : Float(currentIndex + 1) / Float(displayWords.count)
        progressView.setProgress(progress, animated: true)
        
        guard !displayWords.isEmpty else {
            // No words to display
            wordLabel.text = "No Words Available"
            meaningTitleLabel.isHidden = true
            meaningLabel.text = isUnlearnedMode ? 
                "You've learned all available words! Switch to 'All Words' mode to review." : 
                "No words available. Please try again later."
            cardImageView.image = UIImage(named: "default")
            learnedButton.isHidden = true
            return
        }
        
        guard currentIndex < displayWords.count else {
            // All cards viewed
            wordLabel.text = "All Cards Viewed!"
            meaningTitleLabel.isHidden = true
            
            // Check if we've reached the end of all available words
            let hasMoreWords = shouldLoadMoreWords()
            
            if hasMoreWords {
                meaningLabel.text = "Loading more words..."
                // Automatically load more words
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.loadMoreWords()
                }
            } else {
                meaningLabel.text = "You've reviewed all available flash cards. Restart to shuffle and view again."
            }
            
            cardImageView.image = UIImage(named: "default")
            learnedButton.isHidden = true
            return
        }
        
        let currentWord = displayWords[currentIndex]
        wordLabel.text = currentWord.word
        meaningTitleLabel.isHidden = false
        meaningLabel.text = currentWord.meaning
        
        // Use WordImageManager to get the image for the current word
        cardImageView.image = WordImageManager.shared.getImage(for: currentWord.word)
        
        // Mark this word as viewed today
        viewedWords.insert(currentWord.word)
        
        // Add to recently viewed words list (remove if already exists to avoid duplicates)
        if let existingIndex = recentlyViewedWords.firstIndex(of: currentWord.word) {
            recentlyViewedWords.remove(at: existingIndex)
        }
        recentlyViewedWords.append(currentWord.word)
        
        saveViewedWordsToStorage()
        
        // Update learned button state
        let isLearned = learnedWords.contains(currentWord.word)
        learnedButton.isHidden = false
        learnedButton.setImage(UIImage(systemName: isLearned ? "heart.fill" : "heart"), for: .normal)
        learnedButton.tintColor = isLearned ? .systemRed : .systemGray
        
        // Add a subtle animation when displaying a new card
        cardView.alpha = 0.7
        UIView.animate(withDuration: 0.3) {
            self.cardView.alpha = 1.0
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // Swipe left to go to next card
            if currentIndex < displayWords.count - 1 {
                nextButtonTapped()
            }
        } else if gesture.direction == .right {
            // Swipe right to go to previous card
            if currentIndex > 0 {
                prevButtonTapped()
            }
        }
    }
    
    @objc private func nextButtonTapped() {
        guard currentIndex < displayWords.count - 1 else { 
            // If we're at the last card, try to load more words automatically
            if shouldLoadMoreWords() {
                loadMoreWords()
                return
            }
            return 
        }
        
        currentIndex += 1
        
        // Animate card transition
        UIView.transition(with: cardView, duration: 0.4, options: .transitionFlipFromRight, animations: {
            // This will be executed during the animation
        }, completion: { _ in
            // This will be executed after the animation completes
            self.displayCurrentCard()
            
            // Check if we're approaching the end of the batch and preload more words
            if self.currentIndex >= self.displayWords.count - 2 {
                self.preloadMoreWordsIfNeeded()
            }
        })
    }
    
    // Helper method to check if we should load more words
    private func shouldLoadMoreWords() -> Bool {
        if isUnlearnedMode {
            let unlearnedWords = allWords.filter { !learnedWords.contains($0.word) }
            return currentBatch * batchSize < unlearnedWords.count
        } else {
            return currentBatch * batchSize < allWords.count
        }
    }
    
    // Preload more words when approaching the end of the batch
    private func preloadMoreWordsIfNeeded() {
        if shouldLoadMoreWords() && !isLoadingMoreWords {
            isLoadingMoreWords = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loadMoreWords()
            }
        }
    }
    
    // Load more words and continue from the current position
    private func loadMoreWords() {
        currentBatch += 1
        let oldCount = displayWords.count
        
        // If we're loading a new batch and have gone through most of the words,
        // reshuffle the remaining words to ensure variety
        if currentBatch > 1 && currentIndex > oldCount / 2 {
            // Get the words we haven't displayed yet
            let remainingWords: [Word]
            if isUnlearnedMode {
                let unlearnedWords = allWords.filter { !learnedWords.contains($0.word) }
                let displayedCount = min((currentBatch - 1) * batchSize, unlearnedWords.count)
                remainingWords = Array(unlearnedWords[displayedCount..<unlearnedWords.count])
            } else {
                let displayedCount = min((currentBatch - 1) * batchSize, allWords.count)
                remainingWords = Array(allWords[displayedCount..<allWords.count])
            }
            
            // Shuffle the remaining words
            let shuffledRemaining = remainingWords.shuffled()
            
            // Replace the remaining words in the allWords array
            if isUnlearnedMode {
                let unlearnedWords = allWords.filter { !learnedWords.contains($0.word) }
                let displayedCount = min((currentBatch - 1) * batchSize, unlearnedWords.count)
                
                // Create a new array with displayed words + shuffled remaining words
                var newUnlearnedWords = Array(unlearnedWords[0..<displayedCount])
                newUnlearnedWords.append(contentsOf: shuffledRemaining)
                
                // Update allWords to maintain the learned words in their positions
                var index = 0
                allWords = allWords.map { word in
                    if learnedWords.contains(word.word) {
                        return word
                    } else if index < newUnlearnedWords.count {
                        let newWord = newUnlearnedWords[index]
                        index += 1
                        return newWord
                    } else {
                        return word
                    }
                }
            } else {
                let displayedCount = min((currentBatch - 1) * batchSize, allWords.count)
                
                // Replace the remaining words with shuffled ones
                var newAllWords = Array(allWords[0..<displayedCount])
                newAllWords.append(contentsOf: shuffledRemaining)
                allWords = newAllWords
            }
        }
        
        filterAndDisplayWords()
        isLoadingMoreWords = false
        
        // If we were at the end of the previous batch, move to the next card
        if currentIndex == oldCount - 1 && oldCount < displayWords.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.nextButtonTapped()
            }
        }
    }
    
    @objc private func prevButtonTapped() {
        guard currentIndex > 0 else { return }
        
        currentIndex -= 1
        
        // Animate card transition
        UIView.transition(with: cardView, duration: 0.4, options: .transitionFlipFromLeft, animations: {
            // This will be executed during the animation
        }, completion: { _ in
            // This will be executed after the animation completes
            self.displayCurrentCard()
        })
    }
    
    @objc private func learnedButtonTapped() {
        guard !displayWords.isEmpty && currentIndex < displayWords.count else { return }
        
        let currentWord = displayWords[currentIndex].word
        
        if learnedWords.contains(currentWord) {
            // Remove from learned words
            learnedWords.remove(currentWord)
        } else {
            // Add to learned words
            learnedWords.insert(currentWord)
        }
        
        // Save learned words to storage
        saveLearnedWordsToStorage()
        
        // Update UI
        displayCurrentCard()
        
        // If in unlearned mode and marked as learned, move to next card
        if isUnlearnedMode && learnedWords.contains(currentWord) {
            // If this is the last card, go to previous card
            if currentIndex == displayWords.count - 1 && currentIndex > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.prevButtonTapped()
                }
            } else if currentIndex < displayWords.count - 1 {
                // Otherwise go to next card
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.nextButtonTapped()
                }
            } else {
                // Refresh the display words
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.filterAndDisplayWords()
                }
            }
        }
    }
    
    @objc private func loadMoreButtonTapped() {
        loadMoreWords()
    }
    
    @objc private func modeChanged(_ sender: UISegmentedControl) {
        isUnlearnedMode = sender.selectedSegmentIndex == 1
        currentBatch = 1 // Reset to first batch
        currentIndex = 0 // Reset to first card
        allWords = allWords.shuffled() // Reshuffle words when mode changes
        filterAndDisplayWords()
    }
    
    @objc private func backButtonTapped() {
        // Save any pending changes
        saveLearnedWordsToStorage()
        
        // Call completion handler if it exists
        completionHandler?()
        
        // Improved dismissal logic
        if let presentingVC = self.presentingViewController {
            // Ensure we're using the correct presentation context
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            // Fallback to direct dismissal
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func restartButtonTapped() {
        // Reshuffle all words and start over
        allWords = allWords.shuffled()
        currentBatch = 1
        currentIndex = 0
        filterAndDisplayWords()
        
        // Animate the transition
        UIView.transition(with: cardView, duration: 0.6, options: .transitionCurlDown, animations: {
            // Animation will happen automatically
        }, completion: nil)
    }
    
    // MARK: - New Methods for Learned Words and Quiz
    
    @objc private func viewLearnedWordsButtonTapped() {
        let learnedWordsVC = LearnedWordsViewController(learnedWords: Array(learnedWords))
        learnedWordsVC.modalPresentationStyle = .fullScreen
        present(learnedWordsVC, animated: true)
    }
    
    @objc private func takeQuizButtonTapped() {
        // Check if we have enough viewed words for a quiz
        if recentlyViewedWords.count < 5 {
            let alert = UIAlertController(
                title: "Not Enough Words",
                message: "You need to view at least 5 words to take the quiz. You've viewed \(recentlyViewedWords.count) so far.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Take up to 10 most recently viewed words for the quiz (instead of just 5)
        let maxQuizWords = min(10, recentlyViewedWords.count)
        let quizWords = Array(recentlyViewedWords.suffix(maxQuizWords))
        
        // Load the full word objects for the quiz
        guard let allWordsFromService = WordService.shared.loadWords(style: .flashcard) else {
            let alert = UIAlertController(title: "Error", message: "Failed to load words for quiz", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Filter to get only the words we want for the quiz
        let quizWordObjects = allWordsFromService.filter { quizWords.contains($0.word) }
        
        // Create and present the quiz
        let quizVC = QuizViewController(words: quizWordObjects)
        quizVC.title = "Recently Viewed Words Quiz"
        quizVC.modalPresentationStyle = .fullScreen
        
        // Register for quiz styling notification
        QuizStyling.shared.registerForStyling()
        
        // Set completion handler to track wrong answers
        quizVC.completionHandler = { [weak self] (wrongWords: [String]) in
            guard let self = self else { return }
            
            // Add wrong words to the personalized quiz service
            for word in wrongWords {
                PersonalizedQuizService.shared.markWordAsWrong(word)
            }
            
            // Show results with enhanced UI
            self.showQuizResults(quizWordObjects: quizWordObjects, wrongWords: wrongWords)
        }
        
        // Present with a cool transition
        quizVC.modalTransitionStyle = .flipHorizontal
        present(quizVC, animated: true)
    }
    
    // Show quiz results with enhanced UI
    private func showQuizResults(quizWordObjects: [Word], wrongWords: [String]) {
        if wrongWords.isEmpty {
            // Perfect score animation and alert
            let alert = UIAlertController(
                title: "🎉 Perfect Score! 🎉",
                message: "Congratulations! You got all \(quizWordObjects.count) words correct.",
                preferredStyle: .alert
            )
            
            // Add a fun confetti animation or sound here if desired
            
            alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
            present(alert, animated: true)
        } else {
            // Create a more detailed results view
            let correctCount = quizWordObjects.count - wrongWords.count
            let percentage = Int((Double(correctCount) / Double(quizWordObjects.count)) * 100)
            
            var message = "You got \(correctCount) out of \(quizWordObjects.count) correct (\(percentage)%).\n\n"
            
            if !wrongWords.isEmpty {
                message += "Words to practice:\n"
                for word in wrongWords {
                    message += "• \(word)\n"
                }
                message += "\nThese words have been added to your practice list."
            }
            
            let alert = UIAlertController(
                title: percentage >= 80 ? "Great Job! 👍" : "Keep Practicing! 📚",
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func menuButtonTapped() {
        // Create an action sheet with all the secondary options
        let actionSheet = UIAlertController(title: "Flash Card Options", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "View Learned Words", style: .default) { [weak self] _ in
            self?.viewLearnedWordsButtonTapped()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Take Quiz", style: .default) { [weak self] _ in
            self?.takeQuizButtonTapped()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Restart with New Shuffle", style: .default) { [weak self] _ in
            self?.restartButtonTapped()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Back to Home", style: .destructive) { [weak self] _ in
            self?.backButtonTapped()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    @objc private func handleScreenTap(_ gesture: UITapGestureRecognizer) {
        // Get the tap location
        let location = gesture.location(in: view)
        
        // Determine if tap was on the left or right side of the screen
        let isRightSide = location.x > view.bounds.width / 2
        
        // Ignore taps on UI controls
        if gesture.view != view {
            return
        }
        
        // Navigate based on which side was tapped
        if isRightSide {
            // Right side tap - go to next card
            if currentIndex < displayWords.count - 1 {
                nextButtonTapped()
            }
        } else {
            // Left side tap - go to previous card
            if currentIndex > 0 {
                prevButtonTapped()
            }
        }
    }
    
    private func createSwipeHintView(direction: UISwipeGestureRecognizer.Direction) -> UIView {
        let hintView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        hintView.center = cardView.center
        hintView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        hintView.layer.cornerRadius = 10
        
        let label = UILabel(frame: hintView.bounds)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = direction == .left ? "Swipe left for next card" : "Swipe right for previous card"
        hintView.addSubview(label)
        
        return hintView
    }
    
    // MARK: - Persistence for Viewed Words
    
    private func saveViewedWordsToStorage() {
        let defaults = UserDefaults.standard
        
        // Get the current date as a string for the key
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        // Save viewed words with today's date as part of the key
        defaults.set(Array(viewedWords), forKey: "flashCardViewedWords_\(today)")
        
        // Save recently viewed words in order
        defaults.set(recentlyViewedWords, forKey: "flashCardRecentlyViewedWords_\(today)")
    }
    
    private func loadViewedWordsFromStorage() {
        let defaults = UserDefaults.standard
        
        // Get the current date as a string for the key
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        // Load viewed words for today
        if let savedWords = defaults.array(forKey: "flashCardViewedWords_\(today)") as? [String] {
            viewedWords = Set(savedWords)
        } else {
            viewedWords = Set<String>()
        }
        
        // Load recently viewed words in order
        if let savedRecentWords = defaults.array(forKey: "flashCardRecentlyViewedWords_\(today)") as? [String] {
            recentlyViewedWords = savedRecentWords
        } else {
            recentlyViewedWords = []
        }
    }
    
    // MARK: - Persistence for Learned Words
    
    private func saveLearnedWordsToStorage() {
        let defaults = UserDefaults.standard
        defaults.set(Array(learnedWords), forKey: "flashCardLearnedWords")
    }
    
    private func loadLearnedWordsFromStorage() {
        let defaults = UserDefaults.standard
        if let savedWords = defaults.array(forKey: "flashCardLearnedWords") as? [String] {
            learnedWords = Set(savedWords)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure the navigation controller doesn't interfere with our dismissal
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Make sure the view is properly configured for dismissal
        if #available(iOS 13.0, *) {
            // For iOS 13 and later
            isModalInPresentation = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save any pending changes when view disappears
        saveLearnedWordsToStorage()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Quiz Styling Utility

class QuizStyling {
    static let shared = QuizStyling()
    
    private init() {}
    
    // Register for quiz styling notifications
    func registerForStyling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applyQuizStyling(_:)),
            name: NSNotification.Name("QuizViewDidLoadNotification"),
            object: nil
        )
    }
    
    // Apply styling to any quiz view controller
    @objc private func applyQuizStyling(_ notification: Notification) {
        // Get the quiz view controller from the notification
        guard let quizVC = notification.object as? UIViewController, let view = quizVC.view else { return }
        
        // Apply styling to the view
        styleQuizButtons(in: view)
        styleQuizLabels(in: view)
        styleProgressIndicator(in: view)
        
        // Remove the observer after styling is applied
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("QuizViewDidLoadNotification"),
            object: notification.object
        )
    }
    
    // Helper method to style buttons in the quiz view
    private func styleQuizButtons(in view: UIView) {
        // Find all buttons in the view hierarchy
        view.subviews.forEach { subview in
            if let button = subview as? UIButton {
                // Style only option buttons (not navigation buttons)
                if button.backgroundColor == .systemGray5 || button.backgroundColor == .systemGray6 {
                    // Use modern configuration API for iOS 15+
                    if #available(iOS 15.0, *) {
                        var config = button.configuration ?? UIButton.Configuration.filled()
                        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                        button.configuration = config
                    } else {
                        // Make buttons larger with more padding (for older iOS)
                        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
                    }
                    
                    // Fix vertical alignment issue
                    button.contentVerticalAlignment = .center
                    
                    // Improve text appearance
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
                    button.titleLabel?.numberOfLines = 0 // Allow multiple lines
                    button.titleLabel?.textAlignment = .center
                    button.titleLabel?.lineBreakMode = .byWordWrapping
                    
                    // Set title label to adjust font size if needed
                    button.titleLabel?.adjustsFontSizeToFitWidth = false
                    
                    // Force layout update to ensure proper text positioning
                    if let titleLabel = button.titleLabel {
                        titleLabel.preferredMaxLayoutWidth = button.bounds.width - 32
                        titleLabel.setContentHuggingPriority(.required, for: .vertical)
                        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
                    }
                    
                    // Add a nice background and shadow
                    button.backgroundColor = .systemBackground
                    button.layer.cornerRadius = 12
                    button.layer.shadowColor = UIColor.black.cgColor
                    button.layer.shadowOffset = CGSize(width: 0, height: 2)
                    button.layer.shadowOpacity = 0.2
                    button.layer.shadowRadius = 4
                    
                    // Add a subtle border
                    button.layer.borderWidth = 1
                    button.layer.borderColor = UIColor.systemGray4.cgColor
                    
                    // Force layout update
                    button.layoutIfNeeded()
                }
            }
            
            // Recursively check subviews
            styleQuizButtons(in: subview)
        }
    }
    
    // Helper method to style labels in the quiz view
    private func styleQuizLabels(in view: UIView) {
        view.subviews.forEach { subview in
            if let label = subview as? UILabel {
                // Style the word label (largest font)
                if label.font.pointSize > 30 {
                    label.font = UIFont.boldSystemFont(ofSize: 32)
                    label.textColor = .systemBlue
                    
                    // Add a subtle animation
                    UIView.animate(withDuration: 0.3, animations: {
                        label.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            label.transform = CGAffineTransform.identity
                        }
                    })
                }
                
                // Style title labels
                if label.font.pointSize > 22 && label.font.pointSize < 30 {
                    label.font = UIFont.boldSystemFont(ofSize: 24)
                    label.textColor = .label
                }
                
                // Style progress labels
                if label.text?.contains("Question") == true || label.text?.contains("Score") == true {
                    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                    label.textColor = .systemGray
                }
            }
            
            // Recursively check subviews
            styleQuizLabels(in: subview)
        }
    }
    
    // Helper method to style progress indicators in the quiz view
    private func styleProgressIndicator(in view: UIView) {
        view.subviews.forEach { subview in
            if let progressView = subview as? UIProgressView {
                progressView.progressTintColor = .systemGreen
                progressView.trackTintColor = .systemGray5
                progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0) // Make it taller
            }
            
            // Recursively check subviews
            styleProgressIndicator(in: subview)
        }
    }
} 