import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Con escenas (iOS 27) la ventana no existe todavía en didFinishLaunching,
  // así que el motor de Flutter se crea aquí y los plugins se registran en él.
  // La escena (SceneDelegate) lo muestra después.
  lazy var flutterEngine = FlutterEngine(name: "main")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    flutterEngine.run()
    GeneratedPluginRegistrant.register(with: flutterEngine)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// iOS 27 exige el ciclo de vida por escenas (UIScene). La escena crea la ventana,
// le pone la vista de Flutter con el motor del AppDelegate y la comparte con el
// AppDelegate, porque algunos plugins buscan la vista principal en `AppDelegate.window`.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard
      let windowScene = scene as? UIWindowScene,
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
    else { return }

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = FlutterViewController(
      engine: appDelegate.flutterEngine, nibName: nil, bundle: nil)
    self.window = window
    appDelegate.window = window
    window.makeKeyAndVisible()
  }
}
