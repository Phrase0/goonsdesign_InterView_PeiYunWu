//
//  RepositoryDetailViewController.swift
//  goonsdesign_InterView_PeiYunWu
//
//  Created by Peiyun on 2025/3/26.
//

import UIKit

class RepositoryDetailViewController: UIViewController {
    
    private let repository: Repository

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsLabel = RepositoryDetailViewController.createInfoLabel()
    private let watchersLabel = RepositoryDetailViewController.createInfoLabel()
    private let forksLabel = RepositoryDetailViewController.createInfoLabel()
    private let issuesLabel = RepositoryDetailViewController.createInfoLabel()

    // MARK: - 初始化
    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        navigationItem.title = repository.owner.login
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(languageLabel)
        view.addSubview(starsLabel)
        view.addSubview(watchersLabel)
        view.addSubview(forksLabel)
        view.addSubview(issuesLabel)

        let stackView = UIStackView(arrangedSubviews: [starsLabel, watchersLabel, forksLabel, issuesLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .trailing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor, multiplier: 1.0),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            avatarImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            languageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 40),
            languageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            stackView.topAnchor.constraint(equalTo: languageLabel.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // 設定資料
    private func configureData() {
        nameLabel.text = "\(repository.owner.login)/\(repository.name)"
        languageLabel.text = "Written in \(repository.language ?? "Unknown")"
        starsLabel.text = "\(repository.stars) stars"
        watchersLabel.text = "\(repository.watchers) watchers"
        forksLabel.text = "\(repository.forks) forks"
        issuesLabel.text = "\(repository.openIssues) open issues"
        fetchImage(from: repository.owner.avatar_url)
    }

    // 加載圖片
    private func fetchImage(from url: String) {
        guard let imageUrl = URL(string: url) else { return }
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.avatarImageView.image = UIImage(data: data)
            }
        }.resume()
    }

    // 建立通用的 Info Label
    private static func createInfoLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
