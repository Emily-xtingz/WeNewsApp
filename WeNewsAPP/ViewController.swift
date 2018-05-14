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
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var pageMenu: CAPSPageMenu!
    var controllers: [UIViewController] = []
    let statusBarFrame = UIApplication.shared.statusBarFrame
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var cates: [CategoryMO] = []
    var fc: NSFetchedResultsController<CategoryMO>!
    
//    @IBOutlet weak var resultLabel: UILabel!
//
//    @IBAction func cateBtnTap(_ sender: UIButton) {
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UINavigationBar.appearance().isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        fetchAllData()
        initPageMenu()
        DispatchQueue.init(label: "tech.mluoc.queueBackground", qos: .background, attributes: .concurrent).async {
            self.fetchFromNetwork()
        }
    }
    
    func fetchFromNetwork(){
        Category.request { (cates) in
            //创建分类菜单，以及每个导航栏的view
            //创建每个分类的viewcontroller
            self.cates = []
            for cate in cates! {
                let cateMO = CategoryMO(context: self.appDelegate.persistentContainer.viewContext)
                cateMO.count = Int16(cate.count)
                cateMO.id = Int16(cate.id)
                cateMO.title = cate.title
                self.cates.append(cateMO)
            }
            self.appDelegate.saveContext()
        }
    }
    
    func fetchAllData() {
        let request: NSFetchRequest<CategoryMO> = CategoryMO.fetchRequest()
        let sd = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sd]
        let context = appDelegate.persistentContainer.viewContext
        fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        do {
            try fc.performFetch()
            if let objectcs = fc.fetchedObjects {
                cates = objectcs
            }
        } catch {
            print(error)
        }
    }
    
    func initPageMenu() {
        //设置每个PageMenu属性
        self.controllers = cates.map {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SBID_NEWSLIST") as! NewsListController
            vc.title = $0.title
            vc.id = Int($0.id)
            vc.parentNavi = self.navigationController
            return vc
        }
        let param: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(4.3),
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .bottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .selectionIndicatorColor(UIColor(red: 242/255, green: 116/255, blue: 119/255, alpha: 1)),
            .menuMargin(20.0),
            .menuHeight(40.0),
//            .selectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .selectedMenuItemLabelColor(UIColor(red: 242/255, green: 116/255, blue: 119/255, alpha: 1)),
            .unselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .menuItemFont(UIFont(name: "HelveticaNeue-Medium", size: 17.0)!),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(true),
            .selectionIndicatorHeight(2.0),
            .menuItemSeparatorPercentageHeight(0.1),
            .menuItemWidth(80)
        ]
        //menu的位置
        let frame = CGRect(x: 0, y: self.statusBarFrame.height + 44, width: self.view.frame.width, height: self.view.frame.height - 44 - self.statusBarFrame.height)
        self.pageMenu = CAPSPageMenu(viewControllers: self.controllers, frame: frame, pageMenuOptions: param)
//            self.pageMenu = CAPSPageMenu(viewControllers: self.controllers, frame: frame, pageMenuOptions: [])
        
        //子view加入到父view中
        self.view.addSubview(self.pageMenu.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
