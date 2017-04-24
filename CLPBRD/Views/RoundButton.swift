import UIKit

class RoundButton: UIButton {
    var normalColor: UIColor = UIColor.clear
    var highlightColor: UIColor = UIColor.lightGray
    
    private func fontSize(forButtonWidth width: CGFloat) -> CGFloat {
        return 0.2 * width
    }
    
    private func imageScale(forButtonWidth width: CGFloat) -> CGAffineTransform {
        let scale = 0.8 * width
        return CGAffineTransform(scaleX: scale, y: scale)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) * 0.5
        titleLabel?.font = titleLabel?.font.withSize(fontSize(forButtonWidth: frame.width))
        updateBackgroundColor()
//        contentMode = .center
        imageView?.contentMode = .scaleAspectFit
//        setImage(imageView?.image, for: .normal)
        
        /*
        guard let imageWidth = imageView?.image?.size.width,
            imageWidth != 0,
            frame.width != 0 else {
            return
        }
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
        */
//        let scale = (0.1 * frame.width) / imageWidth
//        imageView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        
//        log.debug("Scale: \(scale), Image view size: \(imageView!.frame.size), title = \(titleLabel?.text ?? "")")

        let delta: CGFloat = 0.25 * frame.width
        print("delta \(delta), width \(frame.width)")
        imageEdgeInsets = UIEdgeInsets(top: delta, left: delta, bottom: delta, right: delta)
        setImage(imageView?.image, for: .normal)
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        self.backgroundColor = isHighlighted ? highlightColor : normalColor
    }
}
