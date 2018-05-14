//
//  NewsListController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/21.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import CoreData

class NewsListController: UITableViewController, NSFetchedResultsControllerDelegate {

    var newsList: [Post] = []
    var parentNavi: UINavigationController?
    var id = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var posts: [PostMO] = []
    var fc: NSFetchedResultsController<PostMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFromNetwork()
        
        refreshControl = UIRefreshControl()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl?.addTarget(self, action: #selector(fetchFromNetwork), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFromNetwork), name: NotificationHelper.updateList, object: nil)
    }
    
    func fetchAllData() {
        let request: NSFetchRequest<PostMO> = PostMO.fetchRequest()
        let sd = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sd]
        let context = appDelegate.persistentContainer.viewContext
        fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        do {
            try fc.performFetch()
            if let objectcs = fc.fetchedObjects {
                posts = objectcs
            }
        } catch {
            print(error)
        }
    }
    
    @objc func fetchFromNetwork() {
        //获取对应分类文章列表
        //通过id采集到的文章
        posts = []
        Post.request(id: id) { (posts) in
            //如果文章有值，if true
            if let posts = posts {
                OperationQueue.main.addOperation { // 使他们处于同一进程
//                    self.posts = posts
//                    self.tableView.reloadData() //重新加载
//                    print("网络请求成功")
//                    self.refreshControl?.endRefreshing()
                    for post in posts {
                        let postMO = PostMO(context: self.appDelegate.persistentContainer.viewContext)
                        
                    }
                    self.posts = posts.map {
                        let postMO = PostMO(context: self.appDelegate.persistentContainer.viewContext)
                        postMO.id = Int16($0.id)
                        postMO.title = $0.title
                        postMO.url = $0.url
                        postMO.content = $0.content
                        postMO.relationship
                    }
                }
            } else {
                print("网络错误")
            }
        }
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

        let news = posts[indexPath.row]
        cell.titleLabel.text = news.title
        cell.commentLabel.text = "评论：\(news.comment_count)"

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsList[tableView.indexPathForSelectedRow!.row]
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWS_DETAIL") as! DetailController
        detailVC.title = news.title
        detailVC.post = news
        detailVC.hidesBottomBarWhenPushed = true

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
