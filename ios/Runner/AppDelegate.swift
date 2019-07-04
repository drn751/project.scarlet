import UIKit
import Flutter
import AVFoundation
import Foundation


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    //Td client
      var client : UnsafeMutableRawPointer!
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    
    //Player playground
    var player = AVAudioPlayer()
    
    

    
    
    //Platform channeling code
    let lock = NSLock();
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "tdjsonlib",
                                              binaryMessenger: controller)
    
    methodChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        DispatchQueue.global(qos: .utility).async {
            lock.lock()
            switch(call.method){
            case "create":
                self?.client = td_json_client_create()
                result(nil)
                print("Created successfully");
            case "send":
                let args = call.arguments as! [String : Any]
                td_json_client_send(self?.client, args["request"] as! String)
                result(nil)
                print("Sent successfully");
            case "receive":
                let args = call.arguments as! [String : Any]
                if let res = td_json_client_receive(self?.client, args["delay"] as! Double) {
                    let event = String(cString: res)
                    result(event)
                }else{
                    result(nil)
                }
                print("Received successfully");
            case "execute":
                let args = call.arguments as! [String : Any]
                if let res = td_json_client_execute(self?.client, args["request"] as! String) {
                    let event = String(cString: res)
                    result(event)
                }
                print("Executed successfully");
            case "destroy":
                td_json_client_destroy(self?.client)
                result(nil)
                print("Destroyed successfully");
            case "play":
                let args = call.arguments as! [String : Any]
                do {
                    player = try AVAudioPlayer(contentsOf: getURL(title: args["title"] as! String))
                } catch {
                    print("Something wrong")
                }
                player.play()
                print("Playing");
            case "pause":
                player.pause()
                print("Paused");
            default:
                result(FlutterMethodNotImplemented)
                return
            }
            lock.unlock();
        }
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
    
}

func getURL(title : String) -> URL{
    let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .allDomainsMask, true).first
    let path = "\(dir!)/music/\(title)"
    return URL(fileURLWithPath: path)
}
