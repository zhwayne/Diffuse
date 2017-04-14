//
//  Diffuse.swift
//  Diffuse
//
//  Created by wayne on 2017/4/14.
//  Copyright © 2017年 zhwayne. All rights reserved.
//

import UIKit
import CoreImage
import QuartzCore


/**
 A view with diffuse shadow effects.
 */
public class Diffuse: UIView {
    
    /// The mode for generating shadows
    public enum DiffuseMode {
        case auto
        case custom
    }
    
    /// Shadow properties.
    public struct Shadow {
        
        ///  The shadow opacity. Defaults to 0.8.
        public var opacity: CGFloat = 0.8 {
            didSet {
                if opacity < 0 {
                    opacity = 0
                } else if opacity > 1 {
                    opacity = 1
                }
            }
        }
        
        /// The shadow offset. Defaults to (0, 15).
        public var offset: CGSize = CGSize(width: 0, height: 15)
        
        /// The level used to set the blur of the shadow. Defaults to 20.
        public var level: CGFloat = 20 {
            didSet {
                if level < 0 {
                    level = 0
                }
            }
        }
        
        /// The range used to set the rendering range of the shadow. Defaults to 0.
        public var range: CGFloat = 0
        
        /// The brightness used to set the brightness of the shadows. The value 
        /// range is [0, 1]. Defaults to 1.
        public var brightness: CGFloat = 1 {
            didSet {
                if brightness < 0 {
                    brightness = 0
                } else if brightness > 1 {
                    brightness = 1
                }
            }
        }
        
        /// The customColor used to provide a shadow color when work on 
        /// DiffuseMode.custom.
        public var customColor: UIColor?
    }
    
    /// Used to set the mode for generating shadows. If you set it to `auto`, 
    /// it will automatically generate a picture as a shadow based on the 
    /// contents of the view.
    public var mode: DiffuseMode = .auto
    
    /// The contentView is used to set up a custom view to display the content. 
    /// All shadows also depend on this view.
    public var contentView: UIView! {
        didSet {
            if contentView != oldValue {
                if oldValue != nil {
                    oldValue.removeFromSuperview()
                }
                
                addSubview(contentView)
            }
        }
    }
    
    public override var backgroundColor: UIColor? {
        set {
            super.backgroundColor = newValue
            contentView?.backgroundColor = newValue
        } get {
            return super.backgroundColor
        }
    }
    
    public var shadow: Shadow = Shadow()
    
    private let shadowLayer: CALayer = CALayer()
    
    
    /// Once you have changed some properties, you need to call this method to 
    /// update the view for generating new shadows.
    final public func update() {
        DispatchQueue.main.async {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialize() {
        shadowLayer.contentsGravity = kCAGravityResizeAspectFill
        shadowLayer.contentsScale = UIScreen.main.scale
        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale
        layer.addSublayer(shadowLayer)
        
        let view = UIView()
        view.backgroundColor = (shadow.customColor ?? backgroundColor) ?? UIColor.groupTableViewBackground
        contentView = view
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        contentView.frame = bounds
        contentView.setNeedsUpdateConstraints()
        contentView.updateConstraintsIfNeeded()
 
        let shadowOriginImage: UIImage?
        
        if mode == .auto {
            shadowOriginImage = contentView.snapshot()?.light(level: shadow.brightness)
        } else {
            let view = UIView(frame: bounds)
            view.backgroundColor = shadow.customColor
            shadowOriginImage = view.snapshot()?.light(level: shadow.brightness)
        }
        
        let shadowWithSpaceImage = shadowOriginImage?.addTransparentSpace(10 + shadow.level)
        shadowWithSpaceImage?.blurAsync(level: shadow.level, complate: { (originImage, image) in
            var shadowBluredImage = image?.resize(byAdd: -(self.shadow.level));
            shadowBluredImage = shadowBluredImage?.resize(byAdd: self.shadow.range)
            let shadowSize = (shadowBluredImage != nil) ? shadowBluredImage!.size : self.bounds.size
            self.shadowLayer.contents = shadowBluredImage?.cgImage
            self.shadowLayer.opacity = Float(self.shadow.opacity)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.setAnimationDuration(0)
            self.shadowLayer.frame = CGRect(center: CGPoint(x: self.bounds.width / 2 + self.shadow.offset.width,
                                                       y: self.bounds.height / 2 + self.shadow.offset.height),
                                       size: shadowSize)
            CATransaction.commit()
        })
    }
}


fileprivate extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let point = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        self.init(origin: point, size: size)
    }
}

fileprivate extension UIView {
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: ctx)
        defer { UIGraphicsEndImageContext() }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}


fileprivate extension UIImage {
    
    func blurAsync(level: CGFloat, complate: @escaping (UIImage, UIImage?) -> Void) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            let image = self.blur(level: level)
            DispatchQueue.main.sync {
                complate(self, image)
            }
        }
    }
    
    func blur(level: CGFloat) -> UIImage? {
        
        guard self.cgImage != nil else { return nil }
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        
        let ciImage = CIImage(cgImage: self.cgImage!)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(level, forKey: kCIInputRadiusKey)
        let ctx = CIContext()
        if let outputImage = filter.outputImage,
            let cgImage = ctx.createCGImage(outputImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
        }
        
        return nil
    }
    
    func light(level: CGFloat) -> UIImage? {
        var alpha = 1 - level
        if alpha < 0 { alpha = 0 }
        if alpha > 1 { alpha = 1 }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect(origin: .zero, size: size)
        self.draw(in: rect)
        
        UIColor.black.withAlphaComponent(alpha).setFill()
        ctx?.addRect(rect)
        ctx?.fillPath()
        
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func addTransparentSpace(_ space: CGFloat) -> UIImage {
        
        guard space > 0 else { return self }
        
        let `space` = space * 2
        let newSize = CGSize(width: size.width + space, height: size.height + space)
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        UIColor.clear.setFill()
        ctx?.addRect(CGRect(origin: .zero, size: newSize))
        ctx?.fillPath()
        
        self.draw(in: CGRect(center: CGPoint(x: newSize.width / 2, y: newSize.height / 2),
                             size: size))
        
        defer { UIGraphicsEndImageContext() }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        
        return self
    }
    
    func resize(byAdd aWidth: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width + aWidth,
                             height: size.height * ((size.width + aWidth) / size.width))
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        defer { UIGraphicsEndImageContext() }
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        }
        
        return self
    }
}
