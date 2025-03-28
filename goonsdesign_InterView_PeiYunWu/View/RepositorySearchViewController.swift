//
//  ViewController.swift
//  goonsdesign_InterView_PeiYunWu
//
//  Created by Peiyun on 2025/3/26.
//

import UIKit
import Combine
import MJRefresh

class RepositorySearchViewController: UIViewController {

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "請輸入關鍵字搜尋"
        searchBar.showsCancelButton = false
        return searchBar
    }()

    private let searchTableView = UITableView()
    private var repositories: [Repository] = []
    private var cancellables = Set<AnyCancellable>()
    
    private enum CellType {
        case title
        case searchBar
        case repository
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPullToRefresh()
    }
    
    private func setupNavigationBar() {
        // Initially hide the navigation bar
        navigationController?.navigationBar.isHidden = true
        
        let barAppearance = UINavigationBarAppearance()
        
        // Set the background color to black with 5% transparency
        barAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        
        // Set the title text to white
        barAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Set large title properties if needed
        barAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Apply the appearance to the navigation bar
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        UINavigationBar.appearance().standardAppearance = barAppearance
    }

    private func setupUI() {
        searchBar.delegate = self
        searchBar.sizeToFit()

        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "repositoryCell")
        searchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "titleCell")
        searchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchBarCell")

        view.addSubview(searchTableView)
        searchTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: view.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - API Call
    private func fetchRepositories(query: String) {
        RepositoryManager.shared.fetchRepositories(query: query)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] repositories in
                self?.repositories = repositories
                self?.searchTableView.reloadData()
            })
            .store(in: &cancellables)
    }

    // MARK: - Refresh
    func setupPullToRefresh() {
        MJRefreshNormalHeader {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                if let query = self.searchBar.text, !query.isEmpty {
                    self.fetchRepositories(query: query)
                } else {
                    let alertController = UIAlertController(title: "Oops!", message: "The data couldn't be read because it is missing", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title:"Ok", style: .default, handler: { _ in
                    self.dismiss(animated: true)
                    }))
                   self.present(alertController, animated: true, completion: nil)
                    
                }
                self.searchTableView.mj_header?.endRefreshing()
            }
        }.autoChangeTransparency(true).link(to: self.searchTableView)
    }
}

// MARK: - SearchBar Delegate

extension RepositorySearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            repositories.removeAll()
        } else {
            fetchRepositories(query: searchText)
        }
        searchTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        fetchRepositories(query: query)
        searchBar.becomeFirstResponder()
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        repositories.removeAll()
        searchTableView.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate

extension RepositorySearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add one for the title and search bar rows
        return 1 + 1 + repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Title cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
            cell.textLabel?.text = "Repository Search"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 34)
            cell.textLabel?.textAlignment = .left
            cell.contentView.layoutMargins.left = 16
            
            return cell
        } else if indexPath.row == 1 {
            // Search bar cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchBarCell", for: indexPath)
            cell.contentView.addSubview(searchBar)
            return cell
        } else {
            // Repository cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "repositoryCell", for: indexPath) as! RepositoryTableViewCell
            cell.configure(with: repositories[indexPath.row - 2]) // Adjust for the first two rows
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= 2 {
            let detailVC = RepositoryDetailViewController(repository: repositories[indexPath.row - 2]) // Adjust for the first two rows
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
