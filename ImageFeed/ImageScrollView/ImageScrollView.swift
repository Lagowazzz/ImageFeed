import UIKit

final class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    var imageView: UIImageView!
    var imageZoomView: UIImageView!
    
    private lazy var rotationGestureRecognizer: UIRotationGestureRecognizer = {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        return rotationGesture
    }()
    
    private func rotateImage(by angle: CGFloat) {
        imageView.transform = imageView.transform.rotated(by: angle)
    }
    
    @objc private func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            rotateImage(by: gesture.rotation)
            gesture.rotation = 0
        default:
            break
        }
    }
    
    private lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.decelerationRate = UIScrollView.DecelerationRate.normal
        self.addGestureRecognizer(rotationGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
        imageView?.removeFromSuperview()
        imageView = nil
        
        imageView = UIImageView(image: image)
        self.addSubview(imageView)
        
        configurateFor(imageSize: image.size)
        
        let boundsSize = self.bounds.size
        let imageSize = image.size
        let widthScale = boundsSize.width / imageSize.width
        let heightScale = boundsSize.height / imageSize.height
        let initialScale = min(widthScale, heightScale)
        self.zoomScale = initialScale
        self.centerImage()
    }
    
    private func configurateFor(imageSize: CGSize) {
        self.contentSize = imageSize
        
        setCurrentMaxAndMinZoomScale()
        
        self.imageView.addGestureRecognizer(self.zoomingTap)
        self.imageView.isUserInteractionEnabled = true
        
        self.maximumZoomScale = self.maximumZoomScale * 5.0
    }
    
    private func setCurrentMaxAndMinZoomScale() {
        let boundsSize = self.bounds.size
        let imageSize = imageView.bounds.size
        
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        
        var maxScale: CGFloat = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1 && minScale < 0.5 {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    private func centerImage() {
        let boundsSize = self.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        imageView.frame = frameToCenter
    }
    
    @objc private func handleZoomingTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        
        if self.zoomScale == self.minimumZoomScale {
            let zoomRect = self.zoomRect(scale: self.maximumZoomScale, center: location)
            self.zoom(to: zoomRect, animated: true)
        } else {
            let zoomRect = self.zoomRect(scale: self.minimumZoomScale, center: location)
            self.zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoom(point: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        let minScale = self.minimumZoomScale
        let maxScale = self.maximumZoomScale
        
        if (minScale == maxScale && minScale > 1) {
            return
        }
        let toScale = maxScale
        let finalScale = (currentScale == minScale) ? toScale : minScale
        let zoomRect = self.zoomRect(scale: finalScale, center: point)
        self.zoom(to: zoomRect, animated: animated)
    }
    
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}
