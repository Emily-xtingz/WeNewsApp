//
//  Comments.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/28.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya

struct Comments: Mappable {
    var status: String?
    var commentIds: [Int]? = []
    var error: String?
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        status <- map["status"]
        commentIds <- map["commentIds"]
        error <- map["error"]
    }
}

struct CommentResponse: Mappable {
    var id: Int!
    var post: Int!
    var content: String!
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        post <- map["post"]
        content <- map["content.rendered"]
    }
}

extension Comments {
    static func getUserComments(cookie: String, completion: @escaping([Int]?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.getUserMeta(cookie: cookie, key: "commentIds")) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String : Any]
                if let jsonResponse = Comments(JSON: json) {
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.commentIds)
                        print("获取用户评论成功")
                    } else {
                        completion(nil)
                        print("获取用户评论失败")
                        print(jsonResponse.error ?? "未知错误")
                    }
                } else {
                    completion(nil)
                    print("获取用户评论失败")
                }
            case .failure(let error):
                completion(nil)
                print("获取用户评论失败")
                print(error)
            }
        }
    }
    
    static func update(cookie: String, ids: [Int], completion: @escaping(Bool) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.updateUserMeta(cookie: cookie, ids: ids, key: "commentIds")) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String : Any]
                if let jsonResponse = Comments(JSON: json) {
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
    
    static func getComments(cookie: String, ids: [Int], completion: @escaping([CommentResponse]?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.searchComments(ids: ids)) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [[String : Any]]
                var comments: [CommentResponse] = []
                for i in json {
                    if let jsonResponse = CommentResponse(JSON:i) {
                        comments.append(jsonResponse)
                    } else {
                        completion(nil)
                        print("获取评论失败")
                    }
                }
                completion(comments)
                print("获取评论成功")
            case .failure(let error):
                completion(nil)
                print("获取评论失败")
                print(error)
            }
        }
    }
}

