//
//  ImageCropbox.swift
//  ImageEditorOC
//
//  Created by 郝振壹 on 2023/2/18.
//

import Foundation
import UIKit

extension UIImage {
    var rawSize: CGSize {
        .init(width: size.width*scale, height: size.height*scale)
    }
}

/// calculate cropping operation
extension CGRect {
    
    var ratio: CGFloat {
        size.width / size.height
    }
    
    init(image: UIImage) {
        self = CGRect.zero.fitForImage(image)
    }
    
    func inset(of image: UIImage?) -> UIEdgeInsets {
        guard let image = image else { return .zero }
        let bottom = image.rawSize.height - maxY
        let right = image.rawSize.width - maxX
        return .init(top: minY, left: minX, bottom: bottom, right: right)
    }
    
    func fitForImage(_ image: UIImage?) -> CGRect {
        guard let image = image else { return .zero }
        let fittedSize = size.fitForImageCropping(image)
        let fittedOrigin = fitOriginForImage(image)
        return .init(origin: fittedOrigin, size: fittedSize)
    }
    
    @discardableResult
    mutating func setSize(_ size: CGSize, for image: UIImage) -> CGRect {
        let fittedSize = size.fitForImageCropping(image)
        self = fitForExtendsCropSize(fittedSize)
        return self
    }
    
    @discardableResult
    mutating func setOrigin(_ origin: CGPoint, for image: UIImage) -> CGRect {
        fitOriginForImage(image)
        return self
    }
    
    @discardableResult
    mutating func setBoxRatio(_ ratio: CGFloat, scope: CGSize, for image: UIImage?) -> CGRect {
        guard let image = image else { return .zero }
        let scopeRatio = scope.width / scope.height
        var newW: CGFloat
        var newH: CGFloat
        if ratio >= scopeRatio {
            if self.ratio >= scopeRatio {
                newW = width
            } else {
                newW = scope.width
            }
            newH = newW / ratio
        } else {
            if self.ratio >= scopeRatio {
                newH = scope.height
            } else {
                newH = height
            }
            newW = newH * ratio
        }
        return setSize(.init(width: newW, height: newH), for: image)
    }
    
    @discardableResult
    mutating func fitForExtendsCropSize(_ newSize: CGSize) -> CGRect {
        let diffW = newSize.width - size.width
        let diffH = newSize.height - size.height
        let newX = origin.x - diffW/2
        let newY = origin.y - diffH/2
        self = .init(origin: .init(x: newX, y: newY), size: newSize)
        return self
    }
    
    @discardableResult
    func fitOriginForImage(_ image: UIImage) -> CGPoint {
        var boxOrigin = origin.fitForImageCropping()
        let maxX = boxOrigin.x + size.width
        let maxY = boxOrigin.y + size.height
        let imageSize = image.rawSize
        if maxX > imageSize.width {
            boxOrigin.x -= (maxX - imageSize.width)
        }
        if maxY > imageSize.height {
            boxOrigin.y -= (maxY - imageSize.height)
        }
        return boxOrigin
    }
}

extension CGSize {
    
    /// 保证裁剪框不会比图片大，也不会小于等于0
    func fitForImageCropping(_ image: UIImage) -> CGSize {
        let imageSize = image.rawSize
        var newWidth = self.width > 0 ? self.width : imageSize.width
        var newHeight = self.height > 0 ? self.height : imageSize.height
        let ratio = newWidth / newHeight
        if (newHeight > imageSize.height) {
            newHeight = imageSize.height
            newWidth = newHeight * ratio
        }
        if (newWidth > imageSize.width) {
            newWidth = imageSize.width
            newHeight = newWidth / ratio
        }
        return .init(width: newWidth, height: newHeight)
    }
}

extension CGPoint {
    
    /// 保证裁剪框的位置不会为负
    func fitForImageCropping() -> CGPoint {
        return .init(x: x > 0 ? x : 0, y: y > 0 ? y : 0)
    }
}

//struct ImageCropbox {
//
//    private(set) var rect: CGRect
//    let imageSize: CGSize
//    var ratio: CGFloat {
//        rect.width / rect.height
//    }
//    var inset: UIEdgeInsets {
//        let bottom = imageSize.height - rect.maxY
//        let right = imageSize.width - rect.maxX
//        return .init(top: rect.minY, left: rect.minX, bottom: bottom, right: right)
//    }
//
//    init(rect: CGRect, imageSize: CGSize) {
//        let adjuxtSize = Self.adjustBoxSize(rect.size, for: imageSize)
//        let adjustOrigin = Self.adjustBoxOrigin(boxRect: .init(origin: rect.origin, size: adjuxtSize),
//                                                for: imageSize)
//        self.rect = .init(origin: adjustOrigin, size: adjuxtSize)
//        self.imageSize = imageSize
//    }
//
//    init(imageSize: CGSize) {
//        self.init(rect: .zero, imageSize: imageSize)
//    }
//
//    init(image: UIImage?) {
//        if let image = image {
//            self.init(rect: .zero,
//                      imageSize: .init(width: image.scale*image.size.width,
//                                       height: image.scale*image.size.height))
//        } else {
//            self.init(rect: .null, imageSize: .zero)
//        }
//    }
//
//    static let `null`: ImageCropbox = .init(rect: .null, imageSize: .zero)
//
//    mutating func setBoxSize(_ size: CGSize) {
//        let adjustSize = Self.adjustBoxSize(size, for: imageSize)
//        let oldSize = rect.size
//        let newRect = CGRect(origin: rect.origin, size: adjustSize)
//        let adjustOrigin = Self.adjustBoxOriginForExtendsSize(oldSize: oldSize, newRect: newRect)
//        rect = CGRect(origin: adjustOrigin, size: adjustSize)
//    }
//
//    mutating func setBoxRatio(_ ratio: CGFloat, for scope: CGSize) {
//        let scopeRatio = scope.width / scope.height
//        let boxRatio = self.ratio
//        var newW: CGFloat
//        var newH: CGFloat
//        if ratio >= scopeRatio {
//            if boxRatio >= scopeRatio {
//                newW = rect.width
//            } else {
//                newW = scope.width
//            }
//            newH = newW / ratio
//        } else {
//            if boxRatio >= scopeRatio {
//                newH = scope.height
//            } else {
//                newH = rect.height
//            }
//            newW = newH * ratio
//        }
//        setBoxSize(.init(width: newW, height: newH))
//    }
//
//    mutating func setBoxOrigin(_ origin: CGPoint) {
//        rect.origin = Self.adjustBoxOrigin(boxRect: .init(origin: origin,
//                                                          size: rect.size),
//                                           for: imageSize)
//    }
//
//    mutating func setBoxRect(_ rect: CGRect) {
//        let adjuxtSize = Self.adjustBoxSize(.init(width: rect.width, height: rect.height), for: imageSize)
//        let adjustOrigin = Self.adjustBoxOrigin(boxRect: .init(origin: rect.origin,
//                                                               size: adjuxtSize),
//                                                for: imageSize)
//        self.rect = .init(origin: adjustOrigin, size: adjuxtSize)
//    }
//
//    fileprivate static func adjustBoxSize(_ boxSize: CGSize, for imageSize: CGSize) -> CGSize {
//        var newW = boxSize.width > 0 ? boxSize.width : imageSize.width
//        var newH = boxSize.height > 0 ? boxSize.height : imageSize.height
//        let newRatio = newW / newH
//        if (newH > imageSize.height) {
//            newH = imageSize.height
//            newW = newH * newRatio
//        }
//        if (newW > imageSize.width) {
//            newW = imageSize.width
//            newH = newW / newRatio
//        }
//        return .init(width: newW, height: newH)
//    }
//
//    fileprivate static func adjustBoxOrigin(boxRect: CGRect, for imageSize: CGSize) -> CGPoint {
//        var boxX = boxRect.origin.x >= 0 ? boxRect.origin.x : 0
//        var boxY = boxRect.origin.y >= 0 ? boxRect.origin.y : 0
//        let maxX = boxX + boxRect.size.width
//        let maxY = boxY + boxRect.size.height
//        if maxX > imageSize.width {
//            boxX -= (maxX - imageSize.width)
//        }
//        if maxY > imageSize.height {
//            boxY -= (maxY - imageSize.height)
//        }
//        return .init(x: boxX, y: boxY)
//    }
//
//    fileprivate static func adjustBoxOriginForExtendsSize(oldSize: CGSize, newRect: CGRect) -> CGPoint {
//        let diffW = newRect.width - oldSize.width
//        let diffH = newRect.height - oldSize.height
//        return .init(x: newRect.minX - diffW/2,
//                     y: newRect.minY - diffH/2)
//    }
//}

//extension ImageCropbox: Equatable {}
