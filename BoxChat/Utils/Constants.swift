import Foundation

struct Constants {
    
    #if targetEnvironment(simulator)
    static let apiBaseURL = "http://127.0.0.1:8000/api/v1"
    static let webSocketURL = "ws://127.0.0.1:8000/ws"
    
    #else
    static let apiBaseURL = "http://172.25.15.130:8000/api/v1"
    static let webSocketURL = "ws://172.25.15.130:8000/ws"
    
    #endif
}
