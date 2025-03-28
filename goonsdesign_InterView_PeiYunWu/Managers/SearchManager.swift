//
//  Untitled.swift
//  goonsdesign_InterView_PeiYunWu
//
//  Created by Peiyun on 2025/3/28.
//

import UIKit
import Combine

class RepositoryManager {
    static let shared = RepositoryManager()
    
    private init() {}

    func fetchRepositories(query: String) -> AnyPublisher<[Repository], Error> {
        let urlString = "https://api.github.com/search/repositories?q=\(query)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
