//
//  NetworkManager.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/26/23.
//

import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    
    private init() {
        monitor.start(queue: queue)
    }
    
    func isInternetAvailable(completion: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
        }
    }
}
