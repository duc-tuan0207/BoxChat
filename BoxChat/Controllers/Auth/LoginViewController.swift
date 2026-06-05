import UIKit

class LoginViewController: UIViewController {
    
    private let backgroundGradient = CAGradientLayer()
    private var cardCenterYConstraint: NSLayoutConstraint?
    
    private let cardShadowView: UIView = {
            let v = UIView()
            v.backgroundColor = .clear
            v.layer.shadowColor = UIColor.black.cgColor
            v.layer.shadowOpacity = 0.12
            v.layer.shadowRadius = 25
            v.layer.shadowOffset = CGSize(width: 0, height: 12)
            return v
        }()
    
    private let glassCardView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let v = UIVisualEffectView(effect: blurEffect)
        v.layer.cornerRadius = 28
        v.layer.masksToBounds = true
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        return v
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BoxChat"
        label.font = .systemFont(ofSize: 44, weight: .heavy)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Chào mừng trở lại! Vui lòng đăng nhập."
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private lazy var usernameField: UITextField = createCustomTextField(
        placeholder: "Tên đăng nhập",
        iconName: "person.fill",
        isSecure: false
    )
    
    private lazy var passwordField: UITextField = createCustomTextField(
        placeholder: "Mật khẩu",
        iconName: "lock.fill",
        isSecure: true
    )
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Đăng nhập", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 22
        
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()
    
    private let bottomPromptButton: UIButton = {
        let btn = UIButton(type: .system)
        let attrTitle = NSMutableAttributedString(
            string: "Chưa có tài khoản? ",
            attributes: [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: 15, weight: .medium)]
        )
        attrTitle.append(NSAttributedString(
            string: "Đăng ký ngay",
            attributes: [.foregroundColor: UIColor.systemBlue, .font: UIFont.systemFont(ofSize: 15, weight: .bold)]
        ))
        btn.setAttributedTitle(attrTitle, for: .normal)
        btn.addTarget(self, action: #selector(didTapSignUpPrompt), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupBackground()
        setupLayout()
        setupKeyboardObservers()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    private func setupBackground() {
        backgroundGradient.colors = [
            UIColor(red: 0.92, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.85, green: 0.88, blue: 0.98, alpha: 1.0).cgColor
        ]
        
        if traitCollection.userInterfaceStyle == .dark {
            backgroundGradient.colors = [
                UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0).cgColor,
                UIColor(red: 0.02, green: 0.04, blue: 0.08, alpha: 1.0).cgColor
            ]
        }
        
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    private func setupLayout() {
        view.addSubview(cardShadowView)
        cardShadowView.addSubview(glassCardView)
        view.addSubview(bottomPromptButton)
        
        cardShadowView.translatesAutoresizingMaskIntoConstraints = false
        glassCardView.translatesAutoresizingMaskIntoConstraints = false
        bottomPromptButton.translatesAutoresizingMaskIntoConstraints = false
        
        let textFieldsStack = UIStackView(arrangedSubviews: [usernameField, passwordField])
        textFieldsStack.axis = .vertical
        textFieldsStack.spacing = 16
        
        let mainStack = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, textFieldsStack, actionButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.setCustomSpacing(8, after: titleLabel)
        mainStack.setCustomSpacing(28, after: textFieldsStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        glassCardView.contentView.addSubview(mainStack)
        actionButton.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        cardCenterYConstraint = cardShadowView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            cardCenterYConstraint!,
            cardShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            glassCardView.topAnchor.constraint(equalTo: cardShadowView.topAnchor),
            glassCardView.bottomAnchor.constraint(equalTo: cardShadowView.bottomAnchor),
            glassCardView.leadingAnchor.constraint(equalTo: cardShadowView.leadingAnchor),
            glassCardView.trailingAnchor.constraint(equalTo: cardShadowView.trailingAnchor),
            
            mainStack.topAnchor.constraint(equalTo: glassCardView.topAnchor, constant: 36),
            mainStack.leadingAnchor.constraint(equalTo: glassCardView.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: glassCardView.trailingAnchor, constant: -24),
            mainStack.bottomAnchor.constraint(equalTo: glassCardView.bottomAnchor, constant: -36),
            
            usernameField.heightAnchor.constraint(equalToConstant: 54),
            passwordField.heightAnchor.constraint(equalToConstant: 54),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            
            bottomPromptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bottomPromptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func createCustomTextField(placeholder: String, iconName: String, isSecure: Bool) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.isSecureTextEntry = isSecure
        tf.autocapitalizationType = .none
        tf.font = .systemFont(ofSize: 16)
        
        // Background Kính tinh tế hơn cho ô nhập liệu
        tf.backgroundColor = UIColor.label.withAlphaComponent(0.04)
        tf.layer.cornerRadius = 14
        tf.clipsToBounds = true
        
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 54))
        iconView.frame = CGRect(x: 16, y: 17, width: 20, height: 20)
        iconContainer.addSubview(iconView)
        
        tf.leftView = iconContainer
        tf.leftViewMode = .always
        
        if isSecure {
            let eyeButton = UIButton(type: .custom)
            eyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
            eyeButton.tintColor = .secondaryLabel
            eyeButton.frame = CGRect(x: 0, y: 0, width: 46, height: 54)
            eyeButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
            
            tf.rightView = eyeButton
            tf.rightViewMode = .always
        } else {
            tf.clearButtonMode = .whileEditing
        }
        
        return tf
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordField.isSecureTextEntry = !sender.isSelected
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let targetY = (view.frame.height - keyboardHeight) / 2
            let cardHeight = cardShadowView.frame.height
            
            if targetY < cardHeight / 2 + 40 {
                UIView.animate(withDuration: 0.3) {
                    self.cardCenterYConstraint?.constant = -(keyboardHeight / 2 - 20)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.cardCenterYConstraint?.constant = -10
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func didTapSignUpPrompt() {
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen // Chuyển full màn hình cho trải nghiệm mượt mà hơn formSheet
        present(registerVC, animated: true)
    }
    
    @objc private func didTapLogin() {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(message: "Vui lòng nhập đầy đủ thông tin.")
            return
        }
        
        dismissKeyboard()
        activityIndicator.startAnimating()
        actionButton.setTitle("", for: .normal)
        actionButton.isEnabled = false
        
        let params = ["username": username, "password": password]
        NetworkManager.shared.login(params: params) { [weak self] result in
            self?.handleAuthResult(result)
        }
    }
    
    private func handleAuthResult(_ result: Result<AuthData, Error>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.actionButton.setTitle("Đăng nhập", for: .normal)
            self.actionButton.isEnabled = true
            
            switch result {
            case .success:
                WebSocketService.shared.connect()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    
                    let mainTabBarVC = MainTabBarController()
                    window.rootViewController = mainTabBarVC
                    UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đã hiểu", style: .default))
        present(alert, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupBackground()
        }
    }
}
