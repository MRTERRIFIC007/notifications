//
//  WordDetailViewController.swift
//  Notifications
//
//  Created by Om Roy on 02/03/25.
//

import UIKit

class WordDetailViewController: UIViewController {
    
    // UI Elements
    private let wordImageView = UIImageView()
    private let wordLabel = UILabel()
    private let meaningTitleLabel = UILabel()
    private let meaningLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let practiceButton = UIButton(type: .system)
    private let containerView = UIView()
    
    // Data
    private let word: Word
    
    // Initialize with a word
    init(word: Word) {
        self.word = word
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayWordDetails()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        // Container View
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Word Image View
        wordImageView.contentMode = .scaleAspectFit
        wordImageView.backgroundColor = .systemGray6
        wordImageView.layer.cornerRadius = 10
        wordImageView.clipsToBounds = true
        wordImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(wordImageView)
        
        // Word Label
        wordLabel.font = UIFont.boldSystemFont(ofSize: 28)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(wordLabel)
        
        // Meaning Title Label
        meaningTitleLabel.text = "Meaning:"
        meaningTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        meaningTitleLabel.textColor = .systemBlue
        meaningTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(meaningTitleLabel)
        
        // Meaning Label
        meaningLabel.font = UIFont.systemFont(ofSize: 18)
        meaningLabel.textAlignment = .left
        meaningLabel.numberOfLines = 0
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(meaningLabel)
        
        // Close Button
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .systemRed
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(closeButton)
        
        // Practice Button
        practiceButton.setTitle("Practice This Word", for: .normal)
        practiceButton.backgroundColor = .systemGreen
        practiceButton.setTitleColor(.white, for: .normal)
        practiceButton.layer.cornerRadius = 10
        practiceButton.addTarget(self, action: #selector(practiceButtonTapped), for: .touchUpInside)
        practiceButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(practiceButton)
        
        // Add tap gesture to dismiss when tapping outside the container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            wordImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            wordImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            wordImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            wordImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.4),
            
            wordLabel.topAnchor.constraint(equalTo: wordImageView.bottomAnchor, constant: 20),
            wordLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            meaningTitleLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 15),
            meaningTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            meaningLabel.topAnchor.constraint(equalTo: meaningTitleLabel.bottomAnchor, constant: 5),
            meaningLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            meaningLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            practiceButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -10),
            practiceButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            practiceButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            practiceButton.heightAnchor.constraint(equalToConstant: 50),
            
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func displayWordDetails() {
        // Set word and meaning
        wordLabel.text = word.word
        meaningLabel.text = word.meaning
        
        // Set image
        wordImageView.image = word.image
        
        // Check if the word is in practice list
        let isInPractice = PersonalizedQuizService.shared.getWrongWordsForQuiz().contains(word.word)
        
        // Update practice button state
        if isInPractice {
            practiceButton.setTitle("Already in Practice List", for: .normal)
            practiceButton.backgroundColor = .systemGray
            practiceButton.isEnabled = false
        } else {
            practiceButton.setTitle("Add to Practice List", for: .normal)
            practiceButton.backgroundColor = .systemGreen
            practiceButton.isEnabled = true
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func practiceButtonTapped() {
        // Add the word to the practice list
        PersonalizedQuizService.shared.addWordBackToPractice(word.word)
        
        // Update button state
        practiceButton.setTitle("Added to Practice List", for: .normal)
        practiceButton.backgroundColor = .systemGray
        practiceButton.isEnabled = false
        
        // Show confirmation
        let alert = UIAlertController(
            title: "Added to Practice",
            message: "This word has been added to your practice list. It will appear in your personalized quizzes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func handleTapOutside(sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
} 