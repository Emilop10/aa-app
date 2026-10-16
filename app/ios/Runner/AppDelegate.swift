import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // --- NUEVO: Pide permiso para notificaciones ---
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    // -------------------------------------------

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// iOS 27 exige el ciclo de vida por escenas (UIScene). La escena carga Main.storyboard
// (el FlutterViewController) y le pasa su ventana al AppDelegate, porque Flutter y
// algunos plugins buscan la vista principal en `AppDelegate.window`.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard scene is UIWindowScene else { return }
    if let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate {
      appDelegate.window = window
    }
  }
}
