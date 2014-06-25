
import UIKit
import QuartzCore
import SceneKit
import AudioToolbox

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    var boxNode   : SCNNode!
    var playerBird: SCNNode!
    var cameraNode: SCNNode!
    var scene     : SCNScene!
    var grounds   : SCNNode[] = SCNNode[]()
    var walls     : SCNNode[] = SCNNode[]()
    var currentPos: Float = 0
    var speed     : Float = 0.02

    var gameover  : Bool = false
    
    let groundNum: Int = 7
    let groundLength: Float = 4.0
    
    /**
     *  Play bound sound.
     */
    func playBoundSound() {
        var soundID: SystemSoundID = 0
        var soundURL: NSURL = NSBundle.mainBundle().URLForResource("pipo", withExtension: "wav")
        AudioServicesCreateSystemSoundID(soundURL as CFURLRef, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }

    /**
     *  Create a player bird object.
     */
    func createPlayer() {
        playerBird = SCNNode()
        
        let playerBirdGeo = SCNSphere(radius: 0.08)
        playerBird.geometry = playerBirdGeo
        playerBird.position = SCNVector3(x: 0, y: 1, z: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.grayColor()
        material.specular.contents = UIColor.whiteColor()
        material.reflective.contents = [
            UIImage(named: "right"),
            UIImage(named: "left"),
            UIImage(named: "top"),
            UIImage(named: "bottom"),
            UIImage(named: "front"),
            UIImage(named: "back")
        ]
        playerBird.geometry.firstMaterial = material
        
        scene.rootNode.addChildNode(playerBird)

        let playerBirdShape = SCNPhysicsShape(geometry: playerBirdGeo, options: nil)
        playerBird.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: playerBirdShape)
    }
    
    func createWall() -> (SCNNode, SCNNode) {
        let wall     = SCNNode()
        let wallUp   = SCNNode()
        let wallDown = SCNNode()
        let wallGeo  = SCNBox(width: 1.0, height: 1.0, length: 0.5, chamferRadius: 0)
        let material = SCNMaterial()
        let wallShape = SCNPhysicsShape(geometry: wallGeo, options: nil)
        let wallBody  = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: wallShape)
        
        material.diffuse.contents  = UIImage(named: "texture")
        material.specular.contents = UIColor.grayColor()
        material.locksAmbientWithDiffuse = true
        wallGeo.firstMaterial = material
        
        wallUp.geometry    = wallGeo
        wallUp.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: wallShape)
        wallUp.position    = SCNVector3(x: 0, y: 2.0, z: -1.0)
        
        wallDown.geometry    = wallGeo
        wallDown.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: wallShape)
        wallDown.position    = SCNVector3(x: 0, y: -0.25, z: -1.0)
        
        return (wallUp, wallDown)
    }
    
    
    /**
     *  Set up field.
     */
    func setupField() {
        let width:  CGFloat = 20.0
        let height: CGFloat = 0.5
        
        for i in 0..groundNum {
            let groundNode = SCNNode()
            let groundGeo  = SCNBox(width: width, height: height, length: CGFloat(groundLength), chamferRadius: 0)
            groundNode.geometry = groundGeo
            groundNode.position = SCNVector3(x: 0, y: -1.0, z: -CFloat(Float(i) * groundLength))
            scene.rootNode.addChildNode(groundNode)
            
            let groundShape = SCNPhysicsShape(geometry: groundGeo, options: nil)
            groundNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: groundShape)
            
            let material = SCNMaterial()
            material.diffuse.contents  = UIImage(named: "texture")
            material.diffuse.wrapT     = SCNWrapMode.Repeat
            material.diffuse.wrapS     = SCNWrapMode.Repeat
            material.specular.contents = UIColor.grayColor()
            material.locksAmbientWithDiffuse = true
            groundNode.geometry.firstMaterial = material
            
            grounds.append(groundNode)
        }
    }
    
    /**
     *  Set up environment.
     */
    func setupEnv() {
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        lightNode.light = SCNLight()
        lightNode.light.type = SCNLightTypeOmni
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light.type  = SCNLightTypeAmbient
        ambientLightNode.light.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // configure a physics world.
        let bridge = PhysWorldBridge()
//        bridge.physicsDelegate(scene)
        // bridge.physicsGravity(scene, withGravity: SCNVector3(x: 0, y: -98.0, z: 0))
    }
    
    
    /**
     *  Start game loop.
     *
     *  Game logic updating is in `update:` method.
     */
    func startGameLoop() {
        var displayLink: CADisplayLink = CADisplayLink(target: self, selector: "update:")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    
    /**
     *  Set up to handel tap
     */
    func setupHandleTap() {
        let scnView = self.view as SCNView
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        gestureRecognizers.addObjectsFromArray(scnView.gestureRecognizers)
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    
    /**
     *  Configure a view.
     */
    func configureView() {
        // retrieve the SCNView
        let scnView = self.view as SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a gameloop as delegate
        scnView.delegate = self
    }
    

    /**
     *  @override
     *  viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene()
        
        // set up the skybox.
        scene.background.contents = [
            UIImage(named: "right"),
            UIImage(named: "left"),
            UIImage(named: "top"),
            UIImage(named: "bottom"),
            UIImage(named: "front"),
            UIImage(named: "back")
        ]
        
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode.camera   = SCNCamera()
        cameraNode.position = SCNVector3(x: 0.75, y: 1.0, z: 3.0)
        cameraNode.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: 0.2)
        scene.rootNode.addChildNode(cameraNode)
        
        // Create a player.
        createPlayer()
        
        // Set up environment.
        setupEnv()
        
        // Set up field.
        setupField()
        
        // Configure a view.
        configureView()
        
        // Set up handle tap.
        setupHandleTap()
        
        // Start game loop.
        startGameLoop()
    }
    
    func update(displayLink: CADisplayLink) {
        
        if gameover {
            return
        }

        gameover = playerBird.presentationNode().position.z > 0
        
        currentPos += speed
        
        let limitPos: Float = 4.0
        
        for (i, g) in enumerate(grounds) {
            var pos: SCNVector3 = g.position
            pos.z += speed
            
            if pos.z > limitPos {
                pos.z -= Float(groundNum) * groundLength
                g.position = pos
                
                let (wallUp, wallDown) = createWall()
                scene.rootNode.addChildNode(wallUp)
                scene.rootNode.addChildNode(wallDown)
                walls += wallUp
                walls += wallDown
            }
            else {
                g.position = pos
            }
        }
        
        for (i, w) in enumerate(walls) {
            var pos: SCNVector3 = w.position
            pos.z += speed
            
            if pos.z > limitPos {
                w.removeFromParentNode()
//                walls.removeAtIndex(i)
                continue
            }
            
            w.position = pos
        }
    }
    
    /**
     *  Handle tap gesture.
     *
     *  @param {UIGestureRecognizer} gestureRecognize
     */
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        
        if gameover {
            return
        }
        
        let power: Float = 6.5
        playerBird.physicsBody.applyForce(SCNVector3(x: 0, y: power, z: 0), impulse: true)
        playBoundSound()
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
