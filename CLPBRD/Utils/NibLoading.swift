import UIKit


protocol NibInstatiateable {
    /** Loads instance of view from nib file.
     
     - Parameter name:  Nib name. If omitted it loads nib with the same name as the class name.
     - Returns: View instantiated from this nib */
    static func instantiateFromNib(name: String?, bundle: Bundle?, owner: AnyObject?, index: Int) -> UIView
}


extension NibInstatiateable where Self: UIView {
    static func instantiateFromNib(name: String? = nil, bundle: Bundle? = nil, owner: AnyObject? = nil, index: Int = 0) -> Self {
        let nibName = name ?? "\(self)"
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: owner, options: nil)[index] as! Self
    }
}


extension UIView: NibInstatiateable {}
