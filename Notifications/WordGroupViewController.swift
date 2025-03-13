//
//  WordGroupViewController.swift
//  Notifications
//
//  Created for GRE Vocabulary App
//

import UIKit

class WordGroupViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private var wordGroups: [WordGroup] = []
    private var filteredGroups: [WordGroup] = []
    private let segmentedControl = UISegmentedControl(items: ["All", "Beginner", "Intermediate", "Advanced", "Expert"])
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GRE Word Groups"
        view.backgroundColor = .systemBackground
        
        setupSearchController()
        setupSegmentedControl()
        setupTableView()
        loadWordGroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data when view appears
        loadWordGroups()
        tableView.reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Word Groups"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        let segmentedControlContainer = UIView()
        segmentedControlContainer.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: segmentedControlContainer.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: segmentedControlContainer.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: segmentedControlContainer.trailingAnchor, constant: -16),
            segmentedControl.bottomAnchor.constraint(equalTo: segmentedControlContainer.bottomAnchor, constant: -8)
        ])
        
        tableView.tableHeaderView = segmentedControlContainer
        segmentedControlContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(WordGroupCell.self, forCellReuseIdentifier: "WordGroupCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
    }
    
    // MARK: - Data Methods
    private func loadWordGroups() {
        wordGroups = WordGroupService.shared.getAllWordGroups()
        filterGroups()
    }
    
    private func filterGroups() {
        if searchController.isActive && !searchController.searchBar.text!.isEmpty {
            let searchText = searchController.searchBar.text!.lowercased()
            
            filteredGroups = wordGroups.filter { group in
                return group.groupName.lowercased().contains(searchText) ||
                       group.words.contains { $0.lowercased().contains(searchText) }
            }
        } else {
            filteredGroups = wordGroups
        }
        
        // Apply difficulty filter if not on "All" segment
        if segmentedControl.selectedSegmentIndex > 0 {
            let difficulties: [GroupDifficulty] = [.beginner, .intermediate, .advanced, .expert]
            let selectedDifficulty = difficulties[segmentedControl.selectedSegmentIndex - 1]
            filteredGroups = filteredGroups.filter { $0.difficulty == selectedDifficulty }
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        filterGroups()
    }
}

// MARK: - UITableViewDataSource
extension WordGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordGroupCell", for: indexPath) as! WordGroupCell
        let group = filteredGroups[indexPath.row]
        cell.configure(with: group)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WordGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = filteredGroups[indexPath.row]
        let wordListVC = WordListViewController(groupId: group.groupId)
        navigationController?.pushViewController(wordListVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension WordGroupViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterGroups()
    }
}

// MARK: - Custom Cell
class WordGroupCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let difficultyLabel = UILabel()
    private let progressLabel = UILabel()
    private let difficultyIndicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(difficultyLabel)
        contentView.addSubview(progressLabel)
        contentView.addSubview(difficultyIndicator)
        
        // Configure views
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        countLabel.font = UIFont.systemFont(ofSize: 14)
        difficultyLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.font = UIFont.italicSystemFont(ofSize: 12)
        progressLabel.textColor = .gray
        
        difficultyIndicator.layer.cornerRadius = 4
        
        // Set constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            difficultyIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            difficultyIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            difficultyIndicator.widthAnchor.constraint(equalToConstant: 8),
            difficultyIndicator.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: difficultyIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: difficultyIndicator.trailingAnchor, constant: 12),
            
            difficultyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            difficultyLabel.leadingAnchor.constraint(equalTo: countLabel.trailingAnchor, constant: 8),
            
            progressLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 4),
            progressLabel.leadingAnchor.constraint(equalTo: difficultyIndicator.trailingAnchor, constant: 12),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
        
        // Add disclosure indicator
        accessoryType = .disclosureIndicator
    }
    
    func configure(with group: WordGroup) {
        titleLabel.text = group.groupName
        countLabel.text = "\(group.words.count) words"
        difficultyLabel.text = group.difficulty.rawValue
        progressLabel.text = group.progressInfo
        
        // Set color based on difficulty
        switch group.difficulty {
        case .beginner:
            difficultyIndicator.backgroundColor = .systemGreen
        case .intermediate:
            difficultyIndicator.backgroundColor = .systemBlue
        case .advanced:
            difficultyIndicator.backgroundColor = .systemOrange
        case .expert:
            difficultyIndicator.backgroundColor = .systemRed
        }
        
        // Add checkmark if completed
        accessoryType = group.isCompleted ? .checkmark : .disclosureIndicator
    }
}

// MARK: - Word List View Controller
class WordListViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private let groupId: Int
    private var words: [Word] = []
    
    // MARK: - Initialization
    init(groupId: Int) {
        self.groupId = groupId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let group = WordGroupService.shared.getWordGroup(byId: groupId) {
            title = group.groupName
        } else {
            title = "Word List"
        }
        
        view.backgroundColor = .systemBackground
        setupTableView()
        loadWords()
        setupNavigationBar()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WordCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        if let group = WordGroupService.shared.getWordGroup(byId: groupId) {
            let markButton = UIBarButtonItem(
                title: group.isCompleted ? "Mark Incomplete" : "Mark Complete",
                style: .plain,
                target: self,
                action: #selector(toggleCompletionStatus)
            )
            navigationItem.rightBarButtonItem = markButton
        }
    }
    
    // MARK: - Data Methods
    private func loadWords() {
        if let wordObjects = WordGroupService.shared.getWordObjectsForGroup(groupId: groupId) {
            words = wordObjects
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    @objc private func toggleCompletionStatus() {
        if let group = WordGroupService.shared.getWordGroup(byId: groupId) {
            if group.isCompleted {
                WordGroupService.shared.resetGroup(groupId: groupId)
            } else {
                WordGroupService.shared.markGroupAsCompleted(groupId: groupId)
            }
            setupNavigationBar()
        }
    }
}

// MARK: - UITableViewDataSource
extension WordListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        let word = words[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = word.word
        content.secondaryText = word.meaning
        content.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let word = words[indexPath.row]
        let detailVC = WordDetailViewController(word: word)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Word Detail View Controller
class WordDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let word: Word
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - UI Components
    private let wordLabel = UILabel()
    private let meaningTitleLabel = UILabel()
    private let meaningLabel = UILabel()
    private let practiceButton = UIButton(type: .system)
    
    // MARK: - Initialization
    init(word: Word) {
        self.word = word
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = word.word
        view.backgroundColor = .systemBackground
        
        setupScrollView()
        setupUI()
    }
    
    // MARK: - Setup Methods
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupUI() {
        // Configure labels
        wordLabel.text = word.word
        wordLabel.font = UIFont.boldSystemFont(ofSize: 28)
        wordLabel.textAlignment = .center
        
        meaningTitleLabel.text = "Definition:"
        meaningTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        meaningLabel.text = word.meaning
        meaningLabel.font = UIFont.systemFont(ofSize: 16)
        meaningLabel.numberOfLines = 0
        
        // Configure practice button
        practiceButton.setTitle("Add to Practice List", for: .normal)
        practiceButton.backgroundColor = .systemBlue
        practiceButton.setTitleColor(.white, for: .normal)
        practiceButton.layer.cornerRadius = 10
        practiceButton.addTarget(self, action: #selector(addToPracticeList), for: .touchUpInside)
        
        // Add subviews
        contentView.addSubview(wordLabel)
        contentView.addSubview(meaningTitleLabel)
        contentView.addSubview(meaningLabel)
        contentView.addSubview(practiceButton)
        
        // Set constraints
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        meaningTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        practiceButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            wordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            meaningTitleLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 24),
            meaningTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            meaningTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            meaningLabel.topAnchor.constraint(equalTo: meaningTitleLabel.bottomAnchor, constant: 8),
            meaningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            meaningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            practiceButton.topAnchor.constraint(equalTo: meaningLabel.bottomAnchor, constant: 32),
            practiceButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            practiceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            practiceButton.heightAnchor.constraint(equalToConstant: 50),
            practiceButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Actions
    @objc private func addToPracticeList() {
        PersonalizedQuizService.shared.addWordBackToPractice(word.word)
        
        let alert = UIAlertController(
            title: "Added to Practice",
            message: "\(word.word) has been added to your practice list.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 