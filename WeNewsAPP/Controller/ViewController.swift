//
//  ViewController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/19.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import Moya
import PageMenu

class ViewController: UIViewController {
    
    var pageMenu: CAPSPageMenu!
//    页面菜单
    var controllers: [UIViewController] = []
    var homeIndicatorHight: CGFloat = 0
//    iPhoneX手势条高度
    let statusBarHight = UIApplication.shared.statusBarFrame.height
//     状态栏高度
    let tabBarHight: CGFloat = 49
    let naviBarHight: CGFloat = 44
    
//    @IBOutlet weak var resultLabel: UILabel!
//
//    @IBAction func cateBtnTap(_ sender: UIButton) {
//    }
    
    func showMenu(){
        Category.request { (cates) in
            
            //创建分类菜单，以及每个导航栏的view
            //创建每个分类的viewcontroller
            self.controllers = cates!.map {
//                map循环遍历，遍历cates数组里的每个值，然后分别赋值给controllers数组
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SBID_NEWSLIST") as! NewsListController
//                 初始化NewsList
                vc.superVC = "main" //判断进入的方式，有首页和查看收藏两种方式
                vc.title = $0.title
                vc.id = $0.id
//              NewsList分页，5个为一页
                if $0.count % 5 == 0 {
                    vc.pageMax = $0.count / 5
                } else {
                    vc.pageMax = $0.count / 5 + 1  //多出文章，页数加1
                }
                vc.parentNavi = self.navigationController  // 把首页的导航栏赋给详情页
//                vc.tableView.frame = CGRect(x: 0, y: self.statusBarHight + self.tabBarHight, width: self.view.frame.width, height: self.view.frame.height - self.tabBarHight - self.naviBarHight - self.statusBarHight - self.homeIndicatorHight)
                return vc
//               return给 controllers
            }
            
            //设置每个PageMenu属性
            let param: [CAPSPageMenuOption] = [
                .menuItemSeparatorWidth(4.3),
                .scrollMenuBackgroundColor(UIColor.white),
                .viewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
                .bottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
                .selectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
                .menuMargin(20.0),
                .menuHeight(40.0),
                .selectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
                .unselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
                .menuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 17.0)!),
                .useMenuLikeSegmentedControl(false),
                .menuItemSeparatorRoundEdges(true),
                .selectionIndicatorHeight(2.0),
                .menuItemSeparatorPercentageHeight(0.1),
                .menuItemWidth(150)
            ]
            //menu的位置
            let frame = CGRect(x: 0, y: self.statusBarHight + self.naviBarHight, width: self.view.frame.width, height: self.view.frame.height - self.tabBarHight - self.naviBarHight - self.statusBarHight - self.homeIndicatorHight)
            self.pageMenu = CAPSPageMenu(viewControllers: self.controllers, frame: frame, pageMenuOptions: param)
//          初始化CAPSPageMenu
            
            //子view加入到父view中
            self.view.addSubview(self.pageMenu.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if statusBarHight == 44 {
            homeIndicatorHight = 34
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
//       导航栏返回按钮样式<
        showMenu()
        // Do any additional setup after loading the view, typically from a nib.
    }
//    转场，首页转到搜索页
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearch" {
            let dest = segue.destination as! SearchViewController  //目的地
            dest.parentNavi = self.navigationController
        }
    }
}
