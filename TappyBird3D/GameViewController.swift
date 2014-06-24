
import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var boxNode: SCNNode!
    var playerBird: SCNNode!
    var cameraNode: SCNNode!
    var scene: SCNScene!

    /**
     *  Create a player bird object.
     */
    func createPlayer() {
        playerBird = SCNNode()
        
        let playerBirdGeo = SCNSphere(radius: 0.05)
        playerBird.geometry = playerBirdGeo
        playerBird.position = SCNVector3(x: 0, y: 1, z: 0)
        scene.rootNode.addChildNode(playerBird)

        let playerBirdShape = SCNPhysicsShape(geometry: playerBirdGeo, options: nil)
        playerBird.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: playerBirdShape)
    }
    
    /**
     *  Set up field.
     */
    func setupField() {
        // create and add a 3d box to the scene
        boxNode = SCNNode()
        let boxGeo  = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.02)
        boxNode.geometry = boxGeo
        boxNode.position = SCNVector3(x:0, y:-1, z:0)
        scene.rootNode.addChildNode(boxNode)
        
        let boxShape = SCNPhysicsShape(geometry: boxGeo, options: nil)
        boxNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: boxShape)
        
        // create and configure a material
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "texture")
        material.specular.contents = UIColor.grayColor()
        material.locksAmbientWithDiffuse = true
        
        // set the material to the 3d object geometry
        boxNode.geometry.firstMaterial = material
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
        bridge.physicsGravity(scene, withGravity: SCNVector3(x: 0, y: -98.0, z: 0))
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
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        
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
//        cameraNode.position.z -= 0.01
    }
    
    /**
     *  Handle tap gesture.
     *
     *  @param {UIGestureRecognizer} gestureRecognize
     */
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        playerBird.physicsBody.applyForce(SCNVector3(x: 0, y: 20.5, z: 0), impulse: true)
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
