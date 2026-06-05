import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // 1. Gán Splash Screen làm màn hình đầu tiên khi mở App
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        WebSocketService.shared.disconnect()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Mở lại WebSocket nếu user đã có token và mở app lên lại
        if TokenManager.shared.accessToken != nil {
            WebSocketService.shared.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Ngắt WebSocket khi vuốt app ra ngoài màn hình chính để tiết kiệm pin
        WebSocketService.shared.disconnect()
    }
}
