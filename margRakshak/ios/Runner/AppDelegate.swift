import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let path = Bundle.main.path(forResource: "keys", ofType: "plist"),
               let config = NSDictionary(contentsOfFile: path),
               let apiKey = config["GMAPSAPI"] as? String {
                GMSServices.provideAPIKey(apiKey)
            } else {
                print("Google Maps API Key not found in keys.plist")
            }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
