//
//  ViewController.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    // UI Elements
    private let titleLabel = UILabel()
    private let intervalTextField = UITextField()
    private let scheduleButton = UIButton(type: .system)
    private let stopNotificationsButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let playGameButton = UIButton(type: .system)
    private let randomQuizButton = UIButton(type: .system)
    private let fastestFingerButton = UIButton(type: .system)
    private let personalizedQuizButton = UIButton(type: .system)
    private let flashCardsButton = UIButton(type: .system)
    private let enhancedFlashCardsButton = UIButton(type: .system)
    private let learningAnalyticsButton = UIButton(type: .system)
    private let wordGroupsButton = UIButton(type: .system)
    
    // Track if keyboard is visible
    private var isKeyboardVisible = false
    private var originalViewFrame: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Register for keyboard notifications with better handling
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Request notification permissions when the app launches
        requestNotificationPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Store original frame for keyboard adjustments
        originalViewFrame = view.frame
    }
    
    deinit {
        // Remove observers when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label
        titleLabel.text = "Word Notifications"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Interval Text Field
        intervalTextField.placeholder = "Enter interval in minutes"
        intervalTextField.borderStyle = .roundedRect
        intervalTextField.keyboardType = .decimalPad
        intervalTextField.translatesAutoresizingMaskIntoConstraints = false
        intervalTextField.delegate = self
        
        // Add toolbar with Done button to dismiss keyboard
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        intervalTextField.inputAccessoryView = toolbar
        
        view.addSubview(intervalTextField)
        
        // Schedule Button
        scheduleButton.setTitle("Schedule Notifications", for: .normal)
        scheduleButton.backgroundColor = .systemBlue
        scheduleButton.setTitleColor(.white, for: .normal)
        scheduleButton.layer.cornerRadius = 10
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scheduleButton)
        
        // Stop Notifications Button
        stopNotificationsButton.setTitle("Stop Notifications", for: .normal)
        stopNotificationsButton.backgroundColor = .systemRed
        stopNotificationsButton.setTitleColor(.white, for: .normal)
        stopNotificationsButton.layer.cornerRadius = 10
        stopNotificationsButton.addTarget(self, action: #selector(stopNotificationsButtonTapped), for: .touchUpInside)
        stopNotificationsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stopNotificationsButton)
        
        // Status Label
        statusLabel.text = "Notifications not scheduled."
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        // Play Game Button
        playGameButton.setTitle("Play Word Game", for: .normal)
        playGameButton.backgroundColor = .systemGreen
        playGameButton.setTitleColor(.white, for: .normal)
        playGameButton.layer.cornerRadius = 10
        playGameButton.addTarget(self, action: #selector(playGameButtonTapped), for: .touchUpInside)
        playGameButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playGameButton)
        
        // Random Quiz Button
        randomQuizButton.setTitle("Take Random Quiz", for: .normal)
        randomQuizButton.backgroundColor = .systemPurple
        randomQuizButton.setTitleColor(.white, for: .normal)
        randomQuizButton.layer.cornerRadius = 10
        randomQuizButton.addTarget(self, action: #selector(randomQuizButtonTapped), for: .touchUpInside)
        randomQuizButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(randomQuizButton)
        
        // Fastest Finger Quiz Button
        fastestFingerButton.setTitle("Fastest Finger Quiz", for: .normal)
        fastestFingerButton.backgroundColor = .systemOrange
        fastestFingerButton.setTitleColor(.white, for: .normal)
        fastestFingerButton.layer.cornerRadius = 10
        fastestFingerButton.addTarget(self, action: #selector(fastestFingerButtonTapped), for: .touchUpInside)
        fastestFingerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fastestFingerButton)
        
        // Personalized Quiz Button
        personalizedQuizButton.setTitle("Wrong Words List", for: .normal)
        personalizedQuizButton.backgroundColor = .systemTeal
        personalizedQuizButton.setTitleColor(.white, for: .normal)
        personalizedQuizButton.layer.cornerRadius = 10
        personalizedQuizButton.addTarget(self, action: #selector(personalizedQuizButtonTapped), for: .touchUpInside)
        personalizedQuizButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(personalizedQuizButton)
        
        // Flash Cards Button
        flashCardsButton.setTitle("Flash Cards", for: .normal)
        flashCardsButton.backgroundColor = .systemIndigo
        flashCardsButton.setTitleColor(.white, for: .normal)
        flashCardsButton.layer.cornerRadius = 10
        flashCardsButton.addTarget(self, action: #selector(flashCardsButtonTapped), for: .touchUpInside)
        flashCardsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flashCardsButton)
        
        // Enhanced Flash Cards Button
        enhancedFlashCardsButton.setTitle("Enhanced Flash Cards", for: .normal)
        enhancedFlashCardsButton.backgroundColor = .systemGreen
        enhancedFlashCardsButton.setTitleColor(.white, for: .normal)
        enhancedFlashCardsButton.layer.cornerRadius = 10
        enhancedFlashCardsButton.addTarget(self, action: #selector(enhancedFlashCardsButtonTapped), for: .touchUpInside)
        enhancedFlashCardsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(enhancedFlashCardsButton)
        
        // Learning Analytics Button
        learningAnalyticsButton.setTitle("Learning Analytics", for: .normal)
        learningAnalyticsButton.backgroundColor = .systemYellow
        learningAnalyticsButton.setTitleColor(.white, for: .normal)
        learningAnalyticsButton.layer.cornerRadius = 10
        learningAnalyticsButton.addTarget(self, action: #selector(learningAnalyticsButtonTapped), for: .touchUpInside)
        learningAnalyticsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(learningAnalyticsButton)
        
        // Word Groups Button
        wordGroupsButton.setTitle("GRE Word Groups", for: .normal)
        wordGroupsButton.backgroundColor = .systemBrown
        wordGroupsButton.setTitleColor(.white, for: .normal)
        wordGroupsButton.layer.cornerRadius = 10
        wordGroupsButton.addTarget(self, action: #selector(wordGroupsButtonTapped), for: .touchUpInside)
        wordGroupsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordGroupsButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            intervalTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            intervalTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            intervalTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            intervalTextField.heightAnchor.constraint(equalToConstant: 44),
            
            scheduleButton.topAnchor.constraint(equalTo: intervalTextField.bottomAnchor, constant: 30),
            scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scheduleButton.heightAnchor.constraint(equalToConstant: 50),
            
            stopNotificationsButton.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 15),
            stopNotificationsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stopNotificationsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stopNotificationsButton.heightAnchor.constraint(equalToConstant: 50),
            
            statusLabel.topAnchor.constraint(equalTo: stopNotificationsButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            playGameButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            playGameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playGameButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playGameButton.heightAnchor.constraint(equalToConstant: 50),
            
            randomQuizButton.topAnchor.constraint(equalTo: playGameButton.bottomAnchor, constant: 15),
            randomQuizButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            randomQuizButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            randomQuizButton.heightAnchor.constraint(equalToConstant: 50),
            
            fastestFingerButton.topAnchor.constraint(equalTo: randomQuizButton.bottomAnchor, constant: 15),
            fastestFingerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fastestFingerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            fastestFingerButton.heightAnchor.constraint(equalToConstant: 50),
            
            personalizedQuizButton.topAnchor.constraint(equalTo: fastestFingerButton.bottomAnchor, constant: 15),
            personalizedQuizButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            personalizedQuizButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            personalizedQuizButton.heightAnchor.constraint(equalToConstant: 50),
            
            flashCardsButton.topAnchor.constraint(equalTo: personalizedQuizButton.bottomAnchor, constant: 15),
            flashCardsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            flashCardsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flashCardsButton.heightAnchor.constraint(equalToConstant: 50),
            
            enhancedFlashCardsButton.topAnchor.constraint(equalTo: flashCardsButton.bottomAnchor, constant: 15),
            enhancedFlashCardsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enhancedFlashCardsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            enhancedFlashCardsButton.heightAnchor.constraint(equalToConstant: 50),
            
            learningAnalyticsButton.topAnchor.constraint(equalTo: enhancedFlashCardsButton.bottomAnchor, constant: 15),
            learningAnalyticsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            learningAnalyticsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            learningAnalyticsButton.heightAnchor.constraint(equalToConstant: 50),
            
            wordGroupsButton.topAnchor.constraint(equalTo: learningAnalyticsButton.bottomAnchor, constant: 15),
            wordGroupsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wordGroupsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            wordGroupsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard !isKeyboardVisible, 
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        isKeyboardVisible = true
        
        // Calculate how much to move the view up
        let textFieldBottom = intervalTextField.convert(intervalTextField.bounds, to: view).maxY
        let keyboardTop = view.frame.height - keyboardFrame.height
        let overlap = textFieldBottom - keyboardTop + 20 // Add some padding
        
        if overlap > 0 {
            UIView.animate(withDuration: duration) {
                self.view.frame.origin.y = -overlap
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard isKeyboardVisible,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        isKeyboardVisible = false
        
        // Restore the view to its original position
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.statusLabel.text = "Notification permission granted. Ready to schedule."
                } else {
                    self.statusLabel.text = "Notification permission denied. Please enable in Settings."
                }
            }
        }
    }
    
    @objc private func scheduleButtonTapped() {
        guard let minutesText = intervalTextField.text, !minutesText.isEmpty,
              let minutes = Double(minutesText), minutes > 0 else {
            statusLabel.text = "Please enter a valid number of minutes."
            return
        }
        
        // Convert minutes to seconds
        let seconds = minutes * 60
        
        // Schedule notifications
        NotificationManager.shared.scheduleWordNotifications(duration: seconds)
        
        statusLabel.text = "Notifications scheduled every \(minutes) minute(s)."
        
        // Dismiss keyboard
        dismissKeyboard()
    }
    
    @objc private func playGameButtonTapped() {
        let gameVC = GameViewController()
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }
    
    @objc private func randomQuizButtonTapped() {
        // Get 10 random words for the quiz
        guard let allWords = WordService.shared.loadWords(), !allWords.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Failed to load words for quiz", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Get 10 random words
        let randomWords = WordService.shared.getRandomWords(count: 10)
        
        // Create and present the quiz directly
        let quizVC = QuizViewController(words: randomWords)
        quizVC.modalPresentationStyle = .fullScreen
        quizVC.title = "Random Quiz" // Set a title to indicate it's a random quiz
        present(quizVC, animated: true)
    }
    
    @objc private func fastestFingerButtonTapped() {
        let fastestFingerVC = FastestFingerQuizViewController()
        fastestFingerVC.modalPresentationStyle = .fullScreen
        present(fastestFingerVC, animated: true)
    }
    
    @objc private func personalizedQuizButtonTapped() {
        // Always show the wrong words list, even if empty
        let personalizedQuizVC = PersonalizedQuizViewController()
        personalizedQuizVC.modalPresentationStyle = .fullScreen
        present(personalizedQuizVC, animated: true)
    }
    
    @objc private func flashCardsButtonTapped() {
        let flashCardVC = FlashCardViewController()
        flashCardVC.modalPresentationStyle = .fullScreen
        present(flashCardVC, animated: true)
    }
    
    @objc private func enhancedFlashCardsButtonTapped() {
        // Initialize the spaced repetition system with words if it's empty
        if SpacedRepetitionSystem.shared.getAllWords().isEmpty {
            initializeSpacedRepetitionSystem()
        }
        
        let enhancedFlashCardVC = EnhancedFlashCardViewController()
        enhancedFlashCardVC.modalPresentationStyle = .fullScreen
        present(enhancedFlashCardVC, animated: true)
    }
    
    @objc private func learningAnalyticsButtonTapped() {
        let learningAnalyticsVC = LearningAnalyticsViewController()
        learningAnalyticsVC.modalPresentationStyle = .fullScreen
        present(learningAnalyticsVC, animated: true)
    }
    
    @objc private func stopNotificationsButtonTapped() {
        // Use the NotificationManager to stop all notifications
        NotificationManager.shared.stopAllNotifications()
        
        // Update status label
        statusLabel.text = "All notifications have been cancelled."
        
        // Show confirmation alert
        let alert = UIAlertController(title: "Notifications Stopped", 
                                     message: "All scheduled word notifications have been cancelled.", 
                                     preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func wordGroupsButtonTapped() {
        let wordGroupsVC = WordGroupViewController()
        let navigationController = UINavigationController(rootViewController: wordGroupsVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    private func initializeSpacedRepetitionSystem() {
        // Load words from the WordService
        guard let words = WordService.shared.loadWords(style: .flashcard) else {
            return
        }
        
        // Add the first 50 words to the spaced repetition system
        let initialWords = words.prefix(50)
        for word in initialWords {
            SpacedRepetitionSystem.shared.addWord(word.word, meaning: word.meaning)
            
            // Add example sentences if available
            let exampleSentence = ExampleSentenceGenerator.shared.generateExampleSentence(for: word.word)
            ExampleSentenceGenerator.shared.addExampleSentence(exampleSentence, for: word.word)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Ensure keyboard is properly initialized
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            textField.inputViewController?.viewDidAppear(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Ensure keyboard is properly dismissed
        if isKeyboardVisible {
            dismissKeyboard()
        }
    }
}

