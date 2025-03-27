//
//  ViewController.swift
//  goonsdesign_InterView_PeiYunWu
//
//  Created by Peiyun on 2025/3/26.
//

import UIKit

import UIKit

class RepositorySearchViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "請輸入關鍵字搜尋"
        searchBar.showsCancelButton = false
        return searchBar
    }()
    
    private let tableView = UITableView()
    private var repositories: [Repository] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Repository Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: "cell")
        
        let stackView = UIStackView(arrangedSubviews: [searchBar, tableView])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    
    // MARK: - API Call
    private func fetchRepositories(query: String) {
        let urlString = "https://api.github.com/search/repositories?q=\(query)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode(SearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.repositories = result.items
                    self.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }.resume()
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
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        fetchRepositories(query: query)
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        repositories.removeAll()
        tableView.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate
extension RepositorySearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? RepositoryTableViewCell else { return UITableViewCell() }
        cell.configure(with: repositories[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = RepositoryDetailViewController(repository: repositories[indexPath.row])
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
