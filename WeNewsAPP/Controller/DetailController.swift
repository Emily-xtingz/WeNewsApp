//
//  DetailController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/26.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import WebKit
import LeoDanmakuKit
import LLSwitch
import WZLBadge
import NotificationBannerSwift
//import Cosmos

class DetailController: UIViewController {

    var webView: WKWebView!
    var post: Post!
    var isDanmuOn = true
    let statusBarFrame = UIApplication.shared.statusBarFrame
    var isStared = false
    
    @IBOutlet weak var danmuView: LeoDanmakuView!
    @IBOutlet weak var danmuSwitch: LLSwitch!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var starBtn: UIButton!
    
    @IBAction func starBtnPressed(_ sender: Any) {
        if isStared == false {
            if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {
                let cookie = UserDefaults.standard.value(forKey: "cookie") as! String
                var postIds = UserDefaults.standard.value(forKey: "Favorites") as! [Int]
                postIds.append(self.post.id)
                Favorites.update(cookie: cookie, postIds: postIds, completion: { (isSuccess) in
                    if isSuccess {
                        UserDefaults.standard.set(postIds, forKey: "Favorites")
                        let banner = NotificationBanner(title: "Success", subtitle: "收藏成功！", style: .success)
                        banner.show()
                        self.starBtn.setImage(UIImage(named: "stared"), for: .normal)
                    } else {
                        let banner = NotificationBanner(title: "Error", subtitle: "收藏失败，请重试！", style: .warning)
                        banner.show()
                    }
                })
            } else {
                self.starBtn.setImage(UIImage(named: "unstared"), for: .normal)
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.present(loginVC, animated: true, completion: nil)
                }
                let banner = NotificationBanner(title: "Error", subtitle: "请登录或注册！", style: .warning)
                banner.show()
            }
        } else if isStared == true {
            if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {
                let cookie = UserDefaults.standard.value(forKey: "cookie") as! String
                var postIds = UserDefaults.standard.value(forKey: "Favorites") as! [Int]
                var temp = 0
                for postId in postIds {
                    if postId == self.post.id {
                        postIds.remove(at: temp)
                        break
                    }
                    temp += 1
                }
                Favorites.update(cookie: cookie, postIds: postIds, completion: { (isSuccess) in
                    if isSuccess {
                        UserDefaults.standard.set(postIds, forKey: "Favorites")
                        let banner = NotificationBanner(title: "Success", subtitle: "取消收藏成功！", style: .success)
                        banner.show()
                        self.starBtn.setImage(UIImage(named: "unstared"), for: .normal)
                    } else {
                        let banner = NotificationBanner(title: "Error", subtitle: "取消收藏失败，请重试！", style: .warning)
                        banner.show()
                    }
                })
            } else {
                starBtn.setImage(UIImage(named: "unstared"), for: .normal)
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.present(loginVC, animated: true, completion: nil)
                }
                let banner = NotificationBanner(title: "Error", subtitle: "请登录或注册！", style: .warning)
                banner.show()
            }
        }
    }
    
    @IBAction func commentBtnPressed(_ sender: Any) {
        doJavaScriptFunction()
    }
    
    @IBAction func editBegin(_ sender: UITextField) {
        danmuSwitch.isHidden = true
        commentBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.hidesBarsOnSwipe = true
        commentField.returnKeyType = .send
        showCommentBadge(count: post.comment_count)
        loadHTML()
        loadDanmu(comments: post.comments)
        
        danmuSwitch.delegate = self
        initStarBtn()
    }
    
    func initStarBtn() {
        if isStared {
            self.starBtn.setImage(UIImage(named: "stared"), for: .normal)
        }
    }

    func loadDanmu(comments:[Comment]? = nil,postAComment: String? = nil){
        if isDanmuOn {
            danmuView.resume()
            if let comments = comments {
                let danmus: [LeoDanmakuModel] = comments.map {
                    let model = LeoDanmakuModel.randomDanmku(withColors: UIColor.danmu, maxFontSize: 30, minFontSize: 15)
                    model?.text = $0.content.html2Sting
                    return model!
                }
                danmuView.addDanmaku(with: danmus)
            }
            if let comment = postAComment {
                let danmu = LeoDanmakuModel.randomDanmku(withColors: UIColor.danmu, maxFontSize: 30, minFontSize: 15)
                danmu?.text = comment
                danmuView.addDanmaku(danmu)
            }
        } else {
            danmuView.stop()
        }
    }
    
    func loadHTML() {
        let frame: CGRect
        if statusBarFrame.height == 44 {
            frame = CGRect(x: 0, y: 44, width: view.layer.frame.width, height: view.frame.height - 44 - 45 - 34)
        } else {
            frame = CGRect(x: 0, y: 44, width: view.layer.frame.width, height: view.frame.height - 44 - 45)
        }
        webView = WKWebView(frame: frame)
        view.insertSubview(webView, at: 0)
        
        //        用html来调节页面样式
        //        两个"""之间的所有内容都表示字符串
        let header = """
            <html>
                <body>
                    <head>
                        <script src="https://cdn.bootcss.com/jquery/3.3.1/jquery.min.js"></script>
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <style>
                            img {width : 100%}
                            body {font-size: 100%}
                        </style>
        """
        //, maximum-scale=1.0, user-scalable=0
        let footer = """
                    </head>
                </body>
            </html>
        """
        
        var comments: String {
            var result = "<hr id=\"commentAnchor\">"
            for comment in post.comments {
                let paragraph = "<p> <h6>\(comment.name!)</h6> <h5> \(comment.content!) </h5> <hr> </p>"
                result += paragraph
            }
            return result
        }
        
        //        webView.load(URLRequest(url: url))
        webView.loadHTMLString(header + post.content + comments + footer, baseURL: nil)
    }
    
    func showCommentBadge(count: Int) {
        if count > 0 {
            commentBtn.badgeCenterOffset = CGPoint(x: -4, y: 5)
            commentBtn.showBadge(with: .number, value: count, animationType: .none)
        }
    }
    
    func doJavaScriptFunction() {
//        let js = """
//        $(document).ready(function(){
//            $("p").click(function(){
//                $(this).hide()})
//        })
//        """
        let js = "window.location.hash = \"commentAnchor\""
        webView.evaluateJavaScript(js) { (result, error) in
            print("js执行结果：", result, error)
        }
    }
}

extension DetailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        danmuSwitch.isHidden = false
        commentBtn.isHidden = false
        
        if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {
            if let cookie = UserDefaults.standard.value(forKey: "cookie") as? String {
                if let commentText = textField.text {
                    loadDanmu(postAComment: textField.text)
                    Post.submitComment(postId: post.id, cookie: cookie, content: commentText) { (isSuccess) in
                        if isSuccess {
                            self.showCommentBadge(count: self.post.comment_count + 1)
                            self.post.comment_count = self.post.comment_count + 1
                            textField.text = ""
                            NotificationCenter.default.post(name: NotificationHelper.updateList, object: nil)
                            let banner = NotificationBanner(title: "Success", subtitle: "评论成功！", style: .success)
                            banner.show()
                        }
                    }
                    return true
                }
            }
        } else {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(loginVC, animated: true, completion: nil)
            }
            let banner = NotificationBanner(title: "Error", subtitle: "请登录或注册！", style: .warning)
            banner.show()
        }
        return false
    }
}

extension DetailController: LLSwitchDelegate {
    func didTap(_ llSwitch: LLSwitch!) {
        if isDanmuOn {
            danmuSwitch.setOn(false, animated: true)
            danmuView.stop()
            danmuView.isHidden = true
        } else {
            danmuSwitch.setOn(true, animated: true)
            danmuView.resume()
            danmuView.isHidden = false
        }
        isDanmuOn = !isDanmuOn
    }
}
