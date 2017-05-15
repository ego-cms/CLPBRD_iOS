import Foundation

func delay(_ seconds: TimeInterval, queue: DispatchQueue = .main, closure: @escaping () -> ()) {
    let time = DispatchTime.now() + seconds
    queue.asyncAfter(deadline: time, execute: closure)
}
