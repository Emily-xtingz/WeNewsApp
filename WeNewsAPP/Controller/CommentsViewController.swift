//
//  CommentsViewController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/5/28.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import MJRefresh

class CommentsViewController: UITableViewController {

    var comments: [CommentResponse] = []
//    var posts: [Post] = []
//    var postNames: [String] = []
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackNormalFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 添加头部的下拉刷新
        header.setRefreshingTarget(self, refreshingAction: #selector(initComments))//加载后initComments
        tableView.mj_header = header
        header.beginRefreshing()
    }
    
    @objc func initComments() {
        if let commentIds = UserDefaults.standard.value(forKey: "commentIds") as? [Int] {//有评论id
            if commentIds.count != 0 {//数量大于零
                Comments.getComments(cookie: UserDefaults.standard.value(forKey: "cookie") as! String, ids: commentIds) { (comments) in
                    if let comments = comments {//获取评论
                        self.comments = comments
                        self.tableView.reloadData()//重新加载，显示评论
                        self.tableView.mj_header.endRefreshing()
                    }
                }
            } else {//评论数目为零
                let banner = NotificationBanner(title: "Error", subtitle: "您还没有发表过任何评论！", style: .warning)
                banner.show()
                tableView.mj_header.endRefreshing()
            }
        } else {//没有评论id
            let banner = NotificationBanner(title: "Error", subtitle: "您还没有发表过任何评论！", style: .warning)
            banner.show()
            tableView.mj_header.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count//返回评论数
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell

        cell.commentContentLabel.text = "评论内容：" + comments[indexPath.row].content.html2String

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
