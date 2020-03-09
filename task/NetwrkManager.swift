//
//  NetwrkManager.swift
//  task
//
//  Created by Hasan Armoush on 3/9/20.
//  Copyright © 2020 Hasan Armoush. All rights reserved.
//

import Foundation
import UIKit
class NetworkManager {
static let shared = NetworkManager()
let baseURL = "https://api.github.com/users/"
let cache = NSCache<NSString, UIImage>()

private init() {}

func getFollowers(for username: String, page: Int, completed: @escaping (Result<[Follower], GFError>) -> Void) {
  let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
  
  guard let url = URL(string: endpoint) else {
    completed(.failure(.unableToComplete))
    return
  }
  
  let task = URLSession.shared.dataTask(with: url) { data, response, error in
    if let _ = error {
      completed(.failure(.unableToComplete))
      return
    }
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
      completed(.failure(.unableToComplete))
      return
    }
    
    guard let data = data else {
      completed(.failure(.invalidData))
      return
    }
    
    do {
      let decoder = JSONDecoder() // Codable was introduced in Swift 4.2
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let followers = try decoder.decode([Follower].self, from: data)
      completed(.success(followers))
    } catch {
      // developers can use error.localizedDescription for more detail
      completed(.failure(.invalidData))
    }
  }
  
  task.resume()
}
}
enum GFError: String, Error {
  case invalidUsername = "This username created an invalid url. Please try again"
  case unableToComplete = "Unable to complete request. Check your internet connection"
  case invalidResponse = "Invalid response from the server. Please try again"
  case invalidData = "Invalid data from the server. Please try again"
  case unableToFavorite = "There was an error favoriting this user. Please try again"
  case alreadyInFavorites = "You've already favorited this user. You must really like them"
}
