//
//  ImageCropbox.swift
//  ImageEditorOC
//
//  Created by 郝振壹 on 2023/2/18.
//

import Foundation
import UIKit

struct ImageCropbox {
    
    private(set) var rect: CGRect
    let imageSize: CGSize
    var ratio: CGFloat {
        rect.width / rect.height
    }
    var inset: UIEdgeInsets {
        let bottom = imageSize.height - rect.maxY
        let right = imageSize.width - rect.maxX
        return .init(top: rect.minY, left: rect.minX, bottom: bottom, right: right)
    }
    
    init(rect: CGRect, imageSize: CGSize) {
        let adjuxtSize = Self.adjustBoxSize(rect.size, for: imageSize)
        let adjustOrigin = Self.adjustBoxOrigin(boxRect: .init(origin: rect.origin, size: adjuxtSize),
                                                for: imageSize)
        self.rect = .init(origin: adjustOrigin, size: adjuxtSize)
        self.imageSize = imageSize
    }
    
    init(imageSize: CGSize) {
        self.init(rect: .zero, imageSize: imageSize)
    }
    
    init(image: UIImage?) {
        if let image = image {
            self.init(rect: .zero,
                      imageSize: .init(width: image.scale*image.size.width,
                                       height: image.scale*image.size.height))            
        } else {
            self.init(rect: .null, imageSize: .zero)
        }
    }
    
    static let `null`: ImageCropbox = .init(rect: .null, imageSize: .zero)
    
    mutating func setBoxSize(_ size: CGSize) {
        let adjustSize = Self.adjustBoxSize(size, for: imageSize)
        let oldSize = rect.size
        let newRect = CGRect(origin: rect.origin, size: adjustSize)
        let adjustOrigin = Self.adjustBoxOriginForExtendsSize(oldSize: oldSize, newRect: newRect)
        rect = CGRect(origin: adjustOrigin, size: adjustSize)
    }
    
    mutating func setBoxRatio(_ ratio: CGFloat, for scope: CGSize) {
        let scopeRatio = scope.width / scope.height
        let boxRatio = self.ratio
        var newW: CGFloat
        var newH: CGFloat
        if ratio >= scopeRatio {
            if boxRatio >= scopeRatio {
                newW = rect.width
            } else {
                newW = scope.width
            }
            newH = newW / ratio
        } else {
            if boxRatio >= scopeRatio {
                newH = scope.height
            } else {
                newH = rect.height
            }
            newW = newH * ratio
        }
        setBoxSize(.init(width: newW, height: newH))
    }
    
    mutating func setBoxOrigin(_ origin: CGPoint) {
        rect.origin = Self.adjustBoxOrigin(boxRect: .init(origin: origin,
                                                          size: rect.size),
                                           for: imageSize)
    }
    
    mutating func setBoxRect(_ rect: CGRect) {
        let adjuxtSize = Self.adjustBoxSize(.init(width: rect.width, height: rect.height), for: imageSize)
        let adjustOrigin = Self.adjustBoxOrigin(boxRect: .init(origin: rect.origin,
                                                               size: adjuxtSize),
                                                for: imageSize)
        self.rect = .init(origin: adjustOrigin, size: adjuxtSize)
    }
    
    fileprivate static func adjustBoxSize(_ boxSize: CGSize, for imageSize: CGSize) -> CGSize {
        var newW = boxSize.width > 0 ? boxSize.width : imageSize.width
        var newH = boxSize.height > 0 ? boxSize.height : imageSize.height
        let newRatio = newW / newH
        if (newH > imageSize.height) {
            newH = imageSize.height
            newW = newH * newRatio
        }
        if (newW > imageSize.width) {
            newW = imageSize.width
            newH = newW / newRatio
        }
        return .init(width: newW, height: newH)
    }
    
    fileprivate static func adjustBoxOrigin(boxRect: CGRect, for imageSize: CGSize) -> CGPoint {
        var boxX = boxRect.origin.x >= 0 ? boxRect.origin.x : 0
        var boxY = boxRect.origin.y >= 0 ? boxRect.origin.y : 0
        let maxX = boxX + boxRect.size.width
        let maxY = boxY + boxRect.size.height
        if maxX > imageSize.width {
            boxX -= (maxX - imageSize.width)
        }
        if maxY > imageSize.height {
            boxY -= (maxY - imageSize.height)
        }
        return .init(x: boxX, y: boxY)
    }
    
    fileprivate static func adjustBoxOriginForExtendsSize(oldSize: CGSize, newRect: CGRect) -> CGPoint {
        let diffW = newRect.width - oldSize.width
        let diffH = newRect.height - oldSize.height
        return .init(x: newRect.minX - diffW/2,
                     y: newRect.minY - diffH/2)
    }
}

extension ImageCropbox: Equatable {}
