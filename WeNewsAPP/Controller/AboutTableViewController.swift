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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        隐藏空白横线（生成空UIView）
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        initWaveView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "hasUserData") as? Bool == true {
            nameLabel.text = UserDefaults.standard.value(forKey: "name") as? String
        }
    }
    
    func initWaveView() {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: wave.frame.height)
        let waveView = YXWaveView(frame: frame, color: UIColor.white)
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 5.0
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        if let username = UserDefaults.standard.value(forKey: "name") as? String {
            nameLabel.text = username
        }
        
        wave.addSubview(waveView)
        waveView.addOverView(stackView)
        waveView.start()
        let tap = UITapGestureRecognizer(target: self, action: #selector(initLoginVC))
        waveView.addGestureRecognizer(tap)
    }

    @objc func initLoginVC() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = sectionContent[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

