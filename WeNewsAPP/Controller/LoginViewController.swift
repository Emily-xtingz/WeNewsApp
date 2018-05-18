//
//  LoginViewController.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/15.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: RoundedCornerTextField!
    @IBOutlet weak var passwordTextField: RoundedCornerTextField!
    @IBOutlet weak var loginBtn: RoundedShadowButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            UserCookie.request(username: emailTextField.text!, password: passwordTextField.text!) { (cookie) in
                if let cookie = cookie {
                    UserDefaults.standard.set(cookie, forKey: "cookie")
                    UserDefaults.standard.set(true, forKey: "hasUserData")
                    Favorites.get(cookie: cookie, completion: { (postIds) in
                        if let postIds = postIds {
                            UserDefaults.standard.set(postIds, forKey: "Favorites")
                        }
                    })
                } else {
                    NonceResponse.request(completion: { (nonce) in
                        if let nonce = nonce {
                            RegisterResponse.request(username: self.emailTextField.text!, email: self.emailTextField.text!, nonce: nonce, password: self.passwordTextField.text!, completion: { (cookie) in
                                if let cookie = cookie {
                                    UserDefaults.standard.set(cookie, forKey: "cookie")
                                    UserDefaults.standard.set(true, forKey: "hasUserData")
                                }
                            })
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

        // Do any additional setup after loading the view.
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
            self.loginBtn.animateButton(shouldLoad: true, withMessage: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.loginBtnPressed(self)
            }
            return true
        }
    }
}
