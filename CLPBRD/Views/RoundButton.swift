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
        imageView?.contentMode = .scaleAspectFit
        let delta: CGFloat = 16
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
