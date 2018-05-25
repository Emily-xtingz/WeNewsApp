//
//  CardView.swift
//  WeNewsAPP
//
//  Created by 闵罗琛 on 2018/5/21.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import Foundation
import Cards
import YYCache

extension CardArticle {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleToFill, cache: YYCache) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded cat picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                        // Do something with your image.
                        cache.setObject(imageData as NSCoding, forKey: url.absoluteString)
                        DispatchQueue.main.async() { () -> Void in
                            self.backgroundImage = image
                        }
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
            
            }.resume()
        
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, cache: YYCache) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode, cache: cache)
    }
}
