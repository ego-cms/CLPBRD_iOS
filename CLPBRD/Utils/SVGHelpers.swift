import UIKit


func loadSVG(from fileName: String) -> UIBezierPath {
    let pathString = try! String(contentsOf: Bundle.main.url(forResource: fileName, withExtension: "path")!)
    
    return UIBezierPath(svgPath: pathString)
}


extension CGRect {
    init(center: CGPoint, radius: CGFloat) {
        origin = CGPoint(x: center.x - radius, y: center.y - radius)
        size = CGSize(width: 2 * radius, height: 2 * radius)
    }
}


extension UIBezierPath {
    func scale(toFit containerSize: CGSize) -> CGAffineTransform {
        let size = bounds.size
        let (w, h) = (size.width, size.height)
        let (cw, ch) = (containerSize.width, containerSize.height)
        guard w != 0 && h != 0 else { return CGAffineTransform.identity }
        let scale = min(cw / w, ch / h)
        return CGAffineTransform(scaleX: scale, y: scale)
    }
}
