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
    case postComment(postId: Int, cookie: String, content: String)
    case searchForPost(search: String)
    case generateAuthCookie(username: String, password: String)
    case register(username: String, email: String, nonce: String, password: String)
    case createNonceForRegister
//    case getImage(url: String)
    case getUserMeta(cookie: String, key: String)
    case updateUserMeta(cookie: String, ids: [Int], key: String)
    case searchComments(ids:[Int])
    case changePassword(user_login: String)
}

//符合TargetType协议
extension  NetworkService: TargetType {
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    var baseURL : URL{
        let baseUrl = "https://do-sg.mluoc.tk/"
//        let baseUrl = "http://localhost:8888/wordpress/api/"
        return  URL(string: baseUrl)!
    }
    
    var path: String {
        switch self {
        case .category:
            return "api/get_category_index/"
        case .getPost:
            return "api/get_post/"
        case .showCateNewsList:
            return "api/get_category_posts/"
        case .searchForPost:
            return "api/get_search_results/"
        case .postComment:
            return "api/user/post_comment/"
        case .generateAuthCookie:
            return "api/user/generate_auth_cookie/"
        case .createNonceForRegister:
            return "api/get_nonce/"
        case .register:
            return "api/user/register/"
        case .getUserMeta:
            return "api/user/get_user_meta/"
        case .updateUserMeta:
            return "api/user/update_user_meta/"
        case .searchComments:
            return "wp-json/wp/v2/comments/"
        case .changePassword:
            return "api/user/retrieve_password/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .category, .getPost, .showCateNewsList, .postComment, .searchForPost, .generateAuthCookie, .createNonceForRegister, .register, .getUserMeta, .updateUserMeta, .searchComments, .changePassword:
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
        case .postComment(let postId, let cookie, let content):
            return ["post_id" : postId, "cookie" : cookie, "content" : content, "comment_status" : 1]
        case .searchForPost(let search):
            return ["search" : search]
        case .generateAuthCookie(let username, let password):
            return ["username" : username, "password" : password]
        case .register(let username, let email, let nonce, let password):
            return ["username" : username, "email" : email, "nonce" : nonce, "display_name" : username, "notify" : "both", "user_pass" : password]
        case .createNonceForRegister:
            return ["controller" : "user", "method" : "register"]
        case .getUserMeta(let cookie, let key):
            return ["cookie" : cookie, "meta_key" : key]
        case .updateUserMeta(let cookie, let ids, let key):
            var par = ""
            for id in ids {
                par += "\(id),"
            }
            return ["cookie" : cookie, "meta_key" : key, "meta_value" : par]
        case .searchComments(let ids):
            var par = ""
            var i = 1
            for id in ids {
                if i < ids.count {
                    par = par + "\(id),"
                    i += 1
                } else {
                    par = par + "\(id)"
                }
            }
            return ["include" : par]
        case .changePassword(let user_login):
            return ["user_login" : user_login]
        }
    }
    
    var parameterEncoding: ParameterEncoding{
        switch self {
        case .category, .getPost, .showCateNewsList, .postComment, .searchForPost, .generateAuthCookie, .createNonceForRegister, .register, .getUserMeta, .updateUserMeta, .searchComments, .changePassword:
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
        case .postComment(let postID, let cookie, let content):
            return .requestParameters(parameters: ["post_id" : postID, "cookie" : cookie, "content" : content, "comment_status" : 1], encoding: URLEncoding.queryString)
        case .searchForPost(let search):
            return .requestParameters(parameters: ["search" : search], encoding: URLEncoding.queryString)
        case .generateAuthCookie(let username, let password):
            return .requestParameters(parameters: ["username" : username, "password" : password], encoding: URLEncoding.queryString)
        case .register(let username, let email, let nonce, let password):
            return .requestParameters(parameters: ["username" : username, "email" : email, "nonce" : nonce, "display_name" : username, "notify" : "both", "user_pass" : password], encoding: URLEncoding.queryString)
        case .createNonceForRegister:
            return .requestParameters(parameters: ["controller" : "user", "method" : "register"], encoding: URLEncoding.queryString)
        case .getUserMeta(let cookie, let key):
            return .requestParameters(parameters: ["cookie" : cookie, "meta_key" : key], encoding: URLEncoding.queryString)
        case .updateUserMeta(let cookie, let ids, let key):
            var par = ""
            for id in ids {
                par += "\(id),"
            }
            return .requestParameters(parameters: ["cookie" : cookie, "meta_key" : key, "meta_value" : par], encoding: URLEncoding.queryString)
        case .searchComments(let ids):
            var par = ""
            var i = 1
            for id in ids {
                if i < ids.count {
                    par = par + "\(id),"
                    i += 1
                } else {
                    par = par + "\(id)"
                }
            }
            return .requestParameters(parameters: ["include" : par], encoding: URLEncoding.queryString)
        case .changePassword(let user_login):
            return .requestParameters(parameters: ["user_login" : user_login], encoding: URLEncoding.queryString)
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
