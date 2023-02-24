//
//  ViewController.swift
//  ImageEditorSwift
//
//  Created by 郝振壹 on 2023/2/19.
//

import UIKit

class DemoViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func shareTouched(_ sender: Any) {
        let shareImage = UIImage(named: "demo.jpg")
        let items = [shareImage]
        
        let activityVC = UIActivityViewController(activityItems: items as [Any], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
}

