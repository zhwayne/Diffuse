//
//  ShadowImageView.swift
//  Diffuse
//
//  Created by 张尉 on 2017/6/4.
//  Copyright © 2017年 zhwayne. All rights reserved.
//

import UIKit

class ShadowImageView: Diffuse {
    
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        self.addSubview(imageView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        imageView = UIImageView()
        self.addSubview(imageView!)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = bounds
    }
    
}
