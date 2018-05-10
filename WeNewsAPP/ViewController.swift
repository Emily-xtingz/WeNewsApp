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
    var controllers: [UIViewController] = []
    
    
//    @IBOutlet weak var resultLabel: UILabel!
//
//    @IBAction func cateBtnTap(_ sender: UIButton) {
//    }
    
    func showMenu(){
        Category.request { (cates) in
            
            //创建分类菜单，以及每个导航栏的view
            //创建每个分类的viewcontroller
            self.controllers = cates!.map {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SBID_NEWSLIST") as! NewsListController
                vc.title = $0.title
                vc.id = $0.id
                vc.parentNavi = self.navigationController
                return vc
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
                .menuItemWidth(100)
            ]
            //menu的位置
            let frame = CGRect(x: 0, y: 20 + 44, width: self.view.frame.width, height: self.view.frame.height - 44 - 20)
            self.pageMenu = CAPSPageMenu(viewControllers: self.controllers, frame: frame, pageMenuOptions: param)
            
            //子view加入到父view中
            self.view.addSubview(self.pageMenu.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        showMenu()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
//test
