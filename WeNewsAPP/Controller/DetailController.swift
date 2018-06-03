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
import JHSpinner

class DetailController: UIViewController {

    var webView: WKWebView!
    var post: Post!
    var isDanmuOn = true//弹幕开
    let statusBarFrame = UIApplication.shared.statusBarFrame//状态栏
    var isStared = false//未收藏
    
    @IBOutlet weak var danmuView: LeoDanmakuView!
    @IBOutlet weak var danmuSwitch: LLSwitch!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var starBtn: UIButton!
    
//    点击收藏按钮
    @IBAction func starBtnPressed(_ sender: Any) {
        //加载动画
        let spinner = JHSpinnerView.showOnView((UIApplication.shared.keyWindow?.subviews[0])!, spinnerColor: UIColor.red, overlay: .roundedSquare, overlayColor: UIColor.white.withAlphaComponent(0.6))
        spinner.tag = 1006
        
        if isStared == false {
            if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {
                
                let cookie = UserDefaults.standard.value(forKey: "cookie") as! String//帐号信息
                var postIds = UserDefaults.standard.value(forKey: "Favorites") as! [Int]
                postIds.append(self.post.id!)//添加新收藏的文章id
                
                Favorites.update(cookie: cookie, ids: postIds, completion: { (isSuccess) in
                    if isSuccess {//更新成功
                        UserDefaults.standard.set(postIds, forKey: "Favorites")//保存id到本地
                        self.deleteSpinner()
                        let banner = NotificationBanner(title: "Success", subtitle: "收藏成功！", style: .success)
                        banner.show()
                        self.starBtn.setImage(UIImage(named: "stared"), for: .normal)//收藏成功图标
                        NotificationCenter.default.post(name: NotificationHelper.updateList, object: nil)
                    } else {//更新失败
                        self.deleteSpinner()
                        let banner = NotificationBanner(title: "Error", subtitle: "收藏失败，请重试！", style: .warning)
                        banner.show()
                    }
                })
            } else {
                self.deleteSpinner()
                self.starBtn.setImage(UIImage(named: "unstared"), for: .normal)
                //初始化登录界面
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                //0.5秒后放到主线程中显示出来
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.present(loginVC, animated: true, completion: nil)//创建新页面present
                }
                let banner = NotificationBanner(title: "Error", subtitle: "请登录或注册！", style: .warning)
                banner.show()
            }
        } else if isStared == true {// 如果已被收藏，(再次点击时)
//            判断是否有用户信息
            if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {//有用户信息
                let cookie = UserDefaults.standard.value(forKey: "cookie") as! String
                var postIds = UserDefaults.standard.value(forKey: "Favorites") as! [Int]// 获取已收藏id
//                遍历id
                var temp = 0
                for postId in postIds {
                    if postId == self.post.id {
                        postIds.remove(at: temp)//移除收藏
                        break
                    }
                    temp += 1
                }
//                更新收藏
                Favorites.update(cookie: cookie, ids: postIds, completion: { (isSuccess) in
                    if isSuccess {
                        self.deleteSpinner()//去除动画
                        UserDefaults.standard.set(postIds, forKey: "Favorites")//存到收藏夹中
//                        显示取消收藏成功的通知
                        let banner = NotificationBanner(title: "Success", subtitle: "取消收藏成功！", style: .success)
                        banner.show()
                        self.starBtn.setImage(UIImage(named: "unstared"), for: .normal)
                    } else {
                        self.deleteSpinner()//去除动画
//                        显示取消收藏失败的通知
                        let banner = NotificationBanner(title: "Error", subtitle: "取消收藏失败，请重试！", style: .warning)
                        banner.show()
                    }
                })
            } else { //无用户信息
                self.deleteSpinner()
                starBtn.setImage(UIImage(named: "unstared"), for: .normal)// 设为未收藏图片
//                 初始化登录信息
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
//                放到主线程中0.5秒后加载
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.present(loginVC, animated: true, completion: nil)//跳转至登录页面
                }
                let banner = NotificationBanner(title: "Error", subtitle: "请登录或注册！", style: .warning)
                banner.show()
            }
        }
    }
    
//按下评论按钮
    @IBAction func commentBtnPressed(_ sender: Any) {
        doJavaScriptFunction()
    }
    
//    开始编辑评论文本框时，隐藏弹幕开关和评论按钮
    @IBAction func editBegin(_ sender: UITextField) {
        danmuSwitch.isHidden = true
        commentBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.hidesBarsOnSwipe = true
        commentField.returnKeyType = .send //按钮显示"发送"
        showCommentBadge(count: post.comment_count) //显示评论个数
        loadHTML()
        loadDanmu(comments: post.comments)
        
        danmuSwitch.delegate = self
        initStarBtn()//判断收藏按钮
    }
    
    //判断收藏按钮
    func initStarBtn() {
        if isStared {
            self.starBtn.setImage(UIImage(named: "stared"), for: .normal)//收藏过，修改收藏图片
        }
    }

//    加载弹幕
    func loadDanmu(comments:[Comment]? = nil,postAComment: String? = nil){
        if isDanmuOn {//如果弹幕打开
            danmuView.resume()
            
            if let comments = comments { //comments不为nil
                
//                map循环遍历，遍历comments数组里的每个值，然后分别赋值给danmus数组
                let danmus: [LeoDanmakuModel] = comments.map {
//                    生成随机弹幕
                    let model = LeoDanmakuModel.randomDanmku(withColors: UIColor.danmu, maxFontSize: 30, minFontSize: 15)
                    model?.text = $0.content.html2String
                    return model!
                }
                danmuView.addDanmaku(with: danmus)
            }
            if let comment = postAComment {//postAComment不为nil
                //生成随机弹幕
                let danmu = LeoDanmakuModel.randomDanmku(withColors: UIColor.danmu, maxFontSize: 30, minFontSize: 15)
                danmu?.text = comment
                danmuView.addDanmaku(danmu)//添加弹幕
            }
        } else {
            danmuView.stop()
        }
    }
    
    func loadHTML() {
        let frame: CGRect
        //判断是否是iPhoneX
        if statusBarFrame.height == 44 {
            frame = CGRect(x: 0, y: 44, width: view.layer.frame.width, height: view.frame.height - 44 - 45 - 34)
        } else {
            frame = CGRect(x: 0, y: 44, width: view.layer.frame.width, height: view.frame.height - 44 - 45)
        }
        webView = WKWebView(frame: frame)
        view.insertSubview(webView, at: 0)//插在对底层，弹幕在上面
        
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
        
        //页面下评论信息，包含评论账户和内容
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
        //显示内容
    }
    
    func showCommentBadge(count: Int) {
        if count > 0 {
            commentBtn.badgeCenterOffset = CGPoint(x: -4, y: 5)
            commentBtn.showBadge(with: .number, value: count, animationType: .none)
        }
    }
    
//    点击评论按钮，跳转至页面下的评论模块
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
    
    func deleteSpinner() {
        for view in (UIApplication.shared.keyWindow?.subviews[0].subviews)! {
            if view.tag == 1006 {
                view.removeFromSuperview()
            }
        }
    }
}

extension DetailController: UITextFieldDelegate {
//    按下发送按钮时调用textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //加载动画
        let spinner = JHSpinnerView.showOnView((UIApplication.shared.keyWindow?.subviews[0])!, spinnerColor: UIColor.red, overlay: .roundedSquare, overlayColor: UIColor.white.withAlphaComponent(0.6))
        spinner.tag = 1006
        
        if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {//有用户信息
            if let cookie = UserDefaults.standard.value(forKey: "cookie") as? String {//用户帐号信息
                if let commentText = textField.text {//如果textField有值
                    loadDanmu(postAComment: textField.text)//显示弹幕
//                     提交送评论到服务器，返回isSuccess, commentId
                    Post.postComment(postId: post.id!, cookie: cookie, content: commentText) { (isSuccess, commentId) in
                        if isSuccess {
                            var commentIds = UserDefaults.standard.value(forKey: "commentIds") as! [Int]
                            commentIds.append(commentId!)
                            UserDefaults.standard.set(commentIds, forKey: "commentIds")//存储到评论夹中
                            //更新评论
                            Comments.update(cookie: cookie, ids: commentIds, completion: { (isSuccess) in
                                if isSuccess {
                                    self.deleteSpinner()
                                    self.showCommentBadge(count: self.post.comment_count + 1)  //显示评论数加1
                                    self.post.comment_count = self.post.comment_count + 1  //文章评论数加1
                                    textField.text = ""
                                    NotificationCenter.default.post(name: NotificationHelper.updateList, object: nil)
                                    let banner = NotificationBanner(title: "Success", subtitle: "评论成功！", style: .success)
                                    banner.show()
                                } else {
                                    self.deleteSpinner()
                                    let banner = NotificationBanner(title: "Failure", subtitle: "同步评论失败！", style: .warning)
                                    banner.show()
                                }
                            })
                        } else {
                            self.deleteSpinner()
                            let banner = NotificationBanner(title: "Failure", subtitle: "评论失败，请重试！", style: .danger)
                            banner.show()
                        }
                    }
                    return true
                }
            }
        } else {
            self.deleteSpinner()
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.present(loginVC, animated: true, completion: nil)
            }
            let banner = NotificationBanner(title: "Error", subtitle: "请登录或注册！", style: .warning)
            banner.show()
        }
        return false
    }
    
//    点击文本框隐藏弹幕开关和评论按钮
    func textFieldDidBeginEditing(_ textField: UITextField) {
        danmuSwitch.isHidden = true
        commentBtn.isHidden = true
    }
    
    //关闭评论文本框，显示弹幕开关和评论按钮
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        danmuSwitch.isHidden = false
        commentBtn.isHidden = false
    }
}

//弹幕开关
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
