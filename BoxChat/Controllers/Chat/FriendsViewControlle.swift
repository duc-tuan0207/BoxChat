import UIKit

class FriendsViewController: UIViewController {
    
    private let tableView = UITableView()
    private var friends: [RoomMember] = [] // Danh bạ bạn bè mẫu tải từ database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bạn Bè"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
        loadMockFriends()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendCell.identifier)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadMockFriends() {
        // Load mẫu một số bạn bè tương ứng với dữ liệu database mẫu của dự án
        let decoder = JSONDecoder()
        let sampleData = """
        [
            {"user_id": 2, "username": "minhkhoa", "display_name": "Minh Khoa", "role": "member", "is_online": true, "joined_at": "2026-05-31T10:00:00Z"},
            {"user_id": 3, "username": "thuynguyen", "display_name": "Thùy Nguyễn", "role": "owner", "is_online": true, "joined_at": "2026-05-31T10:00:00Z"},
            {"user_id": 4, "username": "hoanganh", "display_name": "Hoàng Anh", "role": "member", "is_online": false, "joined_at": "2026-05-31T10:00:00Z"},
            {"user_id": 5, "username": "baolong", "display_name": "Bảo Long", "role": "admin", "is_online": true, "joined_at": "2026-05-31T10:00:00Z"},
            {"user_id": 6, "username": "phuonglinh", "display_name": "Phương Linh", "role": "member", "is_online": false, "joined_at": "2026-05-31T10:00:00Z"}
        ]
        """.data(using: .utf8)!
        
        if let decoded = try? decoder.decode([RoomMember].self, from: sampleData) {
            self.friends = decoded
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.identifier, for: indexPath) as! FriendCell
        cell.configure(with: friends[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Friend Cell View
class FriendCell: UITableViewCell {
    static let identifier = "FriendCell"
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .systemGray4
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 22
        iv.clipsToBounds = true
        return iv
    }()
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemBackground.cgColor
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let statusTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(statusIndicator)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusTextLabel)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),
            
            statusIndicator.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 2),
            statusIndicator.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 2),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            statusTextLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -2),
            statusTextLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusTextLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    func configure(with friend: RoomMember) {
        nameLabel.text = friend.displayName
        statusIndicator.backgroundColor = friend.isOnline ? .systemGreen : .systemGray4
        statusTextLabel.text = friend.isOnline ? "Đang hoạt động" : "Ngoại tuyến"
    }
}
