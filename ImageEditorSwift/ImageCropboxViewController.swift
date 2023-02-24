//
//  ImageCropboxViewController.swift
//  ImageEditorSwift
//
//  Created by 郝振壹 on 2023/2/19.
//

import UIKit

class ImageCropboxViewController: UIViewController {

    @IBOutlet weak var cropView: ImageCropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cropView.image = UIImage(named: "demo.jpg")
    }

    @IBSegueAction func showPreview(_ coder: NSCoder) -> UIViewController? {
        let vc = ImagePreviewViewController(coder: coder)
        vc?.image = cropView.image?.cropImage(cropView.cropbox)
        return vc
    }
    
    @IBAction func rawRatioTouched(_ sender: Any) {
        cropView.cropboxRatio = 0
    }
    
    @IBAction func ratio1on1Touched(_ sender: Any) {
        cropView.cropboxRatio = 1
    }
    
    @IBAction func ratio16To9Touched(_ sender: Any) {
        cropView.cropboxRatio = 16/9.0
    }
    
    @IBAction func ratio6To19Touched(_ sender: Any) {
        cropView.cropboxRatio = 9/16.0
    }
    
    @IBAction func rotationLeftTouched(_ sender: Any) {
        cropView.orientation = cropView.orientation.rotationLeft
    }
    
    @IBAction func rotationRightTouched(_ sender: Any) {
        cropView.orientation = cropView.orientation.rotationRight
    }
}
