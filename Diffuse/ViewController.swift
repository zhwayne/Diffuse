//
//  ViewController.swift
//  Diffuse
//
//  Created by wayne on 2017/4/14.
//  Copyright © 2017年 zhwayne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate let images = ["timg-1", "timg-2", "timg-3", "timg-4", "timg-5", "timg-6",
                              "timg-2", "timg-3", "timg-4", "timg-5", "timg-6", "timg-1",
                              "timg-3", "timg-4", "timg-5", "timg-6", "timg-1", "timg-2",
                              "timg-4", "timg-5", "timg-6", "timg-1", "timg-2", "timg-3",
                              "timg-5", "timg-6", "timg-1", "timg-2", "timg-3", "timg-4",
                              "timg-6", "timg-1", "timg-2", "timg-3", "timg-4", "timg-5"]
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let `cell` = cell as! Cell
        
        cell.diffuse.backgroundColor = nil;
        cell.diffuse.shadow.opacity = 0.8
        cell.diffuse.shadow.offset = CGSize(width: 0, height: 25)
        cell.diffuse.shadow.range = 40
        cell.diffuse.shadow.level = 25
        cell.diffuse.shadow.brightness = 1
        cell.diffuse.shadow.customColor = UIColor.red
        cell.perform({ [unowned cell] in
            cell.diffuse.imageView?.image = UIImage(contentsOfFile: Bundle.main.path(forResource: self.images[indexPath.row], ofType: "jpeg")!)
            cell.diffuse.refresh()
        }, thread: Thread.main, mode: RunLoopMode.commonModes)
        
        cell.diffuse2.backgroundColor = nil;
        cell.diffuse2.shadow.opacity = 0.8
        cell.diffuse2.shadow.offset = CGSize(width: 0, height: 15)
        cell.diffuse2.shadow.range = 0
        cell.diffuse2.shadow.level = 20
        cell.diffuse2.shadow.brightness = 0.8
        cell.diffuse2.shadow.customColor = UIColor.red
        cell.perform({ [unowned cell] in
            cell.diffuse2.imageView?.image = UIImage(contentsOfFile: Bundle.main.path(forResource: self.images[indexPath.row], ofType: "jpeg")!)
            cell.diffuse2.refresh()
            }, thread: Thread.main, mode: RunLoopMode.commonModes)
    }
}


