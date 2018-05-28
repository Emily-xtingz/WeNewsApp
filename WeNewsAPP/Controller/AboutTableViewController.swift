//
//  AboutTableViewController.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import SafariServices
import YXWaveView

class AboutTableViewController: UITableViewController {
    
    @IBOutlet weak var wave: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var sectionTitle = ["反馈","网页链接"]
    var sectionContent = [["在AppStore上给我们评分","个人主页"],["百度","新浪","淘宝"]]
    var links = ["https://www.baidu.com","https://www.sina.com","https://www.taobao.com"]
    let statusBarHight = UIApplication.shared.statusBarFrame.height
//    let tabBarHight: CGFloat = 49
    let naviBarHight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        隐藏空白横线（生成空UIView）
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {
            nameLabel.text = UserDefaults.standard.value(forKey: "name") as? String
        }
        initWaveView()
    }
    
    func initWaveView() {
        if UserDefaults.standard.value(forKey: "hasUserData") as! Bool == true {
            sectionTitle = ["用户信息","反馈","网页链接"," "]
            sectionContent = [["我的收藏","我的评论"], ["在AppStore上给我们评分","个人主页"], ["百度","新浪","淘宝"], ["注销"]]
            tableView.reloadData()
        } else {
            sectionTitle = ["反馈","网页链接"]
            sectionContent = [["在AppStore上给我们评分","个人主页"],["百度","新浪","淘宝"]]
            tableView.reloadData()
        }
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: wave.frame.height)
        let waveView = YXWaveView(frame: frame, color: UIColor.white)
        waveView.stop()
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 5.0
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        if let username = UserDefaults.standard.value(forKey: "name") as? String {
            if UserDefaults.standard.value(forKey: "hasUserData") as! Bool == true {
                nameLabel.text = username
            }
        }
        
        wave.addSubview(waveView)
        waveView.addOverView(stackView)
        waveView.start()
        let tap = UITapGestureRecognizer(target: self, action: #selector(initLoginVC))
        if UserDefaults.standard.value(forKey: "hasUserData") as! Bool == false {
            waveView.addGestureRecognizer(tap)
        }
    }

    @objc func initLoginVC() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionContent[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
        if sectionTitle.count == 4 {
            if indexPath.section == 3 {
                cell.textLabel?.textColor = UIColor.red
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if sectionTitle.count == 2 {
            switch indexPath.section {
            //        跳转safari应用
            case 0:
                if indexPath.row == 0 {
                    if let url = URL(string: "http://apple.com/itunes/charts/paid-apps") {
                        UIApplication.shared.open(url)
                    }
                } else {
                    //                performSegue(withIdentifier: "showWebView", sender: self)
                }
            //        内置safari
            case 1:
                if let url = URL(string: links[indexPath.row]) {
                    let safariVC = SFSafariViewController(url: url)
                    present(safariVC, animated: true, completion: nil)
                }
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    let newsVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWSLIST") as! NewsListController
                    newsVC.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(newsVC, animated: true)
                    newsVC.tableView.frame = CGRect(x: 0, y: self.statusBarHight + self.naviBarHight, width: self.view.frame.width, height: self.view.frame.height - self.naviBarHight - self.statusBarHight)
                } else {
                    let commentsVC = storyboard?.instantiateViewController(withIdentifier: "SBID_COMMENTS") as! CommentsViewController
                    commentsVC.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(commentsVC, animated: true)
                }
//        跳转safari应用
            case 1:
                if indexPath.row == 0 {
                    if let url = URL(string: "http://apple.com/itunes/charts/paid-apps") {
                        UIApplication.shared.open(url)
                    }
                } else {
//                performSegue(withIdentifier: "showWebView", sender: self)
                }
//        内置safari
            case 2:
                if let url = URL(string: links[indexPath.row]) {
                    let safariVC = SFSafariViewController(url: url)
                    present(safariVC, animated: true, completion: nil)
                }
            case 3:
                UserDefaults.standard.set(false, forKey: "hasUserData")
                UserDefaults.standard.set("", forKey: "cookie")
                initWaveView()
                tableView.reloadData()
                nameLabel.text = "请登录！"
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

