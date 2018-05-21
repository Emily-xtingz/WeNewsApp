//
//  LoginViewController.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: RoundedCornerTextField!
    @IBOutlet weak var passwordTextField: RoundedCornerTextField!
    @IBOutlet weak var loginBtn: RoundedShadowButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        loginBtn.animateButton(shouldLoad: true, withMessage: nil)
        if emailTextField.text != "" && passwordTextField.text != "" {
            UserCookie.request(username: emailTextField.text!, password: passwordTextField.text!) { (cookie) in
                if let cookie = cookie {
                    UserDefaults.standard.set(cookie, forKey: "cookie")
                    UserDefaults.standard.set(true, forKey: "hasUserData")
                    UserDefaults.standard.set(self.emailTextField.text!, forKey: "name")
                    Favorites.get(cookie: cookie, completion: { (postIds) in
                        if let postIds = postIds {
                            UserDefaults.standard.set(postIds, forKey: "Favorites")
                            self.loginBtn.animateButton(shouldLoad: false, withMessage: "登录成功")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                self.dismiss(animated: true, completion: nil)
                            })
                            return
                        }
                    })
                } else {
                    NonceResponse.request(completion: { (nonce) in
                        if let nonce = nonce {
                            RegisterResponse.request(username: self.emailTextField.text!, email: self.emailTextField.text!, nonce: nonce, password: self.passwordTextField.text!, completion: { (isSuccess, cookie) in
                                if isSuccess {
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
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .join
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1003 {
            passwordTextField.becomeFirstResponder()
            return false
        } else {
            textField.resignFirstResponder()
//            self.loginBtn.animateButton(shouldLoad: true, withMessage: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loginBtnPressed(self)
            }
            return true
        }
    }
}
