import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyDULR1PxZjlXxdnV4-Btx_ZF3WFf1ocsYw")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
