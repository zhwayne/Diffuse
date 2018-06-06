//
//  LazyTask.swift
//  Diffuse
//
//  Created by 张尉 on 2018/5/29.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation


public typealias DispatchOnceToken = String

public extension DispatchQueue {
    
    private static var _onceTokenSet = Set<DispatchOnceToken>()
    
    public class func once(token: DispatchOnceToken, closure: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if _onceTokenSet.contains(token) {
            return
        }
        
        _onceTokenSet.insert(token)
        closure()
    }
}


public protocol TaskWrapable {
    var task: (() -> Void)? { get set }
}


public final class LazyTask {

    private static let queue = DispatchQueue(label: "commitQueue")
    private static var _taskSet = Array<LazyTask>()
    private var action: () -> Void
    
    @discardableResult
    init(_ action: @escaping () -> Void) {
        self.action = action
        self.commit()
    }

    
    private func commit() {
        LazyTask.queue.sync {
            LazyTask.listenRunloop(CFRunLoopGetMain())
            LazyTask._taskSet.append(self)
        }
    }
    
    private static func listenRunloop(_ runloop: CFRunLoop, activity: CFRunLoopActivity = [.beforeWaiting, .exit]) {
        
        DispatchQueue.once(token: "listenRunloop") {
            let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, activity.rawValue, true, 0xFFFFFF) { (observer, activity) in
                
                if _taskSet.count == 0 { return }
                
                let newTaskSet = _taskSet
                _taskSet.removeAll()
                
                newTaskSet.forEach { $0.action() }
            }
            
            CFRunLoopAddObserver(runloop, observer, .commonModes)
        }
    }
}
