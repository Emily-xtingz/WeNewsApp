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
    case getPost(id: Int)
    case showCateNewsList(id: Int, page: Int)
    case submitComment(postId: Int, cookie: String, content: String)
    case searchForPost(search: String)
    case generateAuthCookie(username: String, password: String)
    case register(username: String, email: String, nonce: String, password: String)
    case createNonceForRegister
//    case getImage(url: String)
    case getUserMeta(cookie: String)
    case updateUserMeta(cookie: String, postIds: [Int])
}

//符合TargetType协议
extension  NetworkService: TargetType {
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    var baseURL : URL{
        let baseUrl = "https://do-sg.mluoc.tk/api/"
//        let baseUrl = "http://localhost:8888/wordpress/api"
        return  URL(string: baseUrl)!
    }
    
    var path: String {
        switch self {
        case .category:
            return "get_category_index/"
        case .getPost:
            return "get_post/"
        case .showCateNewsList:
            return "get_category_posts/"
        case .searchForPost:
            return "get_search_results/"
        case .submitComment:
            return "user/post_comment/"
        case .generateAuthCookie:
            return "user/generate_auth_cookie/"
        case .createNonceForRegister:
            return "get_nonce/?controller=user&method=register/"
        case .register:
            return "user/register/"
        case .getUserMeta:
            return "user/get_user_meta/"
        case .updateUserMeta:
            return "user/update_user_meta/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .category, .getPost, .showCateNewsList, .submitComment, .searchForPost, .generateAuthCookie, .createNonceForRegister, .register, .getUserMeta, .updateUserMeta:
            return .get
            //不需返回值
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .category:
            return nil
        case .getPost(let id):
            return ["id" : id]
        case .showCateNewsList(let id, let page):
            return ["id" : id, "page" : page, "count" : 5]
        case .submitComment(let postId, let cookie, let content):
            return ["post_id" : postId, "cookie" : cookie, "content" : content, "comment_status" : 1]
        case .searchForPost(let search):
            return ["search" : search]
        case .generateAuthCookie(let username, let password):
            return ["username" : username, "password" : password]
        case .register(let username, let email, let nonce, let password):
            return ["username" : username, "email" : email, "nonce" : nonce, "display_name" : username, "notify" : "both", "user_pass" : password]
        case .createNonceForRegister:
            return ["controller" : "user", "method" : "register"]
        case .getUserMeta(let cookie):
            return ["cookie" : cookie, "meta_key" : "favorite"]
        case .updateUserMeta(let cookie, let postIds):
            var ids = ""
            for postId in postIds {
                ids += "\(postId),"
            }
            return ["cookie" : cookie, "meta_key" : "favorites", "meta_value" : ids]
        }
    }
    
    var parameterEncoding: ParameterEncoding{
        switch self {
        case .category, .getPost, .showCateNewsList, .submitComment, .searchForPost, .generateAuthCookie, .createNonceForRegister, .register, .getUserMeta, .updateUserMeta:
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
        case .getPost(let id):
            return .requestParameters(parameters: ["id" : id], encoding: URLEncoding.queryString)
        case .showCateNewsList(let id, let page):
            return .requestParameters(parameters: ["id" : id, "page" : page, "count" : 5], encoding: URLEncoding.queryString)
           //一定要返回id,否则获取不了对应文章
        case .submitComment(let postID, let cookie, let content):
            return .requestParameters(parameters: ["post_id" : postID, "cookie" : cookie, "content" : content, "comment_status" : 1], encoding: URLEncoding.queryString)
        case .searchForPost(let search):
            return .requestParameters(parameters: ["search" : search], encoding: URLEncoding.queryString)
        case .generateAuthCookie(let username, let password):
            return .requestParameters(parameters: ["username" : username, "password" : password], encoding: URLEncoding.queryString)
        case .register(let username, let email, let nonce, let password):
            return .requestParameters(parameters: ["username" : username, "email" : email, "nonce" : nonce, "display_name" : username, "notify" : "both", "user_pass" : password], encoding: URLEncoding.queryString)
        case .createNonceForRegister:
            return .requestParameters(parameters: ["controller" : "user", "method" : "register"], encoding: URLEncoding.queryString)
        case .getUserMeta(let cookie):
            return .requestParameters(parameters: ["cookie" : cookie], encoding: URLEncoding.queryString)
        case .updateUserMeta(let cookie, let postIds):
            var ids = ""
            for postId in postIds {
                ids += "\(postId),"
            }
            return .requestParameters(parameters: ["cookie" : cookie, "meta_key" : "favorite", "meta_value" : ids], encoding: URLEncoding.queryString)
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
