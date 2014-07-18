
import UIKit
import QuartzCore
import SceneKit
import AudioToolbox
import OpenGLES
import AVFoundation

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    var scene     : SCNScene!
    var frameBuffer: GLint = 0
    
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
    
//    func renderer(aRenderer: SCNSceneRenderer!, willRenderScene scene: SCNScene!, atTime time: NSTimeInterval) {
//        if (frameBuffer == 0) {
//            glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &frameBuffer)
//            LobiRec.createFramebuffer(GLuint(frameBuffer))
//            LobiRec.startCapturing()
//        }
//        LobiRec.prepareFrame()
//    }
//    
//    func renderer(aRenderer: SCNSceneRenderer!, didRenderScene scene: SCNScene!, atTime time: NSTimeInterval) {
//        LobiRec.appendFrame(GLuint(frameBuffer))
//    }
    
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
