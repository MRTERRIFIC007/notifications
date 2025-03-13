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
    private let todayButton = UIButton(type: .system)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GRE Word Groups"
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupSearchController()
        setupSegmentedControl()
        setupTodayButton()
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
    private func setupNavigationBar() {
        // Add a button to schedule groups
        let calendarButton = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(showCalendar)
        )
        navigationItem.rightBarButtonItem = calendarButton
        
        // Add a close button
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissView)
        )
        navigationItem.leftBarButtonItem = closeButton
    }
    
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
    
    private func setupTodayButton() {
        todayButton.setTitle("Study Today's Group", for: .normal)
        todayButton.backgroundColor = .systemBlue
        todayButton.setTitleColor(.white, for: .normal)
        todayButton.layer.cornerRadius = 10
        todayButton.addTarget(self, action: #selector(studyTodayGroup), for: .touchUpInside)
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(todayButton)
        
        NSLayoutConstraint.activate([
            todayButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            todayButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            todayButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            todayButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: todayButton.topAnchor, constant: -20)
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
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    @objc private func showCalendar() {
        let calendarVC = GroupScheduleViewController()
        navigationController?.pushViewController(calendarVC, animated: true)
    }
    
    @objc private func studyTodayGroup() {
        guard let dailyGroup = WordGroupService.shared.getCurrentDailyGroup() else {
            let alert = UIAlertController(
                title: "No Group Available",
                message: "There are no more groups to study today.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let flashCardVC = DailyFlashCardViewController(groupId: dailyGroup.groupId)
        let navigationController = UINavigationController(rootViewController: flashCardVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
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
    private let statusLabel = UILabel()
    
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
        contentView.addSubview(statusLabel)
        
        // Configure views
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        countLabel.font = UIFont.systemFont(ofSize: 14)
        difficultyLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.font = UIFont.italicSystemFont(ofSize: 12)
        progressLabel.textColor = .gray
        
        statusLabel.font = UIFont.boldSystemFont(ofSize: 12)
        statusLabel.textColor = .systemBlue
        statusLabel.textAlignment = .right
        
        difficultyIndicator.layer.cornerRadius = 4
        
        // Set constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            difficultyIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            difficultyIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            difficultyIndicator.widthAnchor.constraint(equalToConstant: 8),
            difficultyIndicator.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: difficultyIndicator.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
            
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
        statusLabel.text = group.statusInfo
        
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
        
        // Highlight today's group
        if group.isDailyGroup {
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            statusLabel.textColor = .systemBlue
        } else if group.isCompleted {
            contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            statusLabel.textColor = .systemGreen
        } else if group.scheduledForDate != nil {
            contentView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
            statusLabel.textColor = .systemOrange
        } else {
            contentView.backgroundColor = .clear
            statusLabel.textColor = .systemGray
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
        let detailVC = GroupWordDetailViewController(word: word)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Word Detail View Controller
class GroupWordDetailViewController: UIViewController {
    
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

// MARK: - Daily Flash Card View Controller
class DailyFlashCardViewController: UIViewController {
    
    // MARK: - Properties
    private let groupId: Int
    private var words: [Word] = []
    private var currentIndex = 0
    
    private let cardView = UIView()
    private let wordLabel = UILabel()
    private let meaningLabel = UILabel()
    private let progressLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let flipButton = UIButton(type: .system)
    private let completeButton = UIButton(type: .system)
    
    private var isShowingMeaning = false
    
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
            title = "Daily Study: \(group.groupName)"
        } else {
            title = "Daily Study"
        }
        
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCardView()
        setupButtons()
        setupProgressLabel()
        loadWords()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissView)
        )
        navigationItem.leftBarButtonItem = closeButton
        
        let markCompleteButton = UIBarButtonItem(
            title: "Mark Complete",
            style: .plain,
            target: self,
            action: #selector(markGroupAsCompleted)
        )
        navigationItem.rightBarButtonItem = markCompleteButton
    }
    
    private func setupCardView() {
        // Card container
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        // Word label
        wordLabel.font = UIFont.boldSystemFont(ofSize: 28)
        wordLabel.textAlignment = .center
        wordLabel.numberOfLines = 0
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(wordLabel)
        
        // Meaning label
        meaningLabel.font = UIFont.systemFont(ofSize: 18)
        meaningLabel.textAlignment = .center
        meaningLabel.numberOfLines = 0
        meaningLabel.alpha = 0 // Hidden initially
        meaningLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(meaningLabel)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            wordLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -20),
            wordLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            meaningLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            meaningLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 20),
            meaningLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            meaningLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
        ])
        
        // Add tap gesture to flip the card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        cardView.addGestureRecognizer(tapGesture)
        cardView.isUserInteractionEnabled = true
    }
    
    private func setupButtons() {
        // Previous button
        prevButton.setTitle("Previous", for: .normal)
        prevButton.addTarget(self, action: #selector(showPreviousWord), for: .touchUpInside)
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prevButton)
        
        // Next button
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(showNextWord), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        // Flip button
        flipButton.setTitle("Flip Card", for: .normal)
        flipButton.backgroundColor = .systemBlue
        flipButton.setTitleColor(.white, for: .normal)
        flipButton.layer.cornerRadius = 10
        flipButton.addTarget(self, action: #selector(flipCard), for: .touchUpInside)
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(flipButton)
        
        // Complete button
        completeButton.setTitle("Mark Group Complete", for: .normal)
        completeButton.backgroundColor = .systemGreen
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.layer.cornerRadius = 10
        completeButton.addTarget(self, action: #selector(markGroupAsCompleted), for: .touchUpInside)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            prevButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 30),
            
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nextButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 30),
            
            flipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            flipButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 30),
            flipButton.widthAnchor.constraint(equalToConstant: 120),
            flipButton.heightAnchor.constraint(equalToConstant: 44),
            
            completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            completeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupProgressLabel() {
        progressLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.textAlignment = .center
        progressLabel.textColor = .gray
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: flipButton.bottomAnchor, constant: 20)
        ])
    }
    
    // MARK: - Data Methods
    private func loadWords() {
        if let wordObjects = WordGroupService.shared.getWordObjectsForGroup(groupId: groupId) {
            words = wordObjects
            updateUI()
        }
    }
    
    private func updateUI() {
        guard !words.isEmpty else {
            wordLabel.text = "No words available"
            meaningLabel.text = ""
            progressLabel.text = "0/0"
            prevButton.isEnabled = false
            nextButton.isEnabled = false
            flipButton.isEnabled = false
            return
        }
        
        let currentWord = words[currentIndex]
        wordLabel.text = currentWord.word
        meaningLabel.text = currentWord.meaning
        progressLabel.text = "\(currentIndex + 1)/\(words.count)"
        
        // Update button states
        prevButton.isEnabled = currentIndex > 0
        nextButton.isEnabled = currentIndex < words.count - 1
        
        // Reset card state
        isShowingMeaning = false
        UIView.animate(withDuration: 0.2) {
            self.meaningLabel.alpha = 0
        }
    }
    
    // MARK: - Actions
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    @objc private func showPreviousWord() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateUI()
    }
    
    @objc private func showNextWord() {
        guard currentIndex < words.count - 1 else { return }
        currentIndex += 1
        updateUI()
    }
    
    @objc private func flipCard() {
        isShowingMeaning = !isShowingMeaning
        
        UIView.animate(withDuration: 0.3) {
            self.meaningLabel.alpha = self.isShowingMeaning ? 1.0 : 0.0
        }
    }
    
    @objc private func markGroupAsCompleted() {
        WordGroupService.shared.markGroupAsCompleted(groupId: groupId)
        
        let alert = UIAlertController(
            title: "Group Completed",
            message: "This group has been marked as completed. Great job!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Group Schedule View Controller
class GroupScheduleViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private var wordGroups: [WordGroup] = []
    private let datePicker = UIDatePicker()
    private var selectedDate = Date()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule Groups"
        view.backgroundColor = .systemBackground
        
        setupDatePicker()
        setupTableView()
        loadGroups()
    }
    
    // MARK: - Setup Methods
    private func setupDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GroupCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Data Methods
    private func loadGroups() {
        wordGroups = WordGroupService.shared.getAllWordGroups()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func dateChanged() {
        selectedDate = datePicker.date
        tableView.reloadData()
    }
    
    private func scheduleGroup(_ group: WordGroup, forDate date: Date) {
        WordGroupService.shared.scheduleGroup(groupId: group.groupId, forDate: date)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource for GroupScheduleViewController
extension GroupScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        let group = wordGroups[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = group.groupName
        
        // Check if this group is scheduled for the selected date
        let calendar = Calendar.current
        if let scheduledDate = group.scheduledForDate,
           calendar.isDate(scheduledDate, inSameDayAs: selectedDate) {
            content.secondaryText = "Scheduled for this date"
            cell.accessoryType = .checkmark
        } else {
            content.secondaryText = "\(group.words.count) words - \(group.difficulty.rawValue)"
            cell.accessoryType = .none
        }
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate for GroupScheduleViewController
extension GroupScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = wordGroups[indexPath.row]
        
        // Check if already scheduled for this date
        let calendar = Calendar.current
        if let scheduledDate = group.scheduledForDate,
           calendar.isDate(scheduledDate, inSameDayAs: selectedDate) {
            // Already scheduled, ask if they want to unschedule
            let alert = UIAlertController(
                title: "Group Already Scheduled",
                message: "This group is already scheduled for this date. Would you like to unschedule it?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Unschedule", style: .destructive) { _ in
                // Unschedule by setting date to nil
                WordGroupService.shared.scheduleGroup(groupId: group.groupId, forDate: nil)
                tableView.reloadData()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        } else {
            // Not scheduled, ask if they want to schedule
            let alert = UIAlertController(
                title: "Schedule Group",
                message: "Would you like to schedule '\(group.groupName)' for \(formattedDate(selectedDate))?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Schedule", style: .default) { _ in
                self.scheduleGroup(group, forDate: self.selectedDate)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 