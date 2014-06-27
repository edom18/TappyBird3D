
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        LobiCore.setupClientId("c547cf3d2278017d3baffc41d23f121f9aab3607", accountBaseName: "TappyFreaks")
        LobiCore.setRootViewController(self.window?.rootViewController)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject) -> Bool {
        
        if (LobiCore.handleOpenURL(url)) {
            return true
        }
        
        return false
    }
}

