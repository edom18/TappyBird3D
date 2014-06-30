
import UIKit
import QuartzCore
import SceneKit
import AudioToolbox
import OpenGLES
import AVFoundation

class OpeningScene : SCNScene {
    
    var view: SCNView
    
    init(view: SCNView) {
        self.view = view
        super.init()
        
        setupEnv()
    }
    
    func setupEnv() {
        var cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 15)
        rootNode.addChildNode(cameraNode)
        
        let text     = SCNText(string: "Tappy Freak 3D", extrusionDepth: 2.0)
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        textNode.position = SCNVector3(x: -4.0, y: 0, z: 0)
        rootNode.addChildNode(textNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 1, y: 3, z: 5)
        rootNode.addChildNode(lightNode)
        
        background.contents = UIColor.whiteColor()
        
        let gesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let recognizers = NSMutableArray()
        recognizers.addObject(gesture)
        recognizers.addObjectsFromArray(view.gestureRecognizers)
        view.gestureRecognizers = recognizers
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        view.scene = FlapScene(view: view)
    }
}
