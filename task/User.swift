//
//  User.swift
//  task
//
//  Created by Hasan Armoush on 3/9/20.
//  Copyright © 2020 Hasan Armoush. All rights reserved.
//

import Foundation
struct Follower: Codable, Hashable {
  var login: String
  var avatarUrl: String // Codable decoder will convert snake case to camel case
}
struct User: Codable {
  let login: String
  let avatarUrl: String
  var name: String?
  var location: String?
  var bio: String?
  let publicRepos: Int
  let publicGists: Int
  let htmlUrl: String
  let following: Int
  let followers: Int
  let createdAt: Date
}
