//
//  ShadowImageView.swift
//  Diffuse
//
//  Created by 张尉 on 2017/6/4.
//  Copyright © 2017年 zhwayne. All rights reserved.
//

import UIKit
import RunloopTransaction

class MyImageView: UIImageView {
    
    override var image: UIImage? {
        set {
            imageCopy = newValue
            RLTransactionCommit {
                self.layer.contents = self.imageCopy?.cgImage
            }
        }
        get {
            return imageCopy
        }
    }
    
    private var imageCopy: UIImage?
}

class ShadowImageView: Diffuse {
    
    private(set) var imageView = MyImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.clipsToBounds = true
        contentView = imageView
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        imageView.clipsToBounds = true
        contentView = imageView
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16
    }    
}
