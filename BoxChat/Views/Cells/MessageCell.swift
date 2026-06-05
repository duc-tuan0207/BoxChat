import UIKit

class MessageCell: UITableViewCell {
    static let identifier = "MessageCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private let messageImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .systemGray6
        iv.isHidden = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 9)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    
    private var imageWidthConstraint: NSLayoutConstraint!
    private var imageHeightConstraint: NSLayoutConstraint!
    private var imageTopConstraintToBubble: NSLayoutConstraint!
    private var labelTopConstraintToBubble: NSLayoutConstraint!
    private var labelBottomConstraintToBubble: NSLayoutConstraint!
    
    private var imageDownloadTask: URLSessionDataTask?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloadTask?.cancel()
        imageDownloadTask = nil
        messageImageView.image = nil
        messageImageView.isHidden = true
        messageLabel.isHidden = false
    }
    
    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(messageImageView)
        contentView.addSubview(statusLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        leftConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        rightConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        // Cố định kích thước ảnh tối đa trong bubble
        imageWidthConstraint = messageImageView.widthAnchor.constraint(equalToConstant: 200)
        imageHeightConstraint = messageImageView.heightAnchor.constraint(equalToConstant: 150)
        imageTopConstraintToBubble = messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8)
        
        labelTopConstraintToBubble = messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10)
        labelBottomConstraintToBubble = messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            
            bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.72),
            
            labelTopConstraintToBubble,
            labelBottomConstraintToBubble,
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            
            imageTopConstraintToBubble,
            messageImageView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            messageImageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            messageImageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            imageWidthConstraint,
            imageHeightConstraint,
            
            statusLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 1),
            statusLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -4)
        ])
    }
    
    func configure(with msg: Message, isMe: Bool) {
        imageDownloadTask?.cancel()
        imageDownloadTask = nil
        
        messageLabel.text = msg.content
        nameLabel.text = isMe ? nil : (msg.displayName ?? msg.username)
        nameLabel.isHidden = isMe
        
        // Kiểm tra xem tin nhắn có chứa ảnh/file không
        let isImage = msg.messageType == "file" || (msg.fileUrl != nil && (msg.fileUrl?.lowercased().hasSuffix(".jpg") == true || msg.fileUrl?.lowercased().hasSuffix(".jpeg") == true || msg.fileUrl?.lowercased().hasSuffix(".png") == true || msg.fileUrl?.lowercased().hasSuffix(".gif") == true))
        
        if isImage, let fileUrlString = msg.fileUrl, let url = URL(string: fileUrlString) {
            messageImageView.isHidden = false
            imageWidthConstraint.isActive = true
            imageHeightConstraint.isActive = true
            
            labelTopConstraintToBubble.isActive = false
            labelBottomConstraintToBubble.isActive = false
            imageTopConstraintToBubble.isActive = true
            
            if !msg.content.isEmpty {
                messageLabel.isHidden = false
                NSLayoutConstraint.activate([
                    messageLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 8),
                    messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
                ])
            } else {
                messageLabel.isHidden = true
                NSLayoutConstraint.activate([
                    messageImageView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
                ])
            }
            
            // Tải ảnh không đồng bộ
            imageDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self, let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.messageImageView.image = image
                }
            }
            imageDownloadTask?.resume()
        } else {
            messageImageView.isHidden = true
            imageWidthConstraint.isActive = false
            imageHeightConstraint.isActive = false
            
            labelTopConstraintToBubble.isActive = true
            labelBottomConstraintToBubble.isActive = true
            imageTopConstraintToBubble.isActive = false
            messageLabel.isHidden = false
        }
        
        if isMe {
            leftConstraint.isActive = false
            rightConstraint.isActive = true
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            
            switch msg.status {
            case "read": statusLabel.text = "Đã đọc ✓✓"
            case "delivered": statusLabel.text = "Đã nhận ✓"
            default: statusLabel.text = "Đang gửi"
            }
            statusLabel.isHidden = false
        } else {
            rightConstraint.isActive = false
            leftConstraint.isActive = true
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .label
            statusLabel.isHidden = true
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
