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

struct CategoryIndexResponse: Mappable{
    //3个属性
    var status: String? = nil
    var count: Int? = nil
    var categories: [Category]? = []
    
    init?(map: Map) {
    
    }
    
    mutating func mapping(map: Map) {
        status <- map["status"]
        count <- map["count"]
        categories <- map["categories"]
    }
}

struct Category: Mappable{
    var id: Int!
    var title: String!
    var count: Int!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        count <- map["post_count"]
    }
}

extension Category {
    //获取新闻分类
    //用completion进行封装，用@escapin跳出函数。
    static func request(completion: @escaping ([Category]?) -> Void ){
        let provider = MoyaProvider<NetworkService>()
        provider.request(.category){(result) in
            switch result {
            case .success(let moyaResponse):
                let json = try! moyaResponse.mapJSON() as! [String:Any]
                
                if let jsonResponse = CategoryIndexResponse(JSON:json){
                    //                 print(jsonResponse.count,jsonResponse.status,jsonResponse.categories)
                    completion(jsonResponse.categories)
                }
            case .failure:
                print("网络错误")
                completion(nil)
            }
        }
    }

}
