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

class DetailController: UIViewController {

    var webView: WKWebView!
    var url: URL!
    var content: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHTML()
    }
    func loadDanmu(comments:[Comment]? = nil,postAComment: String?){
        
    }
    
    
    func loadHTML() {
        let frame = CGRect(x: 0, y: 44, width: view.frame.width, height: view.frame.height - 44 - 45)
        webView = WKWebView(frame: frame)
        view.insertSubview(webView, at: 0)
        
        //        用html来调节页面样式
        //        两个"""之间的所有内容都表示字符串
        var header = """
<html>
<body>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
img {width : 100%}
body {font-size: 100%}
</style>
"""
        //, maximum-scale=1.0, user-scalable=0
        var footer = """
</head>
</body>
</html>
"""
        
        //        webView.load(URLRequest(url: url))
        webView.loadHTMLString(header + content + footer, baseURL: nil)
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
