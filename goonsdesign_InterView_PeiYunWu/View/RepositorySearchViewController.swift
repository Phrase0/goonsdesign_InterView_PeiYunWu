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
        setupNavigationBarAppearance()
        setupUI()
        setupPullToRefresh()
    }
    
    private func setupNavigationBarAppearance() {
        // 設定 UINavigationBarAppearance
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        // 初始時背景透明
        barAppearance.backgroundColor = .clear
        // 初始時標題文字透明
        barAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
        
        let scrolledAppearance = UINavigationBarAppearance()
        scrolledAppearance.configureWithDefaultBackground()
        scrolledAppearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        // 滑動時標題顯示為白色
        scrolledAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // 設定滑動時與標準模式的外觀
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
        navigationController?.navigationBar.standardAppearance = scrolledAppearance
        
        // 避免標題在返回時變大
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Repository Search"
        
        
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
}

// MARK: - ScrollView Delegate
extension RepositorySearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY > 0 {
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
        } else {
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.clear
            ]
        }
    }
}

// MARK: - SearchBar Delegate
extension RepositorySearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchText.isEmpty {
              repositories.removeAll()
              searchTableView.reloadData()
          }
      }
      
      func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
          guard let query = searchBar.text, !query.isEmpty else { return }
          fetchRepositories(query: query)
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
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 1 {
            // Search bar cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchBarCell", for: indexPath)
            cell.selectionStyle = .none
            cell.contentView.addSubview(searchBar)
            return cell
        } else {
            // Repository cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "repositoryCell", for: indexPath) as! RepositoryTableViewCell
            cell.configure(with: repositories[indexPath.row - 2])
            return cell
        }
    }
    
    // 隱藏第一個Cell上方的分隔線 & 第二個Cell底部的分隔線
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
    }
    
    //進入詳細頁面
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= 2 {
            let detailVC = RepositoryDetailViewController(repository: repositories[indexPath.row - 2])
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
