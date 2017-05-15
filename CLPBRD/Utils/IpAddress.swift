import Foundation

func getLocalIpAddress() -> String? {
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    var address : String?
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs>?
    defer {
        freeifaddrs(ifaddr)
    }
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    
    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        
        // Check for IPv4 or IPv6 interface:
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            
            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if name == "en0" {
                
                // Convert interface address to a human readable string:
                var addr = interface.ifa_addr.pointee
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
    }
    return address
}

func localHostURL() -> URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = "http"
    urlComponents.host = getLocalIpAddress()
    urlComponents.port = 8080
    return urlComponents.url
}

func host(from string: String) -> String? {
    guard let url = URL(string: string) else { return nil }
    guard url.scheme == "clpbrd" else { return nil }
    return url.host
}