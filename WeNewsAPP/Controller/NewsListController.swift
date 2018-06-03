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
import JHSpinner

class NewsListController: UITableViewController {

    var posts: [Post] = []
    var parentNavi: UINavigationController?
    var id = 0
    var page = 1
    var pageMax: Int!
    var superVC = ""
    let header = MJRefreshNormalHeader() //下拉刷新
    let footer = MJRefreshBackNormalFooter() // 上拉加载更多内容
    var cards: [CardArticle] = [] //文章卡片
    let cache: YYCache! = YYCache(name: "newsCache") //缓存文章图片

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none//分割线
        header.beginRefreshing()//开始刷新
        
        if superVC == "main" {
            mainTableViewInit()
        } else {
            
            favoritesTableViewInit()
        }
    }
    
    func mainTableViewInit() {
        // 添加头部的下拉刷新
        header.setRefreshingTarget(self, refreshingAction: #selector(getData))//下拉刷新的时候执行getData()
        tableView.mj_header = header
        
        // 添加底部的上拉加载
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerTrigger))
        tableView.mj_footer = footer
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NotificationHelper.updateList, object: nil)
//        观察者模式，观察其他发出的通知，只要发出updateList通知就执行getData()
//        添加代码响应
    }
    
      //获取对应分类文章列表
    @objc func getData() {
        //通过id采集到的文章
        page = 1
        Post.request(id: id, page: page) { (posts) in
            //如果文章有值，if true
            if let posts = posts {
                OperationQueue.main.addOperation { // 使他们处于主线程,保证界面最快加载；网络请求等于视图无关的放其他线程
                    self.posts = posts
                    self.tableView.reloadData() //重新加载
                    print("网络请求成功")
                    self.tableView.mj_header.endRefreshing()//停止刷新
                    self.tableView.mj_footer.resetNoMoreData()// 重置上拉加载
//                    显示动画
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
//    底部加载页面
    @objc func footerTrigger() {
        if page < pageMax {
            page = page + 1
            Post.request(id: id, page: page) { (posts) in
                //如果文章有值，if true
                if let posts = posts {
                    OperationQueue.main.addOperation { // 使他们处于同一进程
                        self.posts.append(contentsOf: posts)//加在原有后面
                        self.tableView.reloadData() //重新加载
                        print("网络请求成功")
                        self.tableView.mj_footer.endRefreshing()//停止加载
                    }
                } else {
                    let banner = NotificationBanner(title: "Error", subtitle: "网络错误！", style: .warning)
                    banner.show()
                    print("网络错误")
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()//无更多内容
                }
            }
        } else {
            tableView.mj_footer.endRefreshingWithNoMoreData()//无更多内容
        }
    }
//    从收藏进入详情页
    func favoritesTableViewInit() {
        navigationController?.title = "收藏"
        //加载中的图标显示
        let spinner = JHSpinnerView.showOnView((UIApplication.shared.keyWindow?.subviews[0])!, spinnerColor: UIColor.red, overlay: .roundedSquare, overlayColor: UIColor.white.withAlphaComponent(0.6))
        spinner.tag = 1006

        getDataFromFavorites()
    }
//  收藏文章
    @objc func getDataFromFavorites() {
//        从本地存储中找出收藏文章(id)
        if let ids = UserDefaults.standard.value(forKey: "Favorites") as? [Int] {
            if ids.count != 0 {
                for id in ids {
                    Post.get(id: id) { (post) in //通过id获取文章
                        if let post = post {
                            self.posts.append(post)
                            self.tableView.reloadData()
//                            代码放入主线程，1秒后执行，留时间加载多个
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                self.deleteSpinner()//删除加载图标
                            })
                        } else {
                            let banner = NotificationBanner(title: "Error", subtitle: "网络错误！", style: .warning)
                            banner.show()
                            print("网络错误")
                            self.deleteSpinner()
                        }
                    }
                }
                print("获取收藏成功")
            } else {
                let banner = NotificationBanner(title: "Error", subtitle: "您还没有收藏任何文章！", style: .warning)
                banner.show()
                deleteSpinner()
            }
        } else {
            let banner = NotificationBanner(title: "Error", subtitle: "您还没有收藏任何文章！", style: .warning)
            banner.show()
            deleteSpinner()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
        //返回文章数组值个数
    }

//    每个cell的样式
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        获取可重用cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        let post = posts[indexPath.row]
        
        cell.cardView.title = post.title
        cell.cardView.subtitle = "评论：\(post.comment_count!)"
        
        if let postIds = UserDefaults.standard.value(forKey: "Favorites") as? [Int] {
            for postId in postIds {
                if postId == post.id {
//                    显示收藏
                    cell.starImage.image = UIImage(named: "stared")
                }
            }
        }
//        设置背景图片
        if let image = post.thumbnailImage {
//            如果存在图片对象
            if cache.containsObject(forKey: image) {
//                设置图片
                cell.cardView.backgroundImage = UIImage(data: cache.object(forKey: post.thumbnailImage) as! Data)
            } else {
                cell.cardView.downloadedFrom(link: post.thumbnailImage, cache: cache)//下载图片
            }
        }
        
        registerForPreviewing(with: self, sourceView: cell.contentView)//注册每个cell的3Dtouch

        return cell
    }

    // 点击cell，
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[tableView.indexPathForSelectedRow!.row]//获取该cell文章
        
//        初始化DetailController
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWS_DETAIL") as! DetailController
        if let postIds = UserDefaults.standard.value(forKey: "Favorites") as? [Int] {
            for postId in postIds {//遍历收藏文章的id
                if postId == post.id {
                    detailVC.isStared = true//ture,详情页的收藏图标变黄
                }
            }
        }
        detailVC.title = post.title
        detailVC.post = post
        detailVC.hidesBottomBarWhenPushed = true//隐藏tabBar

        tableView.deselectRow(at: indexPath, animated: true)//点击cell有动画，放开时取消动画
        
        parentNavi?.pushViewController(detailVC, animated: true)
        //引用上级的navigation，不需单独写；
        //显示DetailVC，自动识别DetailVC的title，navigationBar显示title，剩下显示DetailVC
    }
    
    func deleteSpinner() {
        for view in (UIApplication.shared.keyWindow?.subviews[0].subviews)! {
            if view.tag == 1006 {
                view.removeFromSuperview()
            }
        }
    }
}

//3D touch 实现的动作
extension NewsListController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPath(for: previewingContext.sourceView.superview as! UITableViewCell) {
            let post = posts[indexPath.row]
            let detailVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWS_DETAIL") as! DetailController
            if let postIds = UserDefaults.standard.value(forKey: "Favorites") as? [Int] {
                for postId in postIds {//遍历收藏文章的id
                    if postId == post.id {
                        detailVC.isStared = true//ture,详情页的收藏图标变黄
                    }
                }
            }
            detailVC.title = post.title
            detailVC.post = post
            return detailVC
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        parentNavi?.pushViewController(viewControllerToCommit, animated: true)//显示detailVC
        
    }
}
