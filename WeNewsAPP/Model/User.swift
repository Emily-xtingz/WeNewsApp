//
//  User.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/17.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya

//提交评论的反馈
struct UserCookie: Mappable{
    //3个属性
    var status: String?
    var cookie: String?
    var error: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        cookie <- map["cookie"]
        error <- map["error"]
    }
}

struct NonceResponse: Mappable{
    //3个属性
    var status: String?
    var nonce: String?
    var error: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        nonce <- map["nonce"]
        error <- map["error"]
    }
}

struct RegisterResponse: Mappable{
    //3个属性
    var status: String?
    var cookie: String?
    var error: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        cookie <- map["cookie"]
        error <- map["error"]
    }
}

extension UserCookie {
    static func request(username: String, password: String, completion: @escaping (String?) -> Void ){
        let provider = MoyaProvider<NetworkService>()
        provider.request(.generateAuthCookie(username: username, password: password)){(result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                if let jsonResponse = UserCookie(JSON:json) {
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.cookie)
                        print("用户授权成功")
                    } else {
                        
                    }
                }
            case .failure(let error):
                print("网络错误")
                print(error)
                completion(nil)
            }
        }
    }
}

extension NonceResponse {
    static func request(completion: @escaping(String?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.createNonceForRegister) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String : Any]
                if let jsonResponse = NonceResponse(JSON: json) {
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.nonce)
                        print("请求Nonce成功")
                    } else {
                        completion(nil)
                        print("请求Nonce失败")
                        print(jsonResponse.error ?? "未知错误")
                    }
                }
            case .failure(let error):
                print("网络错误")
                print(error)
                completion(nil)
            }
        }
    }
}

extension RegisterResponse {
    static func request(username: String, email: String, nonce: String, password: String, completion: @escaping(String?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.register(username: username, email: email, nonce: nonce, password: password)) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                if let jsonResponse = RegisterResponse(JSON: json) {
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.cookie)
                        print("注册成功")
                    } else {
                        completion(nil)
                        print("注册失败")
                        print(jsonResponse.error ?? "未知错误")
                    }
                }
            case .failure(let error):
                print("网络错误")
                print(error)
                completion(nil)
            }
        }
    }
}