import UIKit
import ProgressHUD
import Photos

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        ProgressHUD.animationType = .squareCircuitSnake
        ProgressHUD.colorHUD = .clear
        ProgressHUD.colorAnimation = .lightGray
        ProgressHUD.mediaSize = 50
        ProgressHUD.marginSize = 0
        
        // Request photo library authorization
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Access to photo library granted")
            case .denied, .restricted:
                print("Access to photo library denied")
            case .notDetermined:
                print("Access to photo library not determined")
            case .limited:
                print("some code")
            @unknown default:
                print("Unexpected status")
            }
        }
        
        // Request camera authorization
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Access to camera granted")
            } else {
                print("Access to camera denied")
            }
        }
        
        // Request activity sharing authorization
        let activityViewController = UIActivityViewController(activityItems: [], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if completed {
                print("Activity sharing completed")
            } else {
                print("Activity sharing canceled")
            }
        }
        
        return true
    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Main", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = SceneDelegate.self
        return sceneConfiguration
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
   }
}
