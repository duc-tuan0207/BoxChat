import UIKit

class SplashViewController: UIViewController {

    // Nền Gradient hiện đại (Đồng bộ tone màu với màn hình Login của bạn)
    private let backgroundGradient = CAGradientLayer()
    
    // Logo chữ BoxChat ở chính giữa màn hình
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "BoxChat"
        label.font = .systemFont(ofSize: 56, weight: .heavy)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.alpha = 0 // Bắt đầu bằng 0 để làm hiệu ứng hiện dần (Fade-in)
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupBackground()
        setupUI()
        animateLogoAndTransition()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Đảm bảo Gradient luôn khít với kích thước màn hình kể cả khi xoay
        backgroundGradient.frame = view.bounds
    }

    // MARK: - Setup UI
    private func setupBackground() {
        // Màu sắc Gradient nhẹ nhàng ở chế độ Light Mode
        backgroundGradient.colors = [
            UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 1.0).cgColor
        ]
        
        // Tự động chuyển sang màu tối sâu thẳm ở chế độ Dark Mode
        if traitCollection.userInterfaceStyle == .dark {
            backgroundGradient.colors = [
                UIColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.02, green: 0.05, blue: 0.1, alpha: 1.0).cgColor
            ]
        }
        
        backgroundGradient.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupUI() {
        view.addSubview(logoLabel)
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Căn logo luôn nằm chính giữa màn hình
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Animation & Logic
    private func animateLogoAndTransition() {
        // Thu nhỏ logo lại một chút trước khi chạy hiệu ứng
        logoLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Chạy hiệu ứng mượt mà: Logo vừa hiện rõ vừa phóng to về kích thước chuẩn
        UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
            self.logoLabel.alpha = 1
            self.logoLabel.transform = .identity
        }) { _ in
            
            // Giữ lại logo trên màn hình thêm 1 giây cho đẹp rồi mới chuyển cảnh
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigateNext()
            }
        }
    }

    private func navigateNext() {
        // Lấy đối tượng Window hiện tại từ SceneDelegate
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        
        let rootVC: UIViewController
        
        // KIỂM TRA ĐĂNG NHẬP: Quyết định màn hình tiếp theo sẽ hiển thị
        if TokenManager.shared.accessToken != nil {
            // Trường hợp 1: Đã có Token -> Kết nối mạng Socket và vào thẳng phòng chat
            WebSocketService.shared.connect()
            rootVC = MainTabBarController()
        } else {
            // Trường hợp 2: Chưa có Token -> Chuyển sang màn hình Đăng nhập của bạn
            rootVC = LoginViewController()
        }
        
        // Thực hiện chuyển đổi Root View Controller với hiệu ứng mờ dần (Cross Dissolve) siêu mượt
        window.rootViewController = rootVC
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
    
    // Hỗ trợ cập nhật màu nền khi người dùng đổi giao diện Light/Dark Mode hệ thống
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupBackground()
        }
    }
}
