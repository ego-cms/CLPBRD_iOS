import Foundation


protocol ClipboardProviderService: class {
    var content: String? { get set }
    var changeCount: Int { get }
    var onContentChanged: VoidClosure { get set }
}
