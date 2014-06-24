
import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var boxNode   : SCNNode!
    var playerBird: SCNNode!
    var cameraNode: SCNNode!
    var scene     : SCNScene!
    var grounds   : SCNNode[] = SCNNode[]()
    var walls     : SCNNode[] = SCNNode[]()
    var currentPos: Float = 0
    var speed     : Float = 0.01
    
    let groundNum: Int = 7

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
    
    func createWall() -> SCNNode {
        let wall     = SCNNode()
        let wallUp   = SCNNode()
        let wallDown = SCNNode()
        let wallGeo  = SCNBox(width: 1.0, height: 3.0, length: 0.2, chamferRadius: 0)
        let material = SCNMaterial()
        
        material.diffuse.contents  = UIImage(named: "texture")
        material.specular.contents = UIColor.grayColor()
        material.locksAmbientWithDiffuse = true
        wallGeo.firstMaterial = material
        
        wallUp.geometry = wallGeo
        wallUp.position = SCNVector3(x: 0, y: -0.5, z: 0)
        
        wallDown.geometry = wallGeo
        wallUp.position   = SCNVector3(x: 0, y: 0.5, z: 0)
        
        wall.addChildNode(wallUp)
        wall.addChildNode(wallDown)
        
        return wall
    }
    
    
    /**
     *  Set up field.
     */
    func setupField() {
        for i in 0..groundNum {
            let groundNode = SCNNode()
            let groundGeo  = SCNBox(width: 1, height: 0.5, length: 1, chamferRadius: 0)
            groundNode.geometry = groundGeo
            groundNode.position = SCNVector3(x: 0, y: -1.0, z: CFloat(-i))
            scene.rootNode.addChildNode(groundNode)
            
            let groundShape = SCNPhysicsShape(geometry: groundGeo, options: nil)
            groundNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: groundShape)
            
            let material = SCNMaterial()
            material.diffuse.contents  = UIImage(named: "texture")
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
//        let bridge = PhysWorldBridge()
//        bridge.physicsGravity(scene, withGravity: SCNVector3(x: 0, y: -98.0, z: 0))
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
        cameraNode.position = SCNVector3(x: 0.75, y: 0, z: 3.0)
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
        currentPos += speed
        let index: Int = Int(currentPos)
        let isPop: Bool = index != 0 && index % 2 == 0
        
//        if isPop {
//            let wall = createWall()
//            scene.rootNode.addChildNode(wall)
//            walls += wall
//        }
        
        for (i, g) in enumerate(grounds) {
            var pos: SCNVector3 = g.position
            pos.z += speed
            
            if pos.z > 2.5 {
                pos.z -= Float(groundNum)
                g.position = pos
            }
            else {
                g.position = pos
            }
        }
        
        for (i, w) in enumerate(walls) {
            var pos: SCNVector3 = w.position
            pos.z += speed
            
            if pos.z > 1.5 {
                w.removeFromParentNode()
                walls.removeAtIndex(i)
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
        let power: Float = 6.5
        playerBird.physicsBody.applyForce(SCNVector3(x: 0, y: power, z: 0), impulse: true)
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
