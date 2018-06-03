//
//  LoginViewController.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: RoundedCornerTextField!
    @IBOutlet weak var passwordTextField: RoundedCornerTextField!
    @IBOutlet weak var loginBtn: RoundedShadowButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        loginBtn.animateButton(shouldLoad: true, withMessage: nil)//按下按钮转圈圈
        if emailTextField.text != "" && passwordTextField.text != "" {
            UserCookie.request(username: emailTextField.text!, password: passwordTextField.text!) { (cookie) in
                if let cookie = cookie {//获取到
                    UserDefaults.standard.set(cookie, forKey: "cookie")//存储cookie
                    UserDefaults.standard.set(true, forKey: "hasUserData")
                    UserDefaults.standard.set(self.emailTextField.text!, forKey: "name")//账户名保存为name
                    //获取收藏id
                    Favorites.getFavorites(cookie: cookie, completion: { (postIds) in
                        if let postIds = postIds {
                            var favorites: [Int] = []
                            //string转换成int
                            for postId in postIds {
                                if let int = Int(postId) {
                                    favorites.append(int)
                                }
                            }
                            UserDefaults.standard.set(favorites, forKey: "Favorites")//存储收藏
                        }
                    })
                    //获取评论id
                    Comments.getUserComments(cookie: cookie, completion: { (commentIds) in
                        if let commentIds = commentIds {
                            UserDefaults.standard.set(commentIds, forKey: "commentIds")//存储id
                            self.loginBtn.animateButton(shouldLoad: false, withMessage: "登录成功")//显示登录成功
                            //2秒后登录页面消失
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                self.dismiss(animated: true, completion: nil)
                            })
                        }
                    })
                } else {//未获取到账户信息
                    NonceResponse.request(completion: { (nonce) in
                        if let nonce = nonce {
                            //注册
                            RegisterResponse.request(username: self.emailTextField.text!, email: self.emailTextField.text!, nonce: nonce, password: self.passwordTextField.text!, completion: { (isSuccess, cookie) in
                                if isSuccess {//注册成功
                                    if let cookie = cookie {
                                        UserDefaults.standard.set(cookie, forKey: "cookie")
                                        UserDefaults.standard.set(true, forKey: "hasUserData")
                                        UserDefaults.standard.set(self.emailTextField.text!, forKey: "name")
                                        self.loginBtn.animateButton(shouldLoad: false, withMessage: "注册成功")
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                            self.dismiss(animated: true, completion: nil)
                                        })
                                        return
                                    } else {
                                        let banner = NotificationBanner(title: "未知错误!", subtitle: "失败", style: .warning)
                                        banner.show()
                                        self.loginBtn.animateButton(shouldLoad: false, withMessage: "错误")
                                    }
                                } else {
                                    let banner = NotificationBanner(title: "注册失败!", subtitle: cookie, style: .warning)
                                    banner.show()
                                    self.loginBtn.animateButton(shouldLoad: false, withMessage: "失败")
                                }
                                
                            })
                        } else {
                            let banner = NotificationBanner(title: "未知错误!", subtitle: "失败", style: .warning)
                            banner.show()
                            self.loginBtn.animateButton(shouldLoad: false, withMessage: "错误")
                        }
                    })
                }
            }
        } else {
            let banner = NotificationBanner(title: "请输入!", subtitle: "请输入邮箱与密码。", style: .warning)
            banner.show()
            self.loginBtn.animateButton(shouldLoad: false, withMessage: "请输入")
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.returnKeyType = .next//键盘显示next
        passwordTextField.returnKeyType = .join//键盘显示join
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LoginViewController: UITextFieldDelegate {
    //按下return键执行
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1003 {//1003代表输入email时
            passwordTextField.becomeFirstResponder()//转到密码输入框
            return false//键盘不小时，急需输入
        } else {
            textField.resignFirstResponder()
//            self.loginBtn.animateButton(shouldLoad: true, withMessage: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loginBtnPressed(self)//登录
            }
            return true//键盘消失
        }
    }
}
