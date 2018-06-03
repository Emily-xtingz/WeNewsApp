//
//  htmlToString.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/5/11.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation

//去掉html格式，显示评论时用到
extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding : String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch  {
            print(error)
            return nil
        }
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? "" 
    }
}
