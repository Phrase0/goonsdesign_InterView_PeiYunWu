//
//  RepositoryModel.swift
//  goonsdesign_InterView_PeiYunWu
//
//  Created by Peiyun on 2025/3/26.
//

import UIKit

struct SearchResponse: Codable {
    let items: [Repository]
}

struct Repository: Codable {
    let name: String
    let description: String?
    let language: String?
    let stars: Int
    let watchers: Int
    let forks: Int
    let openIssues: Int
    let owner: Owner

    enum CodingKeys: String, CodingKey {
        case name, description, language, owner
        case stars = "stargazers_count"
        case watchers = "watchers_count"
        case forks = "forks_count"
        case openIssues = "open_issues_count"
    }
}

struct Owner: Codable {
    let login: String
    let avatar_url: String
}
