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
import Accelerate


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
    
    public var shadow: Shadow = Shadow()
    
    private let shadowLayer: CALayer = CALayer()
    
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
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        refresh()
    }
    
    /// Once you have changed some properties, you need to call this method to
    /// update the view for generating new shadows.
    final public func refresh() {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            
            var shadowOriginImage: UIImage?
            
            if self.mode == .auto {
                shadowOriginImage = self.snapshot()
            } else {
                shadowOriginImage = self.shadow.customColor?.image(size: self.bounds.size)
            }
            shadowOriginImage = shadowOriginImage?.light(level: self.shadow.brightness)
            
            
            var shadowWithSpaceImage = shadowOriginImage?.addTransparentSpace(10 + self.shadow.level)
            shadowWithSpaceImage = shadowWithSpaceImage?.blur(level: self.shadow.level)
            
            var shadowBluredImage = shadowWithSpaceImage?.resize(byAdd: -(self.shadow.level));
            shadowBluredImage = shadowBluredImage?.resize(byAdd: self.shadow.range)
            let shadowSize = (shadowBluredImage != nil) ? shadowBluredImage!.size : self.bounds.size
            
            self.perform({[weak self] in
                guard self != nil else {
                    return
                }
                
                self!.shadowLayer.contents = shadowBluredImage?.cgImage
                self!.shadowLayer.opacity = Float(self!.shadow.opacity)
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                CATransaction.setAnimationDuration(0)
                self!.shadowLayer.frame = CGRect(center: CGPoint(x: self!.bounds.width / 2 + self!.shadow.offset.width,
                                                                 y: self!.bounds.height / 2 + self!.shadow.offset.height),
                                                 size: shadowSize)
                CATransaction.commit()
                
                }, thread: Thread.main, mode: RunLoopMode.commonModes)
        }
    }
}

public extension NSObject {
    func perform(_ block: () -> Void, thread: Thread, mode: RunLoopMode) {
        self.perform(#selector(performBlockWith(object:)), on: thread, with: block, waitUntilDone: false, modes: [mode.rawValue])
    }
    
    @objc private func performBlockWith(object: Any?) {
        (object as! (() -> Void))()
    }
}


public extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let point = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        self.init(origin: point, size: size)
    }
}

public extension UIView {
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        ctx.interpolationQuality = .low
        layer.render(in: ctx)
        // drawHierarchy(in: bounds, afterScreenUpdates: true)
        defer { UIGraphicsEndImageContext() }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
}


public extension UIImage {
    
    private var blurIterations: UInt {
        return 3
    }
    
    func blurAsync(level: CGFloat, complate: @escaping (UIImage, UIImage?) -> Void) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            let image = self.blur(level: level)
            complate(self, image)
        }
    }
    
    func blur(level: CGFloat) -> UIImage? {
        guard floorf(Float(size.width)) * floorf(Float(size.height)) > 0 else {
            return self
        }
        var boxSize = UInt32(level * scale)
        if boxSize % 2 == 0 {
            boxSize = boxSize + 1
        }
        
        var imageRef = cgImage
        if imageRef?.bitsPerPixel != 32 || imageRef?.bitsPerComponent != 8 || imageRef?.bitmapInfo.contains(.alphaInfoMask) == false {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(at: .zero)
            imageRef = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
        }
        
        guard imageRef != nil else {
            return self
        }
        
        var buffer1 = vImage_Buffer()
        var buffer2 = vImage_Buffer()
        buffer1.width = vImagePixelCount.init(imageRef!.width)
        buffer1.height = vImagePixelCount(imageRef!.height)
        buffer1.rowBytes = imageRef!.bytesPerRow
        buffer2.width = vImagePixelCount.init(imageRef!.width)
        buffer2.height = vImagePixelCount(imageRef!.height)
        buffer2.rowBytes = imageRef!.bytesPerRow
        
        let bytes = Int(buffer1.rowBytes * Int(buffer1.height))
        buffer1.data = malloc(bytes)
        buffer2.data = malloc(bytes)
        
        guard buffer1.data != nil && buffer2.data != nil else {
            free(buffer1.data)
            free(buffer2.data)
            return self
        }
        
        let provider = imageRef!.dataProvider
        let dataSource: CFData? = provider?.data
        guard dataSource != nil else {
            return self
        }
        
        let tempBuffer = malloc(Int(vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, nil, 0, 0, boxSize, boxSize, nil, vImage_Flags(kvImageEdgeExtend + kvImageGetTempBufferSize))))
        let dataSourceData = CFDataGetBytePtr(dataSource)
        let dataSourceLength = CFDataGetLength(dataSource)
        memcpy(buffer1.data, dataSourceData, min(bytes, dataSourceLength))
        
        for _ in 0..<blurIterations {
            vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, nil, vImage_Flags(kvImageEdgeExtend))
            
            let tmp = buffer1.data
            buffer1.data = buffer2.data
            buffer2.data = tmp
        }
        
        free(buffer2.data)
        free(tempBuffer)
        
        let ctx = CGContext.init(data: buffer1.data, width: Int(buffer1.width), height: Int(buffer1.height), bitsPerComponent: 8, bytesPerRow: buffer1.rowBytes, space: imageRef!.colorSpace!, bitmapInfo: imageRef!.bitmapInfo.rawValue)
        
        imageRef = ctx!.makeImage()
        let image = UIImage(cgImage: imageRef!, scale: scale, orientation: imageOrientation)
        free(buffer1.data)
        
        return image
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
}


extension UIImage {
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

extension UIColor {
    
    func image(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx?.fill(CGRect(origin: .zero, size: size))
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
