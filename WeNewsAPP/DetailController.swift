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

class DetailController: UIViewController {

    var webView: WKWebView!
    var post: Post!
    var isDanmuOn = true
    let statusBarFrame = UIApplication.shared.statusBarFrame
    
    @IBOutlet weak var danmuView: LeoDanmakuView!
    @IBOutlet weak var danmuSwitch: LLSwitch!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBAction func commentBtnPressed(_ sender: Any) {
        doJavaScriptFunction()
    }
    
    @IBAction func editBegin(_ sender: UITextField) {
        danmuSwitch.isHidden = true
        commentBtn.isHidden = true
    }
    
    @IBAction func editEnd(_ sender: UITextField) {
        danmuSwitch.isHidden = false
        commentBtn.isHidden = false
        
        if let commentText = sender.text {
            loadDanmu(postAComment: sender.text)
            Post.submitComment(postId: post.id, name: "屁屁", email: "emily@xtingz.vip", content: commentText) { (isSuccess) in
                if isSuccess {
                    self.showCommentBadge(count: self.post.comment_count + 1)
                    sender.text = ""
                    NotificationCenter.default.post(name: NotificationHelper.updateList, object: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnSwipe = true
        
        showCommentBadge(count: post.comment_count)
        loadHTML()
        loadDanmu(comments: post.comments)
        
        danmuSwitch.delegate = self
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
            frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.height - 44 - 45 - 34)
        } else {
            frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.height - 44 - 45)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
