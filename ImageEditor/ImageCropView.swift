//
//  ImageCropView.swift
//  ImageEditorOC
//
//  Created by 郝振壹 on 2023/2/18.
//

import UIKit

class ImageCropView: UIView, CoordinateSpaceConvertable {    
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            cropbox = cropbox.fitForImage(image)
            setNeedsLayout()
        }
    }
    
    var cropbox: CGRect {
        get {
            _cropbox
        }
        set {
            var nextValue = newValue
            if nextValue == .zero && image != nil {
                nextValue =  newValue.fitForImage(image)
            }
            if nextValue == _cropbox {
                return
            }
            _cropbox = nextValue
            setNeedsLayout()
        }
    }
    
    var _cropbox: CGRect = .zero
    
    var orientation: ImageOrientation = .up {
        didSet {
            setNeedsLayout()
        }
    }
    
    var cropboxRatio: CGFloat {
        set {
            guard let image = image else { return }
            var ratio = newValue
            if ratio == 0 {
                ratio = image.rawSize.width/image.rawSize.height
            }
            if orientation.isHorizontal {
                ratio = 1/ratio
            }
            let scopeSizeOnImage = convertToImageCoordinateSpace(scopeSize)
            cropbox.setBoxRatio(ratio, scope: scopeSizeOnImage, for: image)
        }
        get {
            cropbox.ratio
        }
    }
    
    var maximumZoomScale: CGFloat = 5 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var hPadding: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var vPadding: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .black
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.decelerationRate = .fast
        view.delegate = self
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var cropboxView: CropBoxView = {
        let view = CropBoxView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var tlHandler = UIView(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    private lazy var trHandler = UIView(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    private lazy var blHandler = UIView(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    private lazy var brHandler = UIView(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
    
    private var scopeSize: CGSize {
        scrollView.bounds.insetBy(dx: hPadding, dy: vPadding).size
    }
    
    private var finishFirstLayout = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialConfig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialConfig()
    }
    
    func initialConfig() {
        backgroundColor = .black
        clipsToBounds = true
        scrollView.addSubview(imageView)
        [scrollView, cropboxView].forEach { addSubview($0) }
        let viewGestureMap = [
            tlHandler: UIPanGestureRecognizer(target: self, action: #selector(tlHandlerPan(_:))),
            trHandler: UIPanGestureRecognizer(target: self, action: #selector(trHandlerPan(_:))),
            blHandler: UIPanGestureRecognizer(target: self, action: #selector(blHandlerPan(_:))),
            brHandler: UIPanGestureRecognizer(target: self, action: #selector(brHandlerPan(_:))),
        ]
        viewGestureMap.forEach { view, gesture in
            view.addGestureRecognizer(gesture)
            addSubview(view)
        }
    }
}

/// layout
extension ImageCropView {
    
    override func layoutSubviews() {
        guard (image != nil) else {
            return
        }
        
        let updateLayout = {
            self.updateScrollViewLayout()
            self.updateCropboxViewLayout()
            self.updateImageViewLayout()
            self.updateMinumZoomScale()
            self.updateMaxiumZoomScale()
            self.updateZoomScale()
            self.updateContentSize()
            self.updateContentOffset()
            self.updateImageViewCenter()
            self.updateHandlersLayout()
        }
        
        if finishFirstLayout {
            UIView.animate(withDuration: 0.3, animations: updateLayout)
        } else {
            updateLayout()
            finishFirstLayout = true
        }
    }
    
    func updateScrollViewLayout() {
        scrollView.transform = CGAffineTransformMakeRotation(orientation.radian)
        var scrollViewBounds = self.bounds
        if orientation.isHorizontal {
            scrollViewBounds = .init(x: 0, y: 0, width: scrollViewBounds.height, height: scrollViewBounds.width)
        }
        scrollView.bounds = scrollViewBounds
        scrollView.center = .init(x: bounds.width/2, y: bounds.height/2)
    }
    
    func updateCropboxViewLayout() {
        cropboxView.transform = scrollView.transform
        cropboxView.bounds = scrollView.bounds
        cropboxView.center = scrollView.center
        cropboxView.boxRect = cropboxViewRectFitScope
    }
    
    func updateImageViewLayout() {
        imageView.bounds = .init(origin: .zero, size: imageViewSizeFitScope)
    }
    
    func updateMinumZoomScale() {
        let imageViewSize = imageViewSizeFitScope
        let cropboxViewSize = cropboxViewSizeFitScope
        let imageRatio = imageViewSize.width / imageViewSize.height
        var minZoomScale: CGFloat
        if cropboxRatio < imageRatio {
            let imageViewMinHeight = cropboxViewSize.height
            minZoomScale = imageViewMinHeight / imageViewSize.height
        } else {
            let imageViewMinWidth = cropboxViewSize.width
            minZoomScale = imageViewMinWidth / imageViewSize.width
        }
        scrollView.minimumZoomScale = minZoomScale
    }
    
    func updateMaxiumZoomScale() {
        scrollView.maximumZoomScale = scrollView.minimumZoomScale*maximumZoomScale
    }
    
    func updateZoomScale() {
        guard let image = image else { return }
        let cropboxViewSize = cropboxViewSizeFitScope
        let scale = cropbox.width / cropboxViewSize.width
        let imageViewWidth = imageViewSizeFitScope.width
        scrollView.zoomScale = image.rawSize.width/scale/imageViewWidth
    }
    
    func updateContentSize() {
        let cropboxSize = cropboxViewSizeFitScope
        let width = imageView.frame.width - cropboxSize.width
        let height = imageView.frame.height - cropboxSize.height
        scrollView.contentSize = .init(width: scrollView.bounds.width + width,
                                       height: scrollView.bounds.height + height)
    }
    
    func updateContentOffset() {
        let offset = CGPoint(x: cropbox.inset(of: image).left, y: cropbox.inset(of: image).top)
        scrollView.contentOffset = convertToViewCoordinateSpace(offset)
    }
    
    func updateImageViewCenter() {
        let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width)*0.5 : 0
        let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height)*0.5 : 0
        imageView.center = .init(x: scrollView.contentSize.width*0.5 + offsetX,
                                 y: scrollView.contentSize.height*0.5 + offsetY)
    }
    
    func updateHandlersLayout() {
        let boxRect = cropboxViewRectFitScope
        tlHandler.center = boxRect.origin
        trHandler.center = .init(x: boxRect.maxX, y: boxRect.minY)
        blHandler.center = .init(x: boxRect.minX, y: boxRect.maxY)
        brHandler.center = .init(x: boxRect.maxX, y: boxRect.maxY)
    }
}

/// gesture
private extension ImageCropView {
    @objc func tlHandlerPan(_ gesture: UIPanGestureRecognizer) {
        updateBoxRect(with: gesture) { .init(x: $0.x, y: $0.y, width: -$0.x, height: -$0.y) }
    }
    
    @objc func trHandlerPan(_ gesture: UIPanGestureRecognizer) {
        updateBoxRect(with: gesture) { .init(x: 0, y: $0.y, width: $0.x, height: -$0.y) }
    }
    
    @objc func blHandlerPan(_ gesture: UIPanGestureRecognizer) {
        updateBoxRect(with: gesture) { .init(x: $0.x, y: 0, width: -$0.x, height: $0.y) }
    }
    
    @objc func brHandlerPan(_ gesture: UIPanGestureRecognizer) {
        updateBoxRect(with: gesture) { .init(origin: .zero, size: .init(width: $0.x, height: $0.y)) }
    }
    
    func updateBoxRect(with gesture:UIPanGestureRecognizer, block: (_ translation: CGPoint)->CGRect) {
        if gesture.state == .began || gesture.state == .changed {
            let diff = block(gesture.translation(in: self))
            gesture.setTranslation(.zero, in: self)
            cropboxView.boxRect.origin.x += diff.origin.x
            cropboxView.boxRect.origin.y += diff.origin.y
            cropboxView.boxRect.size.width += diff.size.width
            cropboxView.boxRect.size.height += diff.size.height
        } else {
            handlerGestureEnd()
        }
    }
    
    func handlerGestureEnd() {
        let boxRectOnView = cropboxView.convert(cropboxView.boxRect, to: imageView).applying(imageView.transform)
        cropbox = boxRectOnView.fitForImage(image)
    }
}

extension ImageCropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateContentSize()
        updateImageViewCenter()
        updateCropBox()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating || scrollView.isZooming || scrollView.isZoomBouncing {
            updateCropBox()
        }
    }
}

/// calculation
extension ImageCropView {
    var cropboxViewRectFitScope: CGRect {
        let boxSize = cropboxViewSizeFitScope
        let x = (scrollView.bounds.width - boxSize.width)/2
        let y = (scrollView.bounds.height - boxSize.height)/2
        return .init(x: x, y: y, width: boxSize.width, height: boxSize.height)
    }
    
    var cropboxViewSizeFitScope: CGSize {
        sizeFittingScopeWithRatio(cropboxRatio)
    }
    
    var imageViewSizeFitScope: CGSize {
        guard let image = image else { return .zero }
        return sizeFittingScopeWithRatio(image.rawSize.width / image.rawSize.height)
    }
    
    func sizeFittingScopeWithRatio(_ ratio: CGFloat) -> CGSize {
        let scopeRatio = scopeSize.width / scopeSize.height
        var width, height:CGFloat
        if ratio >= scopeRatio {
            width = scopeSize.width
            height = width / ratio
        } else {
            height = scopeSize.height
            width = height * ratio
        }
        return .init(width: width, height: height)
    }
    
    func updateCropBox() {
        let cropboxSize = convertToImageCoordinateSpace(cropboxViewSizeFitScope)
        let cropboxOrigin = convertToImageCoordinateSpace(scrollView.contentOffset)
        _cropbox = CGRect(origin: cropboxOrigin, size: cropboxSize).fitForImage(image)
    }
}
