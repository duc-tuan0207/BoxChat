import UIKit

class RoomCell: UITableViewCell {
    static let identifier = "RoomCell"
    
    private let containerCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        iv.layer.cornerRadius = 24
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let unreadBadge: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemRed
        label.textColor = .white
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        contentView.addSubview(containerCard)
        containerCard.addSubview(avatarImageView)
        containerCard.addSubview(nameLabel)
        containerCard.addSubview(descriptionLabel)
        containerCard.addSubview(unreadBadge)
        
        containerCard.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        unreadBadge.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            avatarImageView.centerYAnchor.constraint(equalTo: containerCard.centerYAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: containerCard.leadingAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),
            
            nameLabel.topAnchor.constraint(equalTo: containerCard.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: unreadBadge.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerCard.bottomAnchor, constant: -14),
            
            unreadBadge.centerYAnchor.constraint(equalTo: containerCard.centerYAnchor),
            unreadBadge.trailingAnchor.constraint(equalTo: containerCard.trailingAnchor, constant: -14),
            unreadBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),
            unreadBadge.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func configure(with room: Room) {
        nameLabel.text = room.name
        descriptionLabel.text = room.lastMessage?.content ?? room.description ?? "Hãy bắt đầu cuộc trò chuyện..."
        
        if room.unreadCount > 0 {
            unreadBadge.text = "\(room.unreadCount)"
            unreadBadge.isHidden = false
        } else {
            unreadBadge.isHidden = true
        }
    }
}
