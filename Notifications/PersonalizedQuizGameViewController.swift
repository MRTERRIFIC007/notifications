//
//  PersonalizedQuizGameViewController.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit

class PersonalizedQuizGameViewController: UIViewController {
    
    // UI Elements
    private let wordLabel = UILabel()
    private let optionsStackView = UIStackView()
    private let progressLabel = UILabel()
    private let scoreLabel = UILabel()
    private let finishButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let streakLabel = UILabel()
    
    // Quiz State
    private var words: [Word] = []
    private var currentQuestionIndex = 0
    private var score = 0
    private var optionButtons: [UIButton] = []
    private var allWords: [Word] = []
    private var totalQuestions = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWords()
        
        // Post notification for styling
        NotificationCenter.default.post(
            name: NSNotification.Name("QuizViewDidLoadNotification"),
            object: self
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label
        titleLabel.text = "Practice Quiz"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Word Label
        wordLabel.font = UIFont.boldSystemFont(ofSize: 32)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordLabel)
        
        // Streak Label
        streakLabel.font = UIFont.systemFont(ofSize: 14)
        streakLabel.textAlignment = .center
        streakLabel.textColor = .systemGray
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(streakLabel)
        
        // Options Stack View
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 16
        optionsStackView.distribution = .fillEqually
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionsStackView)
        
        // Create option buttons
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.backgroundColor = .systemGray6
            button.setTitleColor(.label, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.layer.cornerRadius = 10
            button.tag = i
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            
            // Fix text alignment
            button.contentVerticalAlignment = .center
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
            
            // Use modern configuration API for iOS 15+
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.filled()
                config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                config.background.backgroundColor = .systemGray6
                config.baseForegroundColor = .label
                button.configuration = config
            } else {
                // Fallback for older iOS versions
                button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            }
            
            // Set content priorities to ensure proper layout
            button.titleLabel?.setContentHuggingPriority(.required, for: .vertical)
            button.titleLabel?.setContentCompressionResistancePriority(.required, for: .vertical)
            
            optionButtons.append(button)
            optionsStackView.addArrangedSubview(button)
            
            // Increase height for better text display
            button.heightAnchor.constraint(equalToConstant: 80).isActive = true
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
        finishButton.setTitle("Finish", for: .normal)
        finishButton.backgroundColor = .systemRed
        finishButton.setTitleColor(.white, for: .normal)
        finishButton.layer.cornerRadius = 10
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.isHidden = true
        view.addSubview(finishButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            wordLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            streakLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 8),
            streakLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            streakLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            optionsStackView.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 40),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 30),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            finishButton.widthAnchor.constraint(equalToConstant: 200),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadWords() {
        // Get words that need practice
        let practiceWordStrings = PersonalizedQuizService.shared.getWrongWordsForQuiz()
        
        // If we don't have enough words, show an alert
        if practiceWordStrings.isEmpty {
            let alert = UIAlertController(
                title: "Not Enough Words",
                message: "You don't have any words to practice yet. Take more quizzes and get some words wrong first!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
            return
        }
        
        // Load all words to get the full Word objects
        guard let allLoadedWords = WordService.shared.loadWords(style: .concise) else {
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to load words. Please try again later.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
            return
        }
        
        // Filter to get only the words that are in our practice list
        words = allLoadedWords.filter { practiceWordStrings.contains($0.word) }
        
        // Shuffle the words
        words.shuffle()
        
        // Set total questions
        totalQuestions = min(10, words.count)
        
        // Load all words for distractors
        loadAllWordsForDistractors()
    }
    
    private func loadAllWordsForDistractors() {
        // Load all words to use as distractors
        guard let loadedWords = WordService.shared.loadWords(style: .concise) else {
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to load words for quiz options. Please try again later.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
            return
        }
        
        allWords = loadedWords
        
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
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to load words for quiz. Please try again later.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
    }
    
    private func showNextQuestion() {
        // Check if we've reached the end of the quiz
        if currentQuestionIndex >= totalQuestions {
            showQuizResults()
            return
        }
        
        // Get the current word
        let currentWord = words[currentQuestionIndex]
        
        // Update the word label
        wordLabel.text = currentWord.word
        
        // Update streak label
        let streak = PersonalizedQuizService.shared.getStreakForWord(currentWord.word)
        streakLabel.text = "Current streak: \(streak)/3"
        
        // Generate options
        let options = generateOptions(for: currentWord)
        
        // Update option buttons
        for (index, option) in options.enumerated() {
            optionButtons[index].setTitle(option, for: .normal)
            optionButtons[index].backgroundColor = .systemGray6
            optionButtons[index].isEnabled = true
        }
        
        // Ensure all buttons have text
        for button in optionButtons {
            if button.title(for: .normal)?.isEmpty ?? true {
                button.setTitle("Option text not available", for: .normal)
            }
            
            // Force layout update for proper text display
            button.titleLabel?.preferredMaxLayoutWidth = button.bounds.width - 32
            button.layoutIfNeeded()
        }
        
        // Force UI update
        optionsStackView.setNeedsLayout()
        optionsStackView.layoutIfNeeded()
        
        // Ensure the view updates completely
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        // Update progress label
        progressLabel.text = "Question \(currentQuestionIndex + 1) of \(totalQuestions)"
        
        // Update score label
        scoreLabel.text = "Score: \(score)/\(totalQuestions)"
    }
    
    private func generateOptions(for word: Word) -> [String] {
        // Create a set to ensure unique options
        var optionsSet = Set<String>()
        
        // Add the correct answer
        optionsSet.insert(word.meaning)
        
        // Add random distractors until we have 4 options
        while optionsSet.count < 4 {
            // Get a random word that's not the current word
            if let randomWord = allWords.filter({ $0.word != word.word }).randomElement() {
                optionsSet.insert(randomWord.meaning)
            }
        }
        
        // Convert to array and shuffle
        return Array(optionsSet).shuffled()
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        // Disable all buttons to prevent multiple selections
        optionButtons.forEach { $0.isEnabled = false }
        
        // Get the current word
        let currentWord = words[currentQuestionIndex]
        
        // Get the selected option
        let selectedOption = sender.title(for: .normal) ?? ""
        
        // Check if the answer is correct
        let isCorrect = selectedOption == currentWord.meaning
        
        // Update the button color based on correctness
        if isCorrect {
            sender.backgroundColor = .systemGreen
            score += 1
            
            // Mark word as correct in the personalized quiz service
            PersonalizedQuizService.shared.markWordAsCorrect(currentWord.word)
        } else {
            sender.backgroundColor = .systemRed
            
            // Find and highlight the correct answer
            for button in optionButtons {
                if button.title(for: .normal) == currentWord.meaning {
                    button.backgroundColor = .systemGreen
                    break
                }
            }
            
            // Reset the word's streak in the personalized quiz service
            PersonalizedQuizService.shared.resetWordStreak(currentWord.word)
        }
        
        // Move to the next question after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.currentQuestionIndex += 1
            self?.showNextQuestion()
        }
    }
    
    private func showQuizResults() {
        // Hide quiz elements
        wordLabel.isHidden = true
        optionsStackView.isHidden = true
        streakLabel.isHidden = true
        
        // Update progress and score labels
        progressLabel.text = "Quiz Complete!"
        scoreLabel.text = "Final Score: \(score)/\(totalQuestions)"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        // Show finish button
        finishButton.isHidden = false
    }
    
    @objc private func finishButtonTapped() {
        dismiss(animated: true)
    }
} 