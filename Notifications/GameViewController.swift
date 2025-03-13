//
//  GameViewController.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit

class GameViewController: UIViewController {
    
    // UI Elements
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let progressLabel = UILabel()
    private let backButton = UIButton(type: .system)
    
    // Game state
    private var words: [Word] = []
    private var currentWordIndex = 0
    private let totalWordsToShow = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWords()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Word Label
        wordLabel.font = UIFont.boldSystemFont(ofSize: 32)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordLabel)
        
        // Meaning Label
        meaningLabel.font = UIFont.systemFont(ofSize: 20)
        meaningLabel.textAlignment = .center
        meaningLabel.numberOfLines = 0
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(meaningLabel)
        
        // Next Button
        nextButton.setTitle("Next Word", for: .normal)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 10
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        // Progress Label
        progressLabel.font = UIFont.systemFont(ofSize: 16)
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)
        
        // Back Button
        backButton.setTitle("Back to Home", for: .normal)
        backButton.backgroundColor = .systemGray
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 40),
            meaningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            meaningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressLabel.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 60),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 40),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.topAnchor.constraint(equalTo: nextButton.bottomAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadWords() {
        // Use concise definitions for the game
        if let randomWords = WordService.shared.getRandomWords(count: totalWordsToShow, style: .concise) {
            words = randomWords
            displayCurrentWord()
        } else {
            // Show error alert if words can't be loaded
            let alert = UIAlertController(title: "Error", message: "Could not load words. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                self?.dismiss(animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    private func displayCurrentWord() {
        guard currentWordIndex < words.count else {
            // Game completed
            wordLabel.text = "Game Completed!"
            meaningLabel.text = "You've learned \(totalWordsToShow) new words."
            progressLabel.text = "10/10"
            nextButton.setTitle("Take Quiz", for: .normal)
            return
        }
        
        let currentWord = words[currentWordIndex]
        wordLabel.text = currentWord.word
        meaningLabel.text = currentWord.meaning
        progressLabel.text = "Word \(currentWordIndex + 1) of \(totalWordsToShow)"
    }
    
    @objc private func nextButtonTapped() {
        if currentWordIndex >= words.count {
            // Start quiz instead of restarting game
            startQuiz()
        } else {
            // Show next word
            currentWordIndex += 1
            displayCurrentWord()
        }
    }
    
    private func startQuiz() {
        let quizVC = QuizViewController(words: words)
        quizVC.modalPresentationStyle = .fullScreen
        
        // Set a completion handler to track quiz results
        quizVC.quizCompletionHandler = { (score, totalQuestions) in
            // If the user got all questions right, no need to do anything
            if score == totalQuestions {
                return
            }
            
            // Otherwise, some words were answered incorrectly
            // We'll handle this in the QuizViewController directly
        }
        
        present(quizVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
} 