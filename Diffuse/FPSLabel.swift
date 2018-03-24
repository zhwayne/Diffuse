//
//  FPSLabel.swift
//  Diffuse
//
//  Created by 张尉 on 2018/3/24.
//  Copyright © 2018年 zhwayne. All rights reserved.
//

import UIKit

class FPSLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private var link: CADisplayLink!
    private var lastTime: TimeInterval = 0
    private var count = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        link = CADisplayLink(target: self, selector: #selector(tick(sender:)))
        link.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        link.invalidate()
    }
    
    @objc func tick(sender: CADisplayLink) {
        if lastTime == 0 {
            lastTime = sender.timestamp
            return
        }
        
        count += 1
        let d = sender.timestamp - lastTime
        if d < 1 { return }
        lastTime = sender.timestamp
        let fps = Double(count) / d
        count = 0
        
        self.text = "\(Int(round(fps))) fps"
    }

}
