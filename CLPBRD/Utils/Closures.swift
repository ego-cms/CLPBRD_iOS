import Foundation


func call<T>(closure: ((T) -> Void)?, parameter: T, on queue: DispatchQueue = .main) {
    guard let closure = closure else {
        return
    }
    queue.async {
        closure(parameter)
    }
}
