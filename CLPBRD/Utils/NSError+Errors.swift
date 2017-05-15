import Foundation


let clpbrdErrorDomain = "CLPBRD Error"


extension NSError {
    static func error(text: String) -> NSError {
        return NSError(domain: clpbrdErrorDomain, code: 1, userInfo: [
            NSLocalizedDescriptionKey: text
        ])
    }
}
