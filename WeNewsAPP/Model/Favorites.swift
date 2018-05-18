//
//  Favorites.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/19.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya

struct Favorites: Mappable {
    var status: String?
    var favorites: [Int]? = []
    var error: String?
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        status <- map["status"]
        favorites <- map["favorites"]
        error <- map["error"]
    }
}

extension Favorites {
    static func get(cookie: String, completion: @escaping([Int]?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.getUserMeta(cookie: cookie)) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String : Any]
                if let jsonResponse = Favorites(JSON: json) {
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.favorites)
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
    
    static func update(cookie: String, postIds: [Int], completion: @escaping(Bool) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.updateUserMeta(cookie: cookie, postIds: postIds)) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String : Any]
                if let jsonResponse = Favorites(JSON: json) {
                    if jsonResponse.status == "ok" {
                        completion(true)
                        print("收藏更新成功")
                    } else {
                        completion(false)
                        print("收藏更新失败")
                    }
                } else {
                    completion(false)
                    print("收藏更新失败")
                }
            case .failure(let error):
                completion(false)
                print("收藏更新失败")
                print(error)
            }
        }
    }
}