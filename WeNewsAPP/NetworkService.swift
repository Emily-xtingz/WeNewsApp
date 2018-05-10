//
//  NetworkService.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/19.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation
import Moya
//  Moya网络抽象层框架， 基于Alamofire的网络编程
//  https://github.com/Moya/Moya/blob/master/docs/Examples/Basic.md


enum NetworkService {
    case category
    case showCateNewsList(id: Int)
    case submitComment(postId: Int, name: String, email: String, content: String)
}

//符合TargetType协议
extension  NetworkService: TargetType {
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    var baseURL : URL{
        let baseUrl = "http://localhost:8888/wordpress/api"
        return  URL(string: baseUrl)!
    }
    
    var path: String {
        switch self {
        case.category:
            return "/get_category_index"
        case .showCateNewsList:
            return "/get_category_posts"
        case .submitComment:
            return "/respond/submit_comment"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .category, .showCateNewsList, .submitComment:
            return .get
            //不需返回值
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .category:
            return nil
        case .showCateNewsList(let id):
            return ["id" : id]
        case .submitComment(let postId, let name, let email, let content):
            return ["post_id" : postId, "name" : name, "email" : email, "content" : content]
        }
    }
    
    var parameterEncoding: ParameterEncoding{
        switch self {
        case .category, .showCateNewsList, .submitComment:
            return  URLEncoding.default
        }
    }
    
    var sampleData:Data {
        return "".utf8Encoded
//        switch self {
//        case .category:
//            return "category test data".utf8Encoded
//        case .showCateNewsList(let id):
//            return "newslist id is \(id)".utf8Encoded
//        }
    }
    
    var task: Task {
        switch self {
        case .category:
            return  .requestPlain
            //return .request 不成功 ????
        case .showCateNewsList(let id):
            return .requestParameters(parameters: ["id" : id], encoding: URLEncoding.queryString)
           //一定要返回id,否则获取不了对应文章
        case .submitComment(let postID, let name, let email, let content):
            return .requestParameters(parameters: ["post_id" : postID, "name" : name, "email" : email, "content" : content], encoding: URLEncoding.queryString)
        }
    }

}

// MARK: - Helpers
//对string的一个扩展，用于sampleData里的utf8Encoded
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
