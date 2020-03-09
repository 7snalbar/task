//
//  ViewController.swift
//  task
//
//  Created by Hasan Armoush on 3/8/20.
//  Copyright © 2020 Hasan Armoush. All rights reserved.
//

import UIKit
import GithubAPI
import Kingfisher
import OctoKit
class ViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    var searchString: String?
    
    var userResponse: OtherUserResponse?
    override func viewDidLoad() {
        super.viewDidLoad()
        initState()
        searchTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        configUserInterfaceViews()
    }
    
    func configUserInterfaceViews() {
        //profileImageView.makeCircular()
        // **********************************
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        followingCount.font = UIFont.systemFont(ofSize: 12)
        followersCount.font = UIFont.systemFont(ofSize: 12)
    }
    
    func initState() {
        profileImageView.isHidden = true
        usernameLabel.text = "Enter a name to search"
        followersCount.isHidden = true
        followingCount.isHidden = true
        separator.isHidden = true
        collectionView.isHidden = true
    }
    
    fileprivate func getUser(username: String) /*-> [UsersSearchItem]*/ {
        let authentication = AccessTokenAuthentication(access_token: "e560cef490861131aeadbc55354bb82e8183f24c")
        UserAPI(authentication: authentication).getUser(username: username) { (response, error) in
            if let response = response {
                if let id = response.id {
                    self.foundUserView(user: response)
                    self.getFollowers(username: self.searchString!, page: 1)
                } else {
                    self.initState()
                }
            } else {
                debugPrint(error ?? "")
            }
        }
    }
    
    var username: String!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var page = 1
    var hasMoreFollowers = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    
    private func getFollowers(username: String, page: Int) {
       isLoadingMoreFollowers = true
       // [weak self] aka capture list in closure to avoid memory leaks
       NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
         guard let self = self else { return }
         switch result {
         case .success(let followers):
           if followers.count < 100 { self.hasMoreFollowers = false }
           self.followers.append(contentsOf: followers)
           DispatchQueue.main.async {
            self.collectionView.reloadData()
           }
           // isEmpty is more efficient than .count == 0
           if self.followers.isEmpty {
             let message = "This user does not have any followers. Go follow them 😄"
             
             return
           }
           
         case .failure(let error):
            break
          
         }
         
         self.isLoadingMoreFollowers = false
       }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
     }
    private func resetFollowers() {
      page = 1
      followers.removeAll()
      filteredFollowers.removeAll()
      collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }

    func foundUserView(user: OtherUserResponse) {
        let url = URL(string: user.avatarUrl!)
        let username = user.login
        let followingCount = user.following!
        let newLine = "\n"
        let followingText = "\(String(describing: followingCount)) \(newLine) Following"
        let followersCount = user.followers!
        let followersText = "\(String(describing: followersCount)) \(newLine) Followers"
        DispatchQueue.main.async {
            self.profileImageView.kf.setImage(with: url)
            self.profileImageView.isHidden = false
            self.profileImageView.makeCircular()
            self.usernameLabel.text = username
            self.followingCount.text = followingText
            self.followingCount.isHidden = false
            self.followersCount.text = followersText
            self.followersCount.isHidden = false
            self.separator.isHidden = false
            self.collectionView.isHidden = false
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchString = textField.text
        getUser(username: (textField.text?.trimmingCharacters(in: .whitespaces))!)
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.searchTextField.text = ""
            self.initState()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
}
extension ViewController: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let offsetY = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height
    let height = scrollView.frame.size.height
    
    if offsetY > contentHeight - height {
      guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
      page += 1
        getFollowers(username: self.searchString!, page: page)
    }
  }
}
extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        debugPrint(self.followers.count)
        return self.followers.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! FollowerCell
        let url = URL(string: followers[indexPath.row].avatarUrl)
        cell.avatar.kf.setImage(with: url)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let collectionViewSize = collectionView.frame.size.width - padding

        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
}

extension UIImageView {
    func makeCircular() {
        self.contentMode = UIView.ContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
}
