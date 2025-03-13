//
//  FastestFingerQuizViewController.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit

class FastestFingerQuizViewController: UIViewController {
    
    // UI Elements
    private let wordLabel = UILabel()
    private let optionsStackView = UIStackView()
    private let progressLabel = UILabel()
    private let scoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let finishButton = UIButton(type: .system)
    
    // Quiz state
    private var words: [Word] = []
    private var currentQuestionIndex = 0
    private var score = 0
    private var optionButtons: [UIButton] = []
    private var allWords: [Word] = []
    private let totalQuestions = 10
    private var timer: Timer?
    private var timeRemaining: Double = 4.0
    private var hasAnswered = false
    
    // Initialize with random words
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Fastest Finger Quiz"
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
        
        // Timer Label
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .systemRed
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)
        
        // Options Stack View
        optionsStackView.axis = .vertical
        optionsStackView.distribution = .fillEqually
        optionsStackView.spacing = 8
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
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            
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
        finishButton.setTitle("End Quiz", for: .normal)
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
            
            wordLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            timerLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 10),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            optionsStackView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 20),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            finishButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadWords() {
        // Use concise definitions for the quiz
        if let allAvailableWords = WordService.shared.loadWords(style: .concise) {
            self.allWords = allAvailableWords
            
            // Get random words for the quiz
            let randomWords = WordService.shared.getRandomWords(count: totalQuestions, style: .concise) ?? []
            if randomWords.isEmpty {
                showErrorAlert()
                return
            }
            
            self.words = randomWords
            
            // Make sure we have words before showing the first question
            if !self.words.isEmpty && !self.allWords.isEmpty {
                // Add a slight delay to ensure UI is ready before showing the first question
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.showNextQuestion()
                    // Force UI update
                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                }
            } else {
                showErrorAlert()
            }
        } else {
            showErrorAlert()
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Could not load words. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }))
        present(alert, animated: true)
    }
    
    private func showNextQuestion() {
        // Check if we've gone through all questions
        if currentQuestionIndex >= totalQuestions {
            showQuizResults()
            return
        }
        
        // Reset state for new question
        hasAnswered = false
        timeRemaining = 4.0
        
        // Get current word
        let currentWord = words[currentQuestionIndex]
        wordLabel.text = currentWord.word
        
        // Update progress
        progressLabel.text = "Question \(currentQuestionIndex + 1) of \(totalQuestions)"
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
        
        // Start timer
        startTimer()
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
                "The opposite meaning",
                "Unrelated concept",
                "Different context entirely"
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
    
    private func startTimer() {
        // Update timer label
        updateTimerLabel()
        
        // Create and start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 0.1
            self.updateTimerLabel()
            
            if self.timeRemaining <= 0 {
                self.timeExpired()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimerLabel() {
        timerLabel.text = String(format: "%.1f", max(0, timeRemaining))
        
        // Change color based on time remaining
        if timeRemaining < 1.3 {
            timerLabel.textColor = .systemRed
        } else if timeRemaining < 2.6 {
            timerLabel.textColor = .systemOrange
        } else {
            timerLabel.textColor = .systemGreen
        }
    }
    
    private func timeExpired() {
        stopTimer()
        
        if !hasAnswered {
            // Mark the current word as wrong since time expired
            let currentWord = words[currentQuestionIndex].word
            PersonalizedQuizService.shared.markWordAsWrong(currentWord)
            
            // Highlight the correct answer
            for button in optionButtons {
                if button.accessibilityIdentifier == "correct" {
                    button.backgroundColor = .systemGreen
                    break
                }
            }
            
            // Disable all buttons
            for button in optionButtons {
                button.isEnabled = false
            }
            
            // Move to next question after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex += 1
                self.showNextQuestion()
            }
        }
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        guard !hasAnswered else { return }
        
        hasAnswered = true
        stopTimer()
        
        // Check if the selected option is correct
        let isCorrect = sender.accessibilityIdentifier == "correct"
        
        // Get the current word
        let currentWord = words[currentQuestionIndex].word
        
        // Update personalized quiz tracking
        if isCorrect {
            PersonalizedQuizService.shared.markWordAsCorrect(currentWord)
        } else {
            PersonalizedQuizService.shared.markWordAsWrong(currentWord)
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
        
        // Move to next question after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex += 1
            self.showNextQuestion()
        }
    }
    
    private func showQuizResults() {
        // Clear the UI
        wordLabel.text = "Quiz Completed!"
        timerLabel.text = ""
        
        // Hide options
        optionsStackView.isHidden = true
        
        // Show final score
        progressLabel.text = "Final Score"
        scoreLabel.text = "\(score) out of \(totalQuestions) correct"
        
        // Change finish button to "Return to Home"
        finishButton.setTitle("Return to Home", for: .normal)
        finishButton.backgroundColor = .systemBlue
    }
    
    @objc private func finishButtonTapped() {
        stopTimer()
        dismiss(animated: true)
    }
} 