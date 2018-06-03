//
//  SearchViewController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import MJRefresh
import YYCache

class SearchViewController: UIViewController {

//    
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
    let header = MJRefreshNormalHeader() //搜索页面下拉刷新
    let cache: YYCache! = YYCache(name: "newsList")//缓存图片

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.returnKeyType = .search//搜索按键类型为search
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10.0
        header.setRefreshingTarget(self, refreshingAction: #selector(performSearch))//刷新时执行performSearch
        tableView.mj_header = header
    }
}

//MARK:  /**********TextField**********/
extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
//    点击搜索后动作
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
//        如果搜索框内容跟上次不同且不为空
        if searchTextField.text != textFieldtext && searchTextField.text != "" {
            Post.searchForPosts(search: searchTextField.text!) { (posts) in
                if let posts = posts { //有文章
                    self.posts = posts
                    self.tableView.reloadData() //重新加载
                    self.tableView.mj_header.endRefreshing() //加载完，结束刷新
                    for post in posts { //遍历
                        let isContain = self.cache.containsObject(forKey: post.thumbnailImage)
                        if !(isContain) {//如果没有图片链接
                            let bq = BlockOperation.init {//创建进程
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
                            bq.queuePriority = .low//进程优先级低
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
