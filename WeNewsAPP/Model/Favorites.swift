//
//  Favorites.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/5/19.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya

struct Favorites: Mappable {
    var status: String?
    var favorite: [String]! = []
    var error: String?
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        status <- map["status"]
        favorite <- map["favorite.0"]
        error <- map["error"]
    }
}

extension Favorites {
//    获取收藏
    static func getFavorites(cookie: String, completion: @escaping([String]?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.getUserMeta(cookie: cookie, key: "favorite")) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String : Any]
                if let jsonResponse = Favorites(JSON: json) {
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.favorite)
                        print("获取收藏成功")
                    } else {
                        completion(nil)
                        print("获取收藏失败")
                        print(jsonResponse.error ?? "未知错误")
                    }
                } else {
                    completion(nil)
                    print("获取收藏失败")
                }
            case .failure(let error):
                completion(nil)
                print("获取收藏失败")
                print(error)
            }
        }
    }
 
//更新收藏    
    static func update(cookie: String, ids: [Int], completion: @escaping(Bool) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.updateUserMeta(cookie: cookie, ids: ids, key: "favorite")) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String : Any]
                if let jsonResponse = Favorites(JSON: json) {
                    if jsonResponse.status == "ok" {
                        completion(true)
                        print("用户参数更新成功")
                    } else {
                        completion(false)
                        print("用户参数更新失败")
                    }
                } else {
                    completion(false)
                    print("用户参数更新失败")
                }
            case .failure(let error):
                completion(false)
                print("用户参数更新失败")
                print(error)
            }
        }
    }
}
