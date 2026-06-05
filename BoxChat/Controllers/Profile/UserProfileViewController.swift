import UIKit

class UserProfileViewController: UIViewController {
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.05
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .systemGray4
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        return iv
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let actionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let changePasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Đổi mật khẩu", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.backgroundColor = .systemBlue.withAlphaComponent(0.08)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.layer.cornerRadius = 14
        return btn
    }()
    
    private let logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Đăng xuất tài khoản", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.backgroundColor = .systemRed.withAlphaComponent(0.08)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.layer.cornerRadius = 14
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hồ Sơ"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground
        
        setupLayout()
        configureProfile()
        
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.addSubview(cardView)
        cardView.addSubview(avatarImageView)
        cardView.addSubview(displayNameLabel)
        cardView.addSubview(usernameLabel)
        
        view.addSubview(actionStackView)
        actionStackView.addArrangedSubview(changePasswordButton)
        actionStackView.addArrangedSubview(logoutButton)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Layout Card cá nhân
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 260),
            
            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            avatarImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            displayNameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            displayNameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            displayNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Layout Nút thao tác dưới Card
            actionStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            actionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            changePasswordButton.heightAnchor.constraint(equalToConstant: 48),
            logoutButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func configureProfile() {
        if let currentUser = TokenManager.shared.currentUser {
            displayNameLabel.text = currentUser.displayName
            usernameLabel.text = "@\(currentUser.username)"
        }
    }
    
    @objc private func didTapLogout() {
        WebSocketService.shared.disconnect()
        TokenManager.shared.clear()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            let loginVC = LoginViewController()
            window.rootViewController = loginVC
            
            UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}
