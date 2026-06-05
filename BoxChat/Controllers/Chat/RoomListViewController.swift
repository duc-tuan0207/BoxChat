import UIKit

class RoomListViewController: UIViewController {
    
    private let tableView = UITableView()
    private var rooms: [Room] = []
    
    // Thêm một UIRefreshControl để người dùng có thể vuốt màn hình từ trên xuống để làm mới danh sách
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tin Nhắn"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
        setupNavBar()
        fetchRooms()
        
        WebSocketService.shared.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogoutRequired), name: .didLogoutRequired, object: nil)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RoomCell.self, forCellReuseIdentifier: RoomCell.identifier)
        
        // Cấu hình tính năng kéo để làm mới (Pull-to-refresh)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavBar() {
        // ĐÃ BỎ: Không tạo nút Đăng xuất bên góc trái nữa
        
        let addImg = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: addImg, style: .plain, target: self, action: #selector(didTapAddRoom))
    }
    
    // Hàm fetchRooms chuẩn hóa luồng render giao diện
    @objc private func fetchRooms() {
        NetworkManager.shared.fetchRooms { [weak self] result in
            DispatchQueue.main.async {
                // Tắt hiệu ứng quay quay của refresh control nếu có
                self?.refreshControl.endRefreshing()
                
                if case .success(let response) = result {
                    print("📊 [Debug] Đã lấy thành công \(response.items.count) phòng từ Server Database.")
                    
                    self?.rooms = response.items
                    self?.tableView.reloadData()
                    
                    // Cập nhật ID tin nhắn cuối cùng cho WebSocket bám sát trạng thái
                    for room in response.items {
                        if let last = room.lastMessage {
                            WebSocketService.shared.localLastMessageIds[room.id] = last.id
                        }
                    }
                } else if case .failure(let error) = result {
                    print("❌ [Lỗi Fetch Rooms]: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func handleRefresh() {
        fetchRooms()
    }
    
    // Gọi Custom Sheet Kính mờ đồng bộ giao diện Đăng Nhập
    @objc private func didTapAddRoom() {
        let actionSheetVC = CreateRoomViewController()
        
        // Lắng nghe sự kiện lưu dữ liệu thành công để reload lại danh sách phòng
        actionSheetVC.onDataChanged = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.fetchRooms()
            }
        }
        
        // Cấu hình hiển thị dạng Bottom Sheet nửa màn hình cao cấp giống Apple, Telegram
        if let sheet = actionSheetVC.sheetPresentationController {
            sheet.detents = [.medium()] // Chỉ mở nửa màn hình
            sheet.prefersGrabberVisible = true // Thêm thanh gờ nhỏ ở đầu để vuốt đóng xuống dễ dàng
            sheet.preferredCornerRadius = 30 // Bo góc đồng bộ với thẻ kính
        }
        
        present(actionSheetVC, animated: true)
    }
    
    // --- XỬ LÝ ĐĂNG XUẤT NGẦM (Giữ lại xử lý logic khi server yêu cầu logout) ---
    private func performLogout() {
        WebSocketService.shared.disconnect()
        TokenManager.shared.clear()
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window else { return }
            
            let loginVC = LoginViewController()
            window.rootViewController = loginVC
            
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    @objc private func handleLogoutRequired() {
        DispatchQueue.main.async { self.performLogout() }
    }
}

// MARK: - UITableView DataSource & Delegate
extension RoomListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.identifier, for: indexPath) as! RoomCell
        cell.configure(with: rooms[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatRoomViewController(room: rooms[indexPath.row])
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - WebSocketServiceDelegate
extension RoomListViewController: WebSocketServiceDelegate {
    func webSocketDidConnect() {}
    func webSocketDidDisconnect(error: Error?) {}
    
    func webSocketDidReceiveEvent(type: String, payload: [String: Any]) {
        if type == "unread_update",
           let roomId = payload["room_id"] as? Int,
           let unread = payload["unread_count"] as? Int,
           let idx = rooms.firstIndex(where: { $0.id == roomId }) {
            
            rooms[idx].unreadCount = unread
            tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
        }
    }
}
