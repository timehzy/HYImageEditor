//
//  UIImage+ImageEditor.swift
//  ImageEditorSwift
//
//  Created by DeGao on 2023/2/20.
//

import UIKit

extension UIImage {
    
    func cropImage(_ cropRect: CGRect) -> UIImage {
        let imageRawSize = CGSize(width: size.width*scale, height: size.height*scale)
        if cropRect.size == imageRawSize {
            return self
        }
        guard let cgImage = cgImage else { return self }
        guard let context = CGContext(data: nil,
                                      width: Int(cropRect.width),
                                      height: Int(cropRect.height),
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: cgImage.bytesPerRow,
                                      space: (cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB))!,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue)
        else { return self }
        
        guard let croppedImage = cgImage.cropping(to: cropRect) else { return self }
        context.draw(croppedImage, in: .init(origin: .zero, size: cropRect.size))
        guard let resultImage = context.makeImage() else { return self }
        return UIImage(cgImage: resultImage)
    }
}
