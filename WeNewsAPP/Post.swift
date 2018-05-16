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

struct PostIndexResponse: Mappable{
    //3个属性
    var status: String?
    var count: Int?
    var posts: [Post]!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        count <- map["count"]
        posts <- map["posts"]
    }
}

//提交评论的反馈
struct SubmitResponse: Mappable{
    //3个属性
    var status: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
    }
}

struct Comment: Mappable {
    var name: String!
    var content: String!
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        content <- map["content"]
    }
}

struct Post: Mappable{
    var id: Int!
    var title: String!
    
    var content: String!
    var url: String!
    var comment_count: Int!
    var comments : [Comment]!
    
    init?(map: Map) {
        
    }
    //Swift 的 mutating 关键字修饰方法是为了能在该方法中修改 struct 或是 enum 的变量
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        
        content <- map["content"]
        url <- map["url"]
        comment_count <- map["comment_count"]
        comments <- map["comments"]
    }
}

extension Post {
    //获取分类文章列表
    //用completion进行封装，学会用@escapin跳出函数。
    static func request(id: Int, page: Int, completion: @escaping ([Post]?) -> Void ){
        let provider = MoyaProvider<NetworkService>()
        provider.request(.showCateNewsList(id: id, page: page)){(result) in
            switch result {
            case let .success(moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                if let jsonResponse = PostIndexResponse(JSON:json){
                    completion(jsonResponse.posts)
                }
            case .failure:
                print("网络错误")
                completion(nil)
            }
        }
    }
    
    //提交评论
    static func submitComment(postId: Int, name: String, email: String, content: String, completion: @escaping (Bool) -> Void){
        let provider = MoyaProvider<NetworkService>()
        provider.request(.submitComment(postId: postId, name: name, email: email, content: content)) {(result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]

                if let jsonResponse = SubmitResponse(JSON:json){
                    if jsonResponse.status == "ok" {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            case .failure:
                print("网络错误")
                completion(false)
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
                }
            case .failure:
                print("网络错误")
                completion(nil)
            }
        }
    }
}
