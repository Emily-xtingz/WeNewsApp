//
//  SearchViewController.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import MJRefresh
import YYCache

class SearchViewController: UIViewController {

    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.isHidden = false
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    @IBOutlet weak var searchTextField: RoundedCornerTextField!
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    var textFieldtext = ""
    var isHidden = false
    var parentNavi: UINavigationController?
    let header = MJRefreshNormalHeader()
    let cache: YYCache! = YYCache(name: "newsList")

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.returnKeyType = .search
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10.0
        header.setRefreshingTarget(self, refreshingAction: #selector(performSearch))
        tableView.mj_header = header
    }
}

//MARK:  /**********TextField**********/
extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            performSearch()
            tableView.mj_header.beginRefreshing()
            searchTextField.endEditing(true)
            textFieldtext = searchTextField.text!
        }
        return true
    }
    
    @objc func performSearch() {
        if searchTextField.text != textFieldtext && searchTextField.text != "" {
            Post.searchForPosts(search: searchTextField.text!) { (posts) in
                if let posts = posts {
                    self.posts = posts
                    self.tableView.reloadData()
                    self.tableView.mj_header.endRefreshing()
                    for post in posts {
                        let isContain = self.cache.containsObject(forKey: post.thumbnailImage)
                        if !(isContain) {
                            let bq = BlockOperation.init {
                                let url = URL(string: post.thumbnailImage)
                                let request = URLRequest(url: url!)
                                let session = URLSession.shared
                                let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                                    if error != nil{
                                        print(error.debugDescription)
                                    } else {
                                        //将图片数据赋予UIImage
                                        self.cache.setObject(data! as NSCoding, forKey: post.thumbnailImage)
                                        OperationQueue.main.addOperation {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }) as URLSessionTask
                                dataTask.resume()
                            }
                            bq.queuePriority = .low
                            OperationQueue.init().addOperation(bq)
                        }
                    }
                }
            }
        }
    }
}

//MARK:  /**********TableView**********/
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        let post = posts[indexPath.row]
        
        cell.cardView.title = post.title
        cell.cardView.subtitle = "评论：\(post.comment_count!)"
        
        if let postIds = UserDefaults.standard.value(forKey: "Favorites") as? [Int] {
            for postId in postIds {
                if postId == post.id {
                    cell.starImage.image = UIImage(named: "stared")
                }
            }
        }
        if let image = post.thumbnailImage {
            if cache.containsObject(forKey: image) {
                cell.cardView.backgroundImage = UIImage(data: cache.object(forKey: post.thumbnailImage) as! Data)
            }
        }
        
//        registerForPreviewing(with: self, sourceView: cell.contentView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
