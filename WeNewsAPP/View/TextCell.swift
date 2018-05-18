//
//  TextCell.swift
//  WeNewsAPP
//
//  Created by 婷婷 on 2018/3/26.
//  Copyright © 2018年 婷婷. All rights reserved.
//

import UIKit
import Cards

class TextCell: UITableViewCell {
    @IBOutlet weak var cardView: CardArticle!
    @IBOutlet weak var starImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
