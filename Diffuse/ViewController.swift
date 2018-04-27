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
        let fpsLabel = FPSLabel(frame: CGRect.init(x: 15, y: 25, width: 80, height: 25))
        fpsLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        view.addSubview(fpsLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private let imageNames = { () -> [String] in
        let base = ["1", "2", "3", "4", "5", "6",
                    "2", "3", "4", "5", "6", "1",
                    "3", "4", "5", "6", "1", "2",
                    "4", "5", "6", "1", "2", "3",
                    "5", "6", "1", "2", "3", "4",
                    "6", "1", "2", "3", "4", "5"]

        return (0..<50).reduce([], { (res, idx) -> [String] in
            return res + base
        })
    }()
    
    private lazy var images = {
        return imageNames.map({ (imageName) -> Data? in
            guard let file = Bundle.main.path(forResource: imageName, ofType: "jpeg") else {
                return nil
            }
            return (NSData.init(contentsOfFile: file) as Data?)
        })
    }()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let `cell` = cell as! Cell
        
        cell.diffuse.backgroundColor = nil
        cell.diffuse.mode = .custom
        cell.diffuse.shadow.customColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.diffuse.shadow.opacity = 0.8
        cell.diffuse.shadow.offset = CGSize(width: 4, height: 8)
        cell.diffuse.shadow.range = 0
        cell.diffuse.shadow.level = 6
        cell.diffuse.shadow.brightness = 0.7
//        cell.diffuse.identify = "\(self.imageNames[indexPath.row])-0"
        if let data = self.images[indexPath.row] {
            cell.diffuse.imageView?.image = UIImage(data: data)
        }
        cell.diffuse.refresh()
        
        
        cell.diffuse2.backgroundColor = nil
        cell.diffuse2.shadow.opacity = 0.7
        cell.diffuse2.shadow.offset = CGSize(width: 0, height: 12)
        cell.diffuse2.shadow.range = -2
        cell.diffuse2.shadow.level = 10
        cell.diffuse2.shadow.brightness = 0.9
//        cell.diffuse2.identify = "\(self.imageNames[indexPath.row])-1"
        if let data = self.images[indexPath.row] {
            cell.diffuse2.imageView?.image = UIImage(data: data)
        }
        cell.diffuse2.refresh()
        
    }
}


