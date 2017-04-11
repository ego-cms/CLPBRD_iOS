// Generates unique ids for current process
struct ClientId: Hashable {
    private static var pool: Set<UInt32> = Set()
    
    private var int: UInt32
    
    init() {
        var nextCandidate: UInt32 = 0
        while true {
            nextCandidate = arc4random()
            if ClientId.pool.contains(nextCandidate) { continue }
            ClientId.pool.insert(nextCandidate)
            break       
        }
        self.int = nextCandidate
    }
    
    static func == (lhs: ClientId, rhs: ClientId) -> Bool {
        return lhs.int == rhs.int
    }
    
    var hashValue: Int {
        return int.hashValue
    }
}
