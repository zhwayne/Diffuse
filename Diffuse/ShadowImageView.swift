//
//  ShadowImageView.swift
//  Diffuse
//
//  Created by 张尉 on 2017/6/4.
//  Copyright © 2017年 zhwayne. All rights reserved.
//

import UIKit

class MyImageView: UIImageView {
    
    override var image: UIImage? {
        set {
            imageCopy = newValue
            LazyTask { [weak self, imageCopy] in
                self?.layer.contents = imageCopy?.cgImage
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
        self.addSubview(imageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        imageView.clipsToBounds = true
        self.addSubview(imageView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
}
