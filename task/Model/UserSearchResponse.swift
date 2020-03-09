//
//  UserSearchResponse.swift
//  task
//
//  Created by Hasan Armoush on 3/8/20.
//  Copyright © 2020 Hasan Armoush. All rights reserved.

import Foundation
public struct SearchUsersResponse : Codable {
    public let incompleteResults : Bool?
    public let items : [SearchUsersItem]?
    public let totalCount : Int?
    enum CodingKeys: String, CodingKey {
        case incompleteResults = "incomplete_results"
        case items
        case totalCount = "total_count"
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        incompleteResults = try values.decodeIfPresent(Bool.self, forKey: .incompleteResults)
        items = try values.decodeIfPresent([SearchUsersItem].self, forKey: .items)
        totalCount = try values.decodeIfPresent(Int.self, forKey: .totalCount)
    }
}
