//
//  PersonalizedQuizViewController.swift
//  Notifications
//
//  Created by Om Roy on 01/03/25.
//

import UIKit

class PersonalizedQuizViewController: UIViewController {
    
    // UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let takeQuizButton = UIButton(type: .system)
    private let emptyStateLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["All Words", "In Practice"])
    
    // Data
    private var allWrongWords: [(word: String, wrongCount: Int, streak: Int)] = []
    private var practiceWords: [(word: String, wrongCount: Int, streak: Int)] = []
    private var displayedWords: [(word: String, wrongCount: Int, streak: Int)] = []
    private var wordMeanings: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWrongWords()
        
        // Post notification for styling
        NotificationCenter.default.post(
            name: NSNotification.Name("QuizViewDidLoadNotification"),
            object: self
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload data when view appears (in case quiz changed the data)
        loadWrongWords()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label
        titleLabel.text = "Wrong Words List"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Segmented Control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        // Table View
        tableView.register(WrongWordCell.self, forCellReuseIdentifier: "WrongWordCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)
        
        // Take Quiz Button
        takeQuizButton.setTitle("Take Practice Quiz", for: .normal)
        takeQuizButton.backgroundColor = .systemTeal
        takeQuizButton.setTitleColor(.white, for: .normal)
        takeQuizButton.layer.cornerRadius = 10
        takeQuizButton.addTarget(self, action: #selector(takeQuizButtonTapped), for: .touchUpInside)
        takeQuizButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(takeQuizButton)
        
        // Empty State Label
        emptyStateLabel.text = "You haven't gotten any words wrong yet.\nKeep taking quizzes to build your practice list!"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: takeQuizButton.topAnchor, constant: -20),
            
            takeQuizButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            takeQuizButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            takeQuizButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            takeQuizButton.heightAnchor.constraint(equalToConstant: 50),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        // Add back button
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func loadWrongWords() {
        // Get all wrong words with their counts
        allWrongWords = PersonalizedQuizService.shared.getAllWrongWordsWithCounts()
        
        // Get words currently in practice
        practiceWords = PersonalizedQuizService.shared.getWordsCurrentlyInPractice()
        
        // Set displayed words based on current segment
        updateDisplayedWords()
        
        // Load meanings for all words
        loadWordMeanings()
        
        // Update UI based on whether we have wrong words
        updateEmptyState()
        
        // Reload table view
        tableView.reloadData()
    }
    
    private func updateDisplayedWords() {
        if segmentedControl.selectedSegmentIndex == 0 {
            // Show all words
            displayedWords = allWrongWords
        } else {
            // Show only words in practice
            displayedWords = practiceWords
        }
    }
    
    private func loadWordMeanings() {
        // Clear existing meanings
        wordMeanings.removeAll()
        
        // Get all words from the service
        if let allWords = WordService.shared.loadWords(style: .concise) {
            // Create a dictionary for quick lookup
            for word in allWords {
                wordMeanings[word.word] = word.meaning
            }
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = allWrongWords.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        segmentedControl.isHidden = isEmpty
        takeQuizButton.isEnabled = !practiceWords.isEmpty
        
        if practiceWords.isEmpty {
            takeQuizButton.alpha = 0.5
        } else {
            takeQuizButton.alpha = 1.0
        }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        updateDisplayedWords()
        tableView.reloadData()
    }
    
    @objc private func takeQuizButtonTapped() {
        // Create and present the personalized quiz
        let quizVC = PersonalizedQuizGameViewController()
        quizVC.modalPresentationStyle = .fullScreen
        
        // Register for quiz styling
        QuizStyling.shared.registerForStyling()
        
        present(quizVC, animated: true)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    private func isWordInPractice(_ word: String) -> Bool {
        return practiceWords.contains { $0.word == word }
    }
    
    private func addWordToPractice(_ word: String) {
        PersonalizedQuizService.shared.addWordBackToPractice(word)
        loadWrongWords() // Reload data to update UI
    }
}

// MARK: - UITableViewDataSource
extension PersonalizedQuizViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WrongWordCell", for: indexPath) as! WrongWordCell
        
        let wordData = displayedWords[indexPath.row]
        let meaning = wordMeanings[wordData.word] ?? "Meaning not available"
        let isInPractice = isWordInPractice(wordData.word)
        
        cell.configure(
            word: wordData.word,
            meaning: meaning,
            wrongCount: wordData.wrongCount,
            streak: wordData.streak,
            isInPractice: isInPractice
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PersonalizedQuizViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let wordData = displayedWords[indexPath.row]
        let isInPractice = isWordInPractice(wordData.word)
        
        // If word is not in practice, show option to add it back
        if !isInPractice {
            let alert = UIAlertController(
                title: "Add to Practice?",
                message: "Would you like to add '\(wordData.word)' back to your practice list?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                self?.addWordToPractice(wordData.word)
            })
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            
            present(alert, animated: true)
        }
    }
}

// MARK: - Custom Cell for Wrong Words
class WrongWordCell: UITableViewCell {
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let wrongCountLabel = UILabel()
    private let streakView = UIStackView()
    private let statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        // Word Label
        wordLabel.font = UIFont.boldSystemFont(ofSize: 18)
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wordLabel)
        
        // Meaning Label
        meaningLabel.font = UIFont.systemFont(ofSize: 14)
        meaningLabel.textColor = .darkGray
        meaningLabel.numberOfLines = 0
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(meaningLabel)
        
        // Wrong Count Label
        wrongCountLabel.font = UIFont.systemFont(ofSize: 14)
        wrongCountLabel.textColor = .systemRed
        wrongCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrongCountLabel)
        
        // Status Label
        statusLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textAlignment = .right
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusLabel)
        
        // Streak View
        streakView.axis = .horizontal
        streakView.spacing = 4
        streakView.distribution = .fillEqually
        streakView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(streakView)
        
        // Add 3 circles to streak view
        for _ in 0..<3 {
            let circleView = UIView()
            circleView.backgroundColor = .systemGray5
            circleView.layer.cornerRadius = 8
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            circleView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            streakView.addArrangedSubview(circleView)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            wrongCountLabel.centerYAnchor.constraint(equalTo: wordLabel.centerYAnchor),
            wrongCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 4),
            meaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            meaningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            statusLabel.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            streakView.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 8),
            streakView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            streakView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(word: String, meaning: String, wrongCount: Int, streak: Int, isInPractice: Bool) {
        wordLabel.text = word
        meaningLabel.text = meaning
        wrongCountLabel.text = "Wrong: \(wrongCount) times"
        
        // Update status label
        if isInPractice {
            statusLabel.text = "In Practice"
            statusLabel.textColor = .systemBlue
            streakView.isHidden = false
            
            // Update streak circles
            for (index, view) in streakView.arrangedSubviews.enumerated() {
                if index < streak {
                    view.backgroundColor = .systemGreen
                } else {
                    view.backgroundColor = .systemGray5
                }
            }
        } else {
            statusLabel.text = "Mastered (tap to practice again)"
            statusLabel.textColor = .systemGreen
            streakView.isHidden = true
        }
        
        // Add disclosure indicator for mastered words
        accessoryType = isInPractice ? .none : .disclosureIndicator
    }
} 