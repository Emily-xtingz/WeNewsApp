//
//  Category.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/21.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya

//ObjectMapper,JSON解析库,对数据模型进行转换
//https://github.com/Hearst-DD/ObjectMapper

struct PostIndexResponse: Mappable {
    //3个属性
    var status: String!
    var count: Int?
    var posts: [Post]!
    var error: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        count <- map["count"]
        posts <- map["posts"]
        error <- map["error"]
    }
}

struct PostResponse: Mappable {
    var status: String!
    var post: Post?
    var error: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        post <- map["post"]
        error <- map["error"]
    }
}

//提交评论的反馈
struct SubmitResponse: Mappable {
    //3个属性
    var status: String?
    var error: String?
    var commentId: Int?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        error <- map["error"]
        commentId <- map["comment_id"]
    }
}

struct Comment: Mappable {
    var name: String!
    var content: String!
    var error: String?
    var post: Int?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        content <- map["content"]
        error <- map["error"]
        post <- map["post"]
    }
}

struct Post: Mappable{
    var status: String?
    var id: Int!
    var title: String!
    var content: String!
    var url: String!
    var comment_count: Int!
    var comments: [Comment]!
    var thumbnailImage: String!
    var error: String?
    
    init?(map: Map) {}
    //Swift 的 mutating 关键字修饰方法是为了能在该方法中修改 struct 或是 enum 的变量
    mutating func mapping(map: Map) {
        status <- map["status"]
        id <- map["id"]
        title <- map["title"]
        content <- map["content"]
        url <- map["url"]
        comment_count <- map["comment_count"]
        comments <- map["comments"]
        thumbnailImage <- map["thumbnail_images.full.url"]
        error <- map["error"]
    }
}

extension Post {
    //获取分类文章列表
    //用completion进行封装，学会用@escapin跳出函数。
    static func request(id: Int, page: Int, completion: @escaping ([Post]?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.showCateNewsList(id: id, page: page)){(result) in
            switch result {
            case let .success(moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                if let jsonResponse = PostIndexResponse(JSON:json){
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.posts)
                        print("请求文章列表成功")
                    } else {
                        print("请求文章列表失败")
                        completion(nil)
                        print(jsonResponse.error ?? "未知错误")
                    }
                }
            case .failure(let error):
                print("请求文章列表失败")
                completion(nil)
                print(error)
            }
        }
    }
    
    static func get(id: Int, completion: @escaping(Post?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.getPost(id: id)) { (result) in
            switch result {
            case let .success(moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                if let jsonResponse = PostResponse(JSON:json){
                    if jsonResponse.status == "ok" {
                        completion(jsonResponse.post)
                    } else {
                        print("请求文章失败")
                        completion(nil)
                        print(jsonResponse.error ?? "未知错误")
                    }
                }
            case .failure(let error):
                print("请求文章失败")
                completion(nil)
                print(error)
            }
        }
    }
    
    //提交评论
    static func postComment(postId: Int, cookie: String, content: String, completion: @escaping (Bool, Int?) -> Void){
        let provider = MoyaProvider<NetworkService>()
        provider.request(.postComment(postId: postId, cookie: cookie, content: content)) {(result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                if let jsonResponse = SubmitResponse(JSON:json){
                    if jsonResponse.status == "ok" {
                        completion(true, jsonResponse.commentId)
                        print("评论成功")
                    } else {
                        completion(false, nil)
                        print("评论失败")
                        print(jsonResponse.error ?? "未知错误")
                    }
                }
            case .failure:
                print("网络错误")
                completion(false, nil)
            }
        }
    }
    
    //搜索
    static func searchForPosts(search: String, completion: @escaping ([Post]?) -> Void) {
        let provider = MoyaProvider<NetworkService>()
        provider.request(.searchForPost(search: search)) { (result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                if let jsonResponse = PostIndexResponse(JSON:json){
                    completion(jsonResponse.posts)
                    print("搜索成功")
                }
            case .failure:
                print("网络错误")
                completion(nil)
            }
        }
    }
}
