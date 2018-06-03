//
//  AboutTableViewController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import SafariServices
import YXWaveView
import NotificationBannerSwift
import JHSpinner
import MessageUI

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var wave: UIView!//上半部分view
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!//头像view
    @IBOutlet weak var nameLabel: UILabel!//账户标签
    
    var mailVC = MFMailComposeViewController()//反馈--发送邮件viewController
    var sectionTitle = ["友情链接", "反馈"]
    var sectionContent = [["央视新闻","腾讯新闻","今日头条"], ["在AppStore上给我们评分","反馈"]]
    var links = ["http://news.cctv.com","http://news.qq.com","https://m.toutiao.com"]
    let statusBarHight = UIApplication.shared.statusBarFrame.height
//    let tabBarHight: CGFloat = 49
    let naviBarHight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        隐藏空白横线（生成空UIView）
        tableView.tableFooterView = UIView(frame: CGRect.zero)//去掉多余线条，留白
    }
    
//  每次加载都会执行
    override func viewDidAppear(_ animated: Bool) {
        //账户名
        if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {
            nameLabel.text = UserDefaults.standard.value(forKey: "name") as? String
        }
        initWaveView()
    }
    
    func initWaveView() {
        if UserDefaults.standard.value(forKey: "hasUserData") as! Bool == true {
            sectionTitle = ["用户信息","友情链接","反馈"," "]
            sectionContent = [["我的收藏","我的评论"], ["央视新闻","腾讯新闻","今日头条"], ["在AppStore上给我们评分","反馈"], ["修改密码","注销"]]
            tableView.reloadData()
        } else {
            sectionTitle = ["友情链接", "反馈"]
            sectionContent = [["央视新闻","腾讯新闻","今日头条"], ["在AppStore上给我们评分","反馈"]]
            tableView.reloadData()
        }
        
//      设置上半部分样式
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: wave.frame.height)
        let waveView = YXWaveView(frame: frame, color: UIColor.white)
        waveView.stop()
        //头像属性
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
        //点击头像登录
        let tap = UITapGestureRecognizer(target: self, action: #selector(initLoginVC))
        if UserDefaults.standard.value(forKey: "hasUserData") as! Bool == false {
            waveView.addGestureRecognizer(tap)//若无帐号，添加
        }
    }

    @objc func initLoginVC() {
//        初始化登录界面，并显示
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionContent[section].count//返回section的行数
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
        if sectionTitle.count == 4 {
            if indexPath.section == 3 {
                cell.textLabel?.textColor = UIColor.red //修改密码和注销字体改为红色
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        未登录时，2个模块：友情链接和反馈评分
        if sectionTitle.count == 2 {
            switch indexPath.section {
            //        跳转safari应用
            case 0:
                if let url = URL(string: links[indexPath.row]) {//string链接转化为URL
                    let safariVC = SFSafariViewController(url: url)//初始化safariVC
                    present(safariVC, animated: true, completion: nil)//显示
                }
            case 1:
                if indexPath.row == 0 {
                    if let url = URL(string: "http://apple.com/itunes/charts/paid-apps") {
                        UIApplication.shared.open(url)
                    }
                } else {
                    if !MFMailComposeViewController.canSendMail() {//不能发邮件
                        print("Mail services are not available")
                        let banner = NotificationBanner(title: "Error", subtitle: "您的手机没有可发送邮件的账户。", style: .warning)
                        banner.show()
                    } else {//能发邮件
                        mailVC = MFMailComposeViewController()
                        mailVC.mailComposeDelegate = self//设置代理为self
                        mailVC.setToRecipients(["wordpress@mluoc.tk"])//设置发送邮箱
                        mailVC.setSubject("反馈")//设置发送标题
                        mailVC.setMessageBody("请详细描述Bug，如果有任何对产品方面的建议也欢迎反馈😋", isHTML: false)//设置发送内容
                        self.present(mailVC, animated: true, completion: nil)//显示
                    }
                }
            default:
                break
            }
        } else {// 已登录账号信息，有4个模块
            switch indexPath.section {
            case 0://查看收藏和评论
                if indexPath.row == 0 {
                    //初始化
                    let newsVC = storyboard?.instantiateViewController(withIdentifier: "SBID_NEWSLIST") as! NewsListController
                    newsVC.hidesBottomBarWhenPushed = true//隐藏tabBar
                    navigationController?.pushViewController(newsVC, animated: true)//navigationController显示页面
                    //设置tabView的样式
                    newsVC.tableView.frame = CGRect(x: 0, y: self.statusBarHight + self.naviBarHight, width: self.view.frame.width, height: self.view.frame.height - self.naviBarHight - self.statusBarHight)
                    newsVC.parentNavi = self.navigationController//navigationController推入收藏文章页面
                } else {
                    //初始化评论
                    let commentsVC = storyboard?.instantiateViewController(withIdentifier: "SBID_COMMENTS") as! CommentsViewController
                    commentsVC.hidesBottomBarWhenPushed = true//隐藏tabBar
                    navigationController?.pushViewController(commentsVC, animated: true)//navigationController显示页面
                }
//        跳转safari应用
            case 1:
                if let url = URL(string: links[indexPath.row]) {
                    let safariVC = SFSafariViewController(url: url)
                    present(safariVC, animated: true, completion: nil)
                }
            case 2:
                if indexPath.row == 0 {
                    if let url = URL(string: "http://apple.com/itunes/charts/paid-apps") {
                        UIApplication.shared.open(url)
                    }
                } else {
                    if !MFMailComposeViewController.canSendMail() {
                        print("Mail services are not available")
                        let banner = NotificationBanner(title: "Error", subtitle: "您的手机没有可发送邮件的账户。", style: .warning)
                        banner.show()
                    } else {
                        mailVC = MFMailComposeViewController()
                        mailVC.mailComposeDelegate = self
                        mailVC.setToRecipients(["wordpress@mluoc.tk"])
                        mailVC.setSubject("反馈")
                        mailVC.setMessageBody("请详细描述Bug，如果有任何对产品方面的建议也欢迎反馈😋", isHTML: false)
                        self.present(mailVC, animated: true, completion: nil)
                    }
                }
            case 3://修改密码和注销
                if indexPath.row == 0 {
                    if let name = UserDefaults.standard.value(forKey: "name") as? String {
                        let spinner = JHSpinnerView.showOnView((UIApplication.shared.keyWindow?.subviews[0])!, spinnerColor: UIColor.red, overlay: .roundedSquare, overlayColor: UIColor.white.withAlphaComponent(0.6))
                        spinner.tag = 1006
                        ChangePasswordResponse.changePassword(user_login: name) { (isSuccess) in
                            if isSuccess {
                                self.deleteSpinner()
                                let banner = NotificationBanner(title: "Success", subtitle: "请查收邮件，点击邮件中的链接修改密码。", style: .success)
                                banner.show()
                            } else {
                                self.deleteSpinner()
                                let banner = NotificationBanner(title: "Error", subtitle: "失败，请重试。", style: .warning)
                                banner.show()
                            }
                        }
                    }
                } else {
                    UserDefaults.standard.set(false, forKey: "hasUserData")
                    UserDefaults.standard.set("", forKey: "cookie")
                    UserDefaults.standard.set([], forKey: "Favorites")
                    initWaveView()
                    tableView.reloadData()
                    nameLabel.text = "请登录！"
                }
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)//点击行，反选
    }
    
//    邮件编辑完成
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        mailVC.dismiss(animated: true, completion: nil)
    }
    
//    删除加载动画
    func deleteSpinner() {
        for view in (UIApplication.shared.keyWindow?.subviews[0].subviews)! {
            if view.tag == 1006 {
                view.removeFromSuperview()
            }
        }
    }
}

