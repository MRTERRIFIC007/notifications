//
//  QuizViewController.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit

class QuizViewController: UIViewController {
    
    // UI Elements
    private let wordLabel = UILabel()
    private let optionsStackView = UIStackView()
    private let progressLabel = UILabel()
    private let scoreLabel = UILabel()
    private let finishButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    
    // Quiz state
    var words: [Word] = []
    private var currentQuestionIndex = 0
    private var score = 0
    private var optionButtons: [UIButton] = []
    private var allWords: [Word] = []
    private let totalWordsToShow = 10
    private var isRandomQuiz: Bool
    private var wrongAnswers: [String] = [] // Track wrong answers
    
    // Completion handler to report quiz results
    var quizCompletionHandler: ((Int, Int) -> Void)?
    
    // Completion handler to track wrong answers
    var completionHandler: (([String]) -> Void)?
    
    // Initialize with the words the user has learned or for a random quiz
    init(words: [Word]? = nil, isRandomQuiz: Bool = false) {
        self.isRandomQuiz = isRandomQuiz
        if let providedWords = words {
            self.words = providedWords
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if words.isEmpty {
            // Load random words if no words were provided
            loadWords()
        } else {
            // Load all words to use as distractors
            loadAllWordsForDistractors()
        }
        
        // Post notification that the view has loaded so external styling can be applied
        NotificationCenter.default.post(
            name: NSNotification.Name("QuizViewDidLoadNotification"),
            object: self
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label (for Random Quiz)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.text = isRandomQuiz ? "Random Word Quiz" : "Word Quiz"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Word Label
        wordLabel.font = UIFont.boldSystemFont(ofSize: 32)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordLabel)
        
        // Options Stack View
        optionsStackView.axis = .vertical
        optionsStackView.distribution = .fillEqually
        optionsStackView.spacing = 10
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsStackView)
        
        // Create 4 option buttons
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.backgroundColor = .systemGray5
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.layer.cornerRadius = 10
            button.tag = i
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Increase height for better text display
            button.heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            // Fix text alignment
            button.contentVerticalAlignment = .center
            button.titleLabel?.textAlignment = .center
            
            // Use modern configuration API for iOS 15+
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                config.background.backgroundColor = .systemGray5
                config.baseForegroundColor = .black
                button.configuration = config
            } else {
                // Fallback for older iOS versions
                button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            }
            
            // Set content priorities to ensure proper layout
            button.titleLabel?.setContentHuggingPriority(.required, for: .vertical)
            button.titleLabel?.setContentCompressionResistancePriority(.required, for: .vertical)
            
            optionsStackView.addArrangedSubview(button)
            optionButtons.append(button)
        }
        
        // Progress Label
        progressLabel.font = UIFont.systemFont(ofSize: 16)
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)
        
        // Score Label
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 18)
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // Finish Button
        finishButton.setTitle("Finish Quiz", for: .normal)
        finishButton.backgroundColor = .systemRed
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.layer.cornerRadius = 10
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(finishButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            wordLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            optionsStackView.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 40),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 30),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            finishButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 30),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadWords() {
        // Use concise definitions for the quiz
        if let randomWords = WordService.shared.getRandomWords(count: totalWordsToShow, style: .concise) {
            words = randomWords
            loadAllWordsForDistractors()
        } else {
            // Show error alert if words can't be loaded
            let alert = UIAlertController(title: "Error", message: "Could not load words. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.dismiss(animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    private func loadAllWordsForDistractors() {
        // Load all words to use as distractors
        if let allAvailableWords = WordService.shared.loadWords(style: .concise) {
            self.allWords = allAvailableWords
            
            // Make sure we have words before showing the first question
            if !words.isEmpty && !allWords.isEmpty {
                // Add a slight delay to ensure UI is ready before showing the first question
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.showNextQuestion()
                    // Force UI update
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                }
            } else {
                // Show error alert if words can't be loaded
                let alert = UIAlertController(title: "Error", message: "Not enough words available for the quiz. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true)
                }))
                present(alert, animated: true)
            }
        } else {
            // Show error alert if words can't be loaded
            let alert = UIAlertController(title: "Error", message: "Could not load words for quiz options. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.dismiss(animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    private func showNextQuestion() {
        // Check if we've gone through all questions
        if currentQuestionIndex >= words.count {
            showQuizResults()
            return
        }
        
        // Get current word
        let currentWord = words[currentQuestionIndex]
        wordLabel.text = currentWord.word
        
        // Update progress
        progressLabel.text = "Question \(currentQuestionIndex + 1) of \(words.count)"
        scoreLabel.text = "Score: \(score)/\(currentQuestionIndex)"
        
        // Generate options (1 correct, 3 incorrect)
        generateOptions(for: currentWord)
        
        // Force UI update for proper text layout
        for button in optionButtons {
            button.titleLabel?.preferredMaxLayoutWidth = button.bounds.width - 32
            button.layoutIfNeeded()
        }
        
        optionsStackView.setNeedsLayout()
        optionsStackView.layoutIfNeeded()
        
        // Ensure the view updates completely
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func generateOptions(for correctWord: Word) {
        // Get the correct meaning
        let correctMeaning = correctWord.meaning
        
        // Get 3 random incorrect meanings
        var incorrectMeanings: [String] = []
        var availableWords = allWords.filter { $0.word != correctWord.word }
        
        // Ensure we have enough words for distractors
        if availableWords.count < 3 {
            // If not enough words, create some fake meanings
            incorrectMeanings = [
                "The opposite of what you might think.",
                "A concept related to mathematics or physics.",
                "A term used in ancient literature."
            ]
        } else {
            // Shuffle and take 3 random words
            availableWords.shuffle()
            incorrectMeanings = availableWords.prefix(3).map { $0.meaning }
        }
        
        // Combine correct and incorrect meanings
        var allOptions = [correctMeaning] + incorrectMeanings
        
        // Shuffle options
        allOptions.shuffle()
        
        // Set button titles
        for (index, option) in allOptions.enumerated() {
            optionButtons[index].setTitle(option, for: .normal)
            // Store whether this is the correct answer in the button's accessibilityIdentifier
            optionButtons[index].accessibilityIdentifier = option == correctMeaning ? "correct" : "incorrect"
            // Reset button appearance
            optionButtons[index].backgroundColor = .systemGray5
            optionButtons[index].isEnabled = true
        }
        
        // Ensure all buttons have text
        for button in optionButtons {
            if button.title(for: .normal)?.isEmpty ?? true {
                button.setTitle("Option text not available", for: .normal)
            }
        }
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        // Check if the selected option is correct
        let isCorrect = sender.accessibilityIdentifier == "correct"
        
        // Get the current word
        let currentWord = words[currentQuestionIndex].word
        
        // Update personalized quiz tracking
        if isCorrect {
            PersonalizedQuizService.shared.markWordAsCorrect(currentWord)
        } else {
            PersonalizedQuizService.shared.markWordAsWrong(currentWord)
            // Add to wrong answers list
            wrongAnswers.append(currentWord)
        }
        
        // Update button appearance based on correctness
        if isCorrect {
            sender.backgroundColor = .systemGreen
            score += 1
        } else {
            sender.backgroundColor = .systemRed
            // Highlight the correct answer
            for button in optionButtons {
                if button.accessibilityIdentifier == "correct" {
                    button.backgroundColor = .systemGreen
                    break
                }
            }
        }
        
        // Disable all buttons to prevent multiple selections
        for button in optionButtons {
            button.isEnabled = false
        }
        
        // Move to next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex += 1
            self.showNextQuestion()
        }
    }
    
    private func showQuizResults() {
        // Clear the UI
        wordLabel.text = "Quiz Completed!"
        
        // Hide options
        optionsStackView.isHidden = true
        
        // Show final score
        progressLabel.text = "Final Score"
        scoreLabel.text = "\(score) out of \(words.count) correct"
        
        // Change finish button to "Return to Home"
        finishButton.setTitle("Return to Home", for: .normal)
        finishButton.backgroundColor = .systemBlue
    }
    
    @objc private func finishButtonTapped() {
        // Call completion handler with final score
        quizCompletionHandler?(score, words.count)
        
        // Call completion handler with wrong answers
        completionHandler?(wrongAnswers)
        
        dismiss(animated: true)
    }
} 