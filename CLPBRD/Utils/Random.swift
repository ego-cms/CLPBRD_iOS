import Foundation


func random(from: UInt, to: UInt) -> UInt {
    return from + UInt(arc4random_uniform(UInt32(to - from + 1)))
}
