import Foundation

protocol WebSocketServiceDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect(error: Error?)
    func webSocketDidReceiveEvent(type: String, payload: [String: Any])
}

class WebSocketService: NSObject {
    static let shared = WebSocketService()
    
    weak var delegate: WebSocketServiceDelegate?
    private var webSocketTask: URLSessionWebSocketTask?
    
    private var pingTimer: Timer?
    private var pongTimeoutTimer: Timer?
    private var reconnectAttempt = 0
    private var isConnected = false
    private var isConnecting = false
    
    var localLastMessageIds: [Int: Int] = [:]
    
    private override init() { super.init() }
    
    func connect() {
        guard !isConnected && !isConnecting, let token = TokenManager.shared.accessToken else { return }
        isConnecting = true
        
        guard let url = URL(string: "\(Constants.webSocketURL)?token=\(token)") else { return }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        listen()
    }
    
    func disconnect() {
        stopHeartbeat()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        isConnected = false
        isConnecting = false
    }
    
    func sendEvent(type: String, payload: [String: Any]) {
        let frame: [String: Any] = [
            "type": type,
            "payload": payload,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: frame),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error { print("WS Send Error: \(error)") }
        }
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    self.handleIncomingMessage(text)
                }
                self.listen()
            case .failure(let error):
                self.handleDisconnection(error: error)
            }
        }
    }
    
    private func handleIncomingMessage(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = jsonObject["type"] as? String else { return }
        
        let payload = jsonObject["payload"] as? [String: Any] ?? [:]
        
        if type == "pong" {
            pongTimeoutTimer?.invalidate()
            pongTimeoutTimer = nil
            return
        }
        
        if type == "connected" {
            isConnected = true
            isConnecting = false
            reconnectAttempt = 0
            startHeartbeat()
            delegate?.webSocketDidConnect()
            syncMessagesAfterReconnect()
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.webSocketDidReceiveEvent(type: type, payload: payload)
        }
    }
    
    private func startHeartbeat() {
        stopHeartbeat()
        DispatchQueue.main.async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
                self?.sendPing()
            }
        }
    }
    
    private func stopHeartbeat() {
        pingTimer?.invalidate()
        pingTimer = nil
        pongTimeoutTimer?.invalidate()
        pongTimeoutTimer = nil
    }
    
    private func sendPing() {
        sendEvent(type: "ping", payload: [:])
        DispatchQueue.main.async {
            self.pongTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.handleDisconnection(error: NSError(domain: "WS", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ping Timeout"]))
            }
        }
    }
    
    private func handleDisconnection(error: Error?) {
        disconnect()
        let delay = min(pow(2.0, Double(reconnectAttempt)), 30.0)
        reconnectAttempt += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.connect()
        }
    }
    
    private func syncMessagesAfterReconnect() {
        for (roomId, lastId) in localLastMessageIds {
            sendEvent(type: "sync_messages", payload: ["room_id": roomId, "last_message_id": lastId])
        }
    }
}

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        if closeCode.rawValue == 4001 {
            NetworkManager.shared.refreshAccessToken { success in
                if success { self.connect() }
            }
        } else {
            handleDisconnection(error: nil)
        }
    }
}
