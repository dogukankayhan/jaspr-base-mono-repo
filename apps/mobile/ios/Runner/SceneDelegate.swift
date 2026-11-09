import Flutter
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let flutterViewController = FlutterViewController(
      engine: appDelegate.flutterEngine,
      nibName: nil,
      bundle: nil
    )

    let channel = FlutterMethodChannel(
      name: "com.yourcompany.baseapp/environment",
      binaryMessenger: flutterViewController.binaryMessenger
    )
    channel.setMethodCallHandler { (call, result) in
      if call.method == "getEnvironmentConfig" {
        let infoPlist = Bundle.main.infoDictionary ?? [:]
        result([
          "appName": infoPlist["CFBundleDisplayName"] as? String ?? "",
          "baseUrl": infoPlist["BaseUrl"] as? String ?? "",
          "googleServerClientId": infoPlist["GoogleServerClientId"] as? String ?? "",
        ])
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let securityChannel = FlutterMethodChannel(
      name: "com.yourcompany.baseapp/security",
      binaryMessenger: flutterViewController.binaryMessenger
    )
    securityChannel.setMethodCallHandler { (call, result) in
      if call.method == "isJailbroken" {
        result(JailbreakDetector.isJailbroken())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = flutterViewController
    window?.makeKeyAndVisible()
  }
}
