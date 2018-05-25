//
//  NewsListController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/21.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import Cards
import NotificationBannerSwift
import YYCache
import ViewAnimator

class NewsListController: UITableViewController {

    var posts: [Post] = []
    var parentNavi: UINavigationController?
    var id = 0
    var page = 1
    var pageMax: Int!
    var superVC = ""
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackNormalFooter()
    var cards: [CardArticle] = []
    let cache: YYCache! = YYCache(name: "newsCache")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        header.beginRefreshing()
        
        if superVC == "main" {
            mainTableViewInit()
        } else {
            favoritesTableViewInit()
        }
    }
    
    func mainTableViewInit() {
        // 添加头部的下拉刷新
        header.setRefreshingTarget(self, refreshingAction: #selector(getData))
        tableView.mj_header = header
        
        // 添加底部的上拉加载
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerTrigger))
        tableView.mj_footer = footer
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NotificationHelper.updateList, object: nil)
        //        getData()
    }
    
    @objc func getData() {
        //获取对应分类文章列表
        //通过id采集到的文章
        page = 1
        Post.request(id: id, page: page) { (posts) in
            //如果文章有值，if true
            if let posts = posts {
                OperationQueue.main.addOperation { // 使他们处于同一进程
                    self.posts = posts
                    self.tableView.reloadData() //重新加载
                    print("网络请求成功")
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.mj_footer.resetNoMoreData()
                    self.tableView.animate(animations: [AnimationType.from(direction: .left, offset: 50.0)])
                    let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
                    let cells = self.tableView.visibleCells(in: 0)
                    UIView.animate(views: cells, animations: [fromAnimation], reversed: false, initialAlpha: 0.0, finalAlpha: 1.0, animationInterval: 0.3, duration: 1.0)
                }
            } else {
                let banner = NotificationBanner(title: "Error", subtitle: "网络错误！", style: .warning)
                banner.show()
                print("网络错误")
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    @objc func footerTrigger() {
        if page < pageMax {
            page = page + 1
            Post.request(id: id, page: page) { (posts) in
                //如果文章有值，if true
                if let posts = posts {
                    OperationQueue.main.addOperation { // 使他们处于同一进程
                        self.posts.append(contentsOf: posts)
                        self.tableView.reloadData() //重新加载
                        print("网络请求成功")
                        self.tableView.mj_footer.endRefreshing()
                    }
                } else {
                    let banner = NotificationBanner(title: "Error", subtitle: "网络错误！", style: .warning)
                    banner.show()
                    print("网络错误")
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            }
        } else {
            tableView.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    
    func favoritesTableViewInit() {
        // 添加头部的下拉刷新
        header.setRefreshingTarget(self, refreshingAction: #selector(getDataFromFavorites))
        tableView.mj_header = header
        
        tableView.mj_footer.endRefreshingWithNoMoreData()
        getDataFromFavorites()
    }
    
    @objc func getDataFromFavorites() {
        let ids = UserDefaults.standard.value(forKey: "Favorites") as! [Int]
        if ids.count != 0 {
            for id in ids {
                Post.get(id: id) { (post) in
                    if let post = post {
                        self.posts.append(post)
                        guard self.cache.containsObject(forKey: post.thumbnailImage) else {
                            let bq = BlockOperation.init {
                                let url = URL(string: post.thumbnailImage)
                                let request = URLRequest(url: url!)
                                let session = URLSession.shared
                                let dataTask = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                                    if error != nil{
                                        print(error.debugDescription)
                                    } else {
                                        //将图片数据赋予UIImage
                                        self.cache?.setObject(data! as NSCoding, forKey: post.thumbnailImage)
                                        OperationQueue.main.addOperation {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }) as URLSessionTask
                                dataTask.resume()
                            }
                            bq.queuePriority = .low
                            OperationQueue.init().addOperation(bq)
                            return
                        }
                        OperationQueue.main.addOperation {
                            self.tableView.reloadData()
                            self.tableView.mj_header.endRefreshing()
                            self.tableView.mj_footer.resetNoMoreData()
                        }
                    } else {
//                        let banner = NotificationBanner(title: "Error", subtitle: "网络错误！", style: .warning)
//                        banner.show()
                        print("网络错误")
                        self.tableView.mj_header.endRefreshing()
                    }
                }
            }
        } else {
            let banner = NotificationBanner(title: "Error", subtitle: "您还没有收藏任何文章！", style: .warning)
            banner.show()
            self.tableView.mj_header.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
        //返回数组值个数
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            } else {
                cell.cardView.downloadedFrom(link: post.thumbnailImage, cache: cache)
            }
        }
        
        registerForPreviewing(with: self, sourceView: cell.contentView)

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[tableView.indexPathForSelectedRow!.row]
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWS_DETAIL") as! DetailController
        if let postIds = UserDefaults.standard.value(forKey: "Favorites") as? [Int] {
            for postId in postIds {
                if postId == post.id {
                    detailVC.isStared = true
                }
            }
        }
        detailVC.title = post.title
        detailVC.post = post
        detailVC.hidesBottomBarWhenPushed = true

        tableView.deselectRow(at: indexPath, animated: true)
        
        parentNavi?.pushViewController(detailVC, animated: true)
        //引用上级的navigation
    }
}

extension NewsListController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPath(for: previewingContext.sourceView.superview as! UITableViewCell) {
            let post = posts[indexPath.row]
            let detailVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWS_DETAIL") as! DetailController
            detailVC.title = post.title
            detailVC.post = post
            return detailVC
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        parentNavi?.pushViewController(viewControllerToCommit, animated: true)
    }
}
