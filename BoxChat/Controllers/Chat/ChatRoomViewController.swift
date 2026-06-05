import UIKit

class ChatRoomViewController: UIViewController {
    private let room: Room
    private var messages: [Message] = []
    private var isTyping = false
    
    private let tableView = UITableView()
    private let inputVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let attachButton = UIButton(type: .system)
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let typingIndicatorLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 11)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()
    
    private var inputBottomConstraint: NSLayoutConstraint!
    
    init(room: Room) {
        self.room = room
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = room.name
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
        setupInputContainer()
        setupTypingIndicator()
        setupActivityIndicator()
        setupNavBar()
        
        loadMessageHistory()
        joinWebSocketRoom()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        markMessagesAsRead()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        leaveWebSocketRoom()
    }
    
    private func setupNavBar() {
        let infoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(didTapInfo))
        navigationItem.rightBarButtonItem = infoButton
    }
    
    @objc private func didTapInfo() {
        let message = """
        Mô tả: \(room.description ?? "Không có mô tả")
        Mã mời: \(room.inviteCode)
        """
        let alert = UIAlertController(title: room.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sao chép Mã mời", style: .default) { _ in
            UIPasteboard.general.string = self.room.inviteCode
        })
        alert.addAction(UIAlertAction(title: "Đóng", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.keyboardDismissMode = .interactive
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupInputContainer() {
        view.addSubview(inputVisualEffectView)
        inputVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        textField.placeholder = "Nhập tin nhắn..."
        textField.borderStyle = .none
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 20
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: 15)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let attachImg = UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
        attachButton.setImage(attachImg, for: .normal)
        attachButton.tintColor = .secondaryLabel
        attachButton.addTarget(self, action: #selector(didTapAttach), for: .touchUpInside)
        
        let sendImg = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        sendButton.setImage(sendImg, for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        inputVisualEffectView.contentView.addSubview(attachButton)
        inputVisualEffectView.contentView.addSubview(textField)
        inputVisualEffectView.contentView.addSubview(sendButton)
        
        attachButton.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        inputBottomConstraint = inputVisualEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            inputVisualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputVisualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBottomConstraint,
            inputVisualEffectView.heightAnchor.constraint(equalToConstant: 64),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputVisualEffectView.topAnchor),
            
            attachButton.centerYAnchor.constraint(equalTo: inputVisualEffectView.contentView.centerYAnchor),
            attachButton.leadingAnchor.constraint(equalTo: inputVisualEffectView.contentView.leadingAnchor, constant: 12),
            attachButton.widthAnchor.constraint(equalToConstant: 36),
            attachButton.heightAnchor.constraint(equalToConstant: 36),
            
            textField.centerYAnchor.constraint(equalTo: inputVisualEffectView.contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            textField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.centerYAnchor.constraint(equalTo: inputVisualEffectView.contentView.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: inputVisualEffectView.contentView.trailingAnchor, constant: -16),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
            sendButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupTypingIndicator() {
        view.addSubview(typingIndicatorLabel)
        typingIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typingIndicatorLabel.bottomAnchor.constraint(equalTo: inputVisualEffectView.topAnchor, constant: -4),
            typingIndicatorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadMessageHistory() {
        activityIndicator.startAnimating()
        NetworkManager.shared.fetchMessages(roomId: room.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if case .success(let response) = result {
                    self?.messages = response.items.reversed()
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                    if let last = response.items.first {
                        WebSocketService.shared.localLastMessageIds[self?.room.id ?? 0] = last.id
                    }
                }
            }
        }
    }
    
    private func joinWebSocketRoom() {
        WebSocketService.shared.sendEvent(type: "join_room", payload: ["room_id": room.id])
        WebSocketService.shared.delegate = self
    }
    
    private func leaveWebSocketRoom() {
        WebSocketService.shared.sendEvent(type: "leave_room", payload: ["room_id": room.id])
    }
    
    @objc private func didTapSend() {
        guard let text = textField.text, !text.isEmpty else { return }
        WebSocketService.shared.sendEvent(type: "send_message", payload: [
            "room_id": room.id,
            "content": text,
            "temp_id": UUID().uuidString
        ])
        textField.text = ""
        sendStopTyping()
    }
    
    @objc private func didTapAttach() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    private func markMessagesAsRead() {
        guard let last = messages.last else { return }
        WebSocketService.shared.sendEvent(type: "mark_read", payload: ["room_id": room.id, "last_message_id": last.id])
    }
    
    @objc private func textFieldDidChange() {
        if let text = textField.text, !text.isEmpty {
            if !isTyping {
                isTyping = true
                WebSocketService.shared.sendEvent(type: "typing", payload: ["room_id": room.id])
            }
        } else {
            sendStopTyping()
        }
    }
    
    private func sendStopTyping() {
        isTyping = false
        WebSocketService.shared.sendEvent(type: "stop_typing", payload: ["room_id": room.id])
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(n: NSNotification) {
        guard let kbFrame = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = kbFrame.height
        inputBottomConstraint.constant = -keyboardHeight + view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        self.scrollToBottom()
    }
    
    @objc private func keyboardWillHide(n: NSNotification) {
        guard let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        inputBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollToBottom() {
        if messages.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
}

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        let msg = messages[indexPath.row]
        cell.configure(with: msg, isMe: msg.userId == TokenManager.shared.currentUser?.id)
        return cell
    }
}

extension ChatRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage,
              let data = image.jpegData(compressionQuality: 0.7) else { return }
        
        activityIndicator.startAnimating()
        
        NetworkManager.shared.uploadFile(
            roomId: room.id,
            fileData: data,
            fileName: "image_\(Int(Date().timeIntervalSince1970)).jpg",
            mimeType: "image/jpeg"
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let message):
                    self?.messages.append(message)
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                case .failure(let error):
                    let alert = UIAlertController(title: "Tải ảnh thất bại", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

extension ChatRoomViewController: WebSocketServiceDelegate {
    func webSocketDidConnect() {
        joinWebSocketRoom()
    }
    
    func webSocketDidDisconnect(error: Error?) {
        print("Mất kết nối WebSocket: \(String(describing: error?.localizedDescription))")
    }
    
    func webSocketDidReceiveEvent(type: String, payload: [String: Any]) {
        switch type {
        case "new_message":
            if let rId = payload["room_id"] as? Int, rId == room.id,
               let msgDict = payload["message"],
               let raw = try? JSONSerialization.data(withJSONObject: msgDict),
               let msg = try? JSONDecoder().decode(Message.self, from: raw) {
                messages.append(msg)
                tableView.reloadData()
                scrollToBottom()
                WebSocketService.shared.localLastMessageIds[room.id] = msg.id
                markMessagesAsRead()
            }
        case "message_sent":
            if let msgDict = payload["message"],
               let raw = try? JSONSerialization.data(withJSONObject: msgDict),
               let msg = try? JSONDecoder().decode(Message.self, from: raw) {
                if !messages.contains(where: { $0.id == msg.id }) {
                    messages.append(msg)
                    tableView.reloadData()
                    scrollToBottom()
                    WebSocketService.shared.localLastMessageIds[room.id] = msg.id
                }
            }
        case "typing_indicator":
            if let rId = payload["room_id"] as? Int, rId == room.id,
               let username = payload["username"] as? String,
               let active = payload["is_typing"] as? Bool {
                typingIndicatorLabel.text = active ? "\(username) đang soạn tin nhắn..." : nil
                typingIndicatorLabel.isHidden = !active
            }
        case "sync_messages":
            if let rId = payload["room_id"] as? Int, rId == room.id,
               let list = payload["messages"] as? [[String: Any]] {
                for item in list {
                    if let raw = try? JSONSerialization.data(withJSONObject: item),
                       let msg = try? JSONDecoder().decode(Message.self, from: raw),
                       !messages.contains(where: { $0.id == msg.id }) {
                        messages.append(msg)
                    }
                }
                messages.sort(by: { $0.id < $1.id })
                tableView.reloadData()
                scrollToBottom()
            }
        default:
            break
        }
    }
}
