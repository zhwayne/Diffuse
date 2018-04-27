//
//  Cell.swift
//  Diffuse
//
//  Created by wayne on 2017/4/14.
//  Copyright © 2017年 zhwayne. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    @IBOutlet weak var diffuse: ShadowImageView!
    @IBOutlet weak var diffuse2: ShadowImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        
        diffuse.center = CGPoint(x: bounds.midX * 0.5 , y: bounds.midY)
        diffuse2.center = CGPoint(x: bounds.midX * 1.5, y: bounds.midY)
    }
}
