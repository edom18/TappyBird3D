
import UIKit
import QuartzCore
import SceneKit
import AudioToolbox
import AVFoundation

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    var scene     : SCNScene!
    
    /**
     *  Configure a view.
     */
    func configureView() {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        // scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a gameloop as delegate
        scnView.delegate = self
        
        // LobiRec.setCurrentContext(scnView.eaglContext, withGLView: scnView)
    }
    

    /**
     *  @override
     *  viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = OpeningScene(view: self.view as SCNView)
        
        // Configure a view.
        configureView()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }
}
