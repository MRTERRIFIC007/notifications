//
//  LearnedWordsViewController.swift
//  Notifications
//
//  Created by Om Roy on 02/03/25.
//

import UIKit

class LearnedWordsViewController: UIViewController {
    
    // UI Elements
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let backButton = UIButton(type: .system)
    private let takeQuizButton = UIButton(type: .system)
    private let emptyStateLabel = UILabel()
    
    // Data
    private var learnedWords: [String]
    private var wordObjects: [Word] = []
    
    // Initialize with learned words
    init(learnedWords: [String]) {
        self.learnedWords = learnedWords.sorted()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWordObjects()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label
        titleLabel.text = "Learned Words"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Table View
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WordCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Empty State Label
        emptyStateLabel.text = "You haven't marked any words as learned yet."
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = !learnedWords.isEmpty
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        // Back Button
        backButton.setTitle("Back to Flash Cards", for: .normal)
        backButton.backgroundColor = .systemRed
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 10
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        // Take Quiz Button
        takeQuizButton.setTitle("Take Quiz on Learned Words", for: .normal)
        takeQuizButton.backgroundColor = .systemGreen
        takeQuizButton.setTitleColor(.white, for: .normal)
        takeQuizButton.layer.cornerRadius = 10
        takeQuizButton.addTarget(self, action: #selector(takeQuizButtonTapped), for: .touchUpInside)
        takeQuizButton.translatesAutoresizingMaskIntoConstraints = false
        takeQuizButton.isEnabled = !learnedWords.isEmpty
        view.addSubview(takeQuizButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: takeQuizButton.topAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            takeQuizButton.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -10),
            takeQuizButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            takeQuizButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            takeQuizButton.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadWordObjects() {
        guard !learnedWords.isEmpty else { return }
        
        // Load all words from the service
        guard let allWords = WordService.shared.loadWords(style: .flashcard) else {
            showAlert(title: "Error", message: "Failed to load word details")
            return
        }
        
        // Filter to get only the learned words
        wordObjects = allWords.filter { learnedWords.contains($0.word) }
        
        // Sort alphabetically
        wordObjects.sort { $0.word < $1.word }
        
        // Reload the table view
        tableView.reloadData()
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func takeQuizButtonTapped() {
        guard !wordObjects.isEmpty else {
            showAlert(title: "No Words", message: "There are no learned words to quiz on.")
            return
        }
        
        // Get up to 10 random words from learned words
        let shuffledWords = wordObjects.shuffled()
        let quizWordCount = min(10, shuffledWords.count)
        let quizWords = Array(shuffledWords.prefix(quizWordCount))
        
        // Create and present the quiz
        let quizVC = QuizViewController(words: quizWords)
        quizVC.title = "Learned Words Quiz"
        quizVC.modalPresentationStyle = .fullScreen
        
        // Set completion handler to track wrong answers
        quizVC.completionHandler = { [weak self] (wrongWords: [String]) in
            guard let self = self else { return }
            
            // Add wrong words to the personalized quiz service
            for word in wrongWords {
                PersonalizedQuizService.shared.markWordAsWrong(word)
            }
            
            // Show results
            if wrongWords.isEmpty {
                self.showAlert(title: "Perfect Score!", message: "Congratulations! You got all the words correct.")
            } else {
                self.showAlert(
                    title: "Quiz Completed",
                    message: "You got \(quizWords.count - wrongWords.count) out of \(quizWords.count) correct. The words you missed have been added to your practice list."
                )
            }
        }
        
        present(quizVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension LearnedWordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordObjects.isEmpty ? 0 : wordObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        if indexPath.row < wordObjects.count {
            let word = wordObjects[indexPath.row]
            
            // Configure cell with word and meaning
            var content = cell.defaultContentConfiguration()
            content.text = word.word
            content.secondaryText = word.meaning
            content.secondaryTextProperties.numberOfLines = 2
            content.textProperties.font = UIFont.boldSystemFont(ofSize: 16)
            cell.contentConfiguration = content
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LearnedWordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < wordObjects.count {
            let word = wordObjects[indexPath.row]
            
            // Show detail view with the word, meaning, and image
            let detailVC = WordDetailViewController(word: word)
            present(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // Provide enough height for the word and meaning
    }
} 