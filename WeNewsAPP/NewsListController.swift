//
//  NewsListController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/21.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit


class NewsListController: UITableViewController {

    var newsList: [Post] = []
    var parentNavi: UINavigationController?
    var id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //获取对应分类文章列表
        //通过id采集到的文章
        Post.request(id: id) { (posts) in
            //如果文章有值，if true
            if let posts = posts {
                OperationQueue.main.addOperation { // 使他们处于同一进程
                    self.newsList = posts
                    self.tableView.reloadData() //重新加载
                    print("网络请求成功")
                }
            } else {
                print("网络错误")
            }
        }
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsList.count
        //返回数组值个数
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell

        let news = newsList[indexPath.row]
        cell.titleLabel.text = news.title
        cell.commentLabel.text = "评论：\(news.comment_count!)"

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsList[tableView.indexPathForSelectedRow!.row]
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWS_DETAIL") as! DetailController
        detailVC.title = news.title
        detailVC.post = news
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        parentNavi?.pushViewController(detailVC, animated: true)
        //引用上级的navigation
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
