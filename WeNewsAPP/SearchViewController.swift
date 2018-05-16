//
//  SearchViewController.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var searchTextField: RoundedCornerTextField!
    
    var tableView = UITableView()
    var posts: [Post] = []
    var textFieldtext = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        hidesBottomBarWhenPushed = true
        searchTextField.delegate = self
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTextField {
            var y: CGFloat = 0
            if UIScreen.main.bounds.height == 812 {
                y = 180
            } else {
                y = 160
            }
            if tableView.frame.origin.y != y {
                tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40, height: view.frame.height - y)
                tableView.layer.cornerRadius = 5.0
                tableView.register(TextCell.self, forCellReuseIdentifier: "TextCell")
                
                tableView.delegate = self
                tableView.dataSource = self
                
                tableView.tag = 1004
                tableView.rowHeight = 60
                
                view.addSubview(tableView)
                animateTableView(shouldShow: true)
            }
        }
    }
    
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.5, animations: {
                if UIScreen.main.bounds.height == 812 {
                    self.tableView.frame = CGRect(x: 20, y: 220, width: self.view.frame.width - 40, height: self.view.frame.height - 220)
                } else {
                    self.tableView.frame = CGRect(x: 20, y: 180, width: self.view.frame.width - 40, height: self.view.frame.height - 180)
                }
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableView.frame = CGRect(x: 20, y: self.view.frame.height, width: self.view.frame.width - 40, height: self.view.frame.height - 180)
            }, completion: { (finished) in
                if finished {
                    for subview in self.view.subviews {
                        if subview.tag == 1004 {
                            subview.removeFromSuperview()
                        }
                    }
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            if searchTextField.text != textFieldtext {
                performSearch(searchWord: searchTextField.text!)
            }
            searchTextField.endEditing(true)
            textFieldtext = searchTextField.text!
        }
        return true
    }
    
    func performSearch(searchWord: String) {
        Post.searchForPosts(search: searchWord) { (posts) in
            if let posts = posts {
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        
        let post = posts[indexPath.row]
        cell.titleLabel?.text = post.title
        cell.commentLabel?.text = "评论：\(post.comment_count!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}