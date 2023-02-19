//
//  ImageEditProtocol.swift
//  ImageEditorOC
//
//  Created by 郝振壹 on 2023/2/19.
//

import UIKit

enum ImageOrientation: CGFloat {
case up=0, right=90, down=180, left=270
    
    var radian: CGFloat {
        rawValue*CGFloat.pi/180
    }
    
    var isHorizontal: Bool {
        self == .left || self == .right
    }
    
    var rotationLeft: ImageOrientation {
        ImageOrientation(rawValue: (rawValue + 270).truncatingRemainder(dividingBy: 360))!
    }
    
    var rotationRight: ImageOrientation {
        ImageOrientation(rawValue: (rawValue + 90).truncatingRemainder(dividingBy: 360))!
    }
}

protocol CoordinateSpaceConvertable: UIView {
    var image: UIImage? { get }
    var imageSize: CGSize { get }
    var cropbox: ImageCropbox { get }
    var orientation: ImageOrientation { get }
    var imageToViewScale: CGFloat { get }
    
    func convertToImageCoordinateSpace(_ length: CGFloat) -> CGFloat
    func convertToImageCoordinateSpace(_ point: CGPoint) -> CGPoint
    func convertToImageCoordinateSpace(_ size: CGSize) -> CGSize
    func convertToImageCoordinateSpace(_ rect: CGRect) -> CGRect
    
    func convertToViewCoordinateSpace(_ length: CGFloat) -> CGFloat
    func convertToViewCoordinateSpace(_ point: CGPoint) -> CGPoint
    func convertToViewCoordinateSpace(_ size: CGSize) -> CGSize
    func convertToViewCoordinateSpace(_ rect: CGRect) -> CGRect
}

extension CoordinateSpaceConvertable {
    
    var imageSize: CGSize {
        guard let image = image else { return .zero }
        return .init(width: image.size.width*image.scale, height: image.size.height*image.scale)
    }
    
    var imageToViewScale: CGFloat {
        if orientation.isHorizontal {
            return imageSize.height
        } else {
            return imageSize.width / bounds.width
        }
    }
    
    func convertToImageCoordinateSpace(_ length: CGFloat) -> CGFloat {
        length*imageToViewScale
    }
    
    func convertToImageCoordinateSpace(_ point: CGPoint) -> CGPoint {
        .init(x: point.x*imageToViewScale,
              y: point.y*imageToViewScale)
    }
    
    func convertToImageCoordinateSpace(_ size: CGSize) -> CGSize {
        .init(width: size.width*imageToViewScale,
              height: size.height*imageToViewScale)
    }
    
    func convertToImageCoordinateSpace(_ rect: CGRect) -> CGRect {
        .init(origin: convertToImageCoordinateSpace(rect.origin),
              size: convertToImageCoordinateSpace(rect.size))
    }
    
    func convertToViewCoordinateSpace(_ length: CGFloat) -> CGFloat {
        length/imageToViewScale
    }
    
    func convertToViewCoordinateSpace(_ point: CGPoint) -> CGPoint {
        .init(x: point.x/imageToViewScale,
              y: point.y/imageToViewScale)
    }
    
    func convertToViewCoordinateSpace(_ size: CGSize) -> CGSize {
        .init(width: size.width/imageToViewScale,
              height: size.height/imageToViewScale)
    }
    
    func convertToViewCoordinateSpace(_ rect: CGRect) -> CGRect {
        .init(origin: convertToViewCoordinateSpace(rect.origin),
              size: convertToViewCoordinateSpace(rect.size))
    }
}
