
import UIKit
import QuartzCore
import SceneKit
import AudioToolbox
import OpenGLES
import AVFoundation

class OpeningScene : SCNScene {
    
    var view: SCNView
    var playerBird: SCNNode!
    
    init(view: SCNView) {
        self.view = view
        super.init()
        
        setupEnv()
        createPlayer()
    }
    
    func createPlayer() {
        let fileName: String = "bird"
        let url: NSURL = NSBundle.mainBundle().URLForResource(fileName, withExtension: "dae")
        let sceneSource: SCNSceneSource = SCNSceneSource(URL: url, options: nil)
        
        playerBird = SCNNode()
        playerBird.position.y = 1.5
        
        let nodeNames  = sceneSource.identifiersOfEntriesWithClass(SCNNode.self)
        let body   = sceneSource.entryWithIdentifier("body",   withClass: SCNNode.self) as SCNNode
        let wing_L = sceneSource.entryWithIdentifier("wing_L", withClass: SCNNode.self) as SCNNode
        let wing_R = sceneSource.entryWithIdentifier("wing_R", withClass: SCNNode.self) as SCNNode
        playerBird.addChildNode(body)
        playerBird.addChildNode(wing_L)
        playerBird.addChildNode(wing_R)
        
        // println(sceneSource.identifiersOfEntriesWithClass(CAAnimation.self))
        let bodyAnim    = sceneSource.entryWithIdentifier("body_location_X",   withClass: CAAnimation.self) as CAAnimation
        playerBird.addAnimation(bodyAnim, forKey: "flap")
        
        rootNode.addChildNode(playerBird)
    }
    
    func setupEnv() {
        // create a new scene
        fogStartDistance = 13.0
        fogEndDistance   = 25.0
        fogColor         = UIColor.whiteColor()
        
        // set up the skybox.
        background.contents = [
            UIImage(named: "right"),
            UIImage(named: "left"),
            UIImage(named: "top"),
            UIImage(named: "bottom"),
            UIImage(named: "front"),
            UIImage(named: "back")
        ]
        
        var cameraNode = SCNNode()
        cameraNode.camera   = SCNCamera()
        cameraNode.position = SCNVector3(x: 2.5, y: 1.5, z: 3.5)
        cameraNode.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: 0.40)
        rootNode.addChildNode(cameraNode)
        
        let text     = SCNText(string: "Tappy Freak 3D", extrusionDepth: 5.0)
        let textNode = SCNNode(geometry: text)
        let s: CFloat = 0.033
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blueColor()
        material.reflective.contents = [
            UIImage(named: "right"),
            UIImage(named: "left"),
            UIImage(named: "top"),
            UIImage(named: "bottom"),
            UIImage(named: "front"),
            UIImage(named: "back")
        ]
        text.firstMaterial = material
        textNode.scale = SCNVector3(x: s, y: s, z: s)
        textNode.position = SCNVector3(x: -0.5, y: 0.5, z: 0)
        rootNode.addChildNode(textNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 1, y: 3, z: 5)
        rootNode.addChildNode(lightNode)
        
        let gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let recognizers = NSMutableArray()
        view.addGestureRecognizer(gesture)
//        recognizers.addObject(gesture)
//        recognizers.addObjectsFromArray(view.gestureRecognizers)
//        view.gestureRecognizers = recognizers
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        view.removeGestureRecognizer(gestureRecognize)
        view.scene = FlapScene(view: view)
    }
}
