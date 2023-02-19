//
//  CropBoxView.swift
//  ImageEditorOC
//
//  Created by 郝振壹 on 2023/2/18.
//

import UIKit

class CropBoxView: UIView {

    var boxRect: CGRect = .zero {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var maskColor: UIColor = .black.withAlphaComponent(0.5) {
        didSet {
            [topEdge, leftEdge, rightEdge, bottomEdge]
                .forEach { $0.backgroundColor = maskColor }
        }
    }
    
    private let topEdge = UIView()
    private let leftEdge = UIView()
    private let rightEdge = UIView()
    private let bottomEdge = UIView()
    let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [topEdge, leftEdge, rightEdge, bottomEdge, borderView]
            .forEach { addSubview($0) }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        [topEdge, leftEdge, rightEdge, bottomEdge, borderView]
            .forEach { addSubview($0) }
    }
    
    override func layoutSubviews() {
        topEdge.frame = .init(origin: .zero, size: .init(width: bounds.width, height: boxRect.minY))
        bottomEdge.frame = .init(x: 0, y: boxRect.maxY, width: bounds.width, height: bounds.height - boxRect.maxY)
        leftEdge.frame = .init(x: 0, y: boxRect.minY, width: boxRect.minX, height: boxRect.height)
        rightEdge.frame = .init(x: boxRect.maxX, y: boxRect.minY, width: bounds.width - boxRect.maxX, height: boxRect.height)
        borderView.frame = boxRect
    }
}
