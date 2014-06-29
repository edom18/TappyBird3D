
import UIKit
import QuartzCore
import SceneKit
import AudioToolbox
import OpenGLES
import AVFoundation

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
    var audioPlayer = AVAudioPlayer()
    
    let groundNum: Int = 6
    let groundLength: Float = 4.0
    
    var frameBuffer: GLint = 0
    
    /**
     *  Play bound sound.
     */
    func playBoundSound() {
        var soundURL: NSURL = NSBundle.mainBundle().URLForResource("flap1", withExtension: "mp3")
        playSound(soundURL)
    }
    /**
     *  Play fail sound.
     */
    func playFailSound() {
        var soundURL: NSURL = NSBundle.mainBundle().URLForResource("fail1", withExtension: "mp3")
        playSound(soundURL)
    }

    /**
     *  Play any sound.
     */
    func playSound(url: NSURL) {
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURLRef, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    /**
     *  Play BGM.
     */
    func playBGM() {
        var bgmURL = NSBundle.mainBundle().URLForResource("bgm1", withExtension: "mp3")
        audioPlayer = AVAudioPlayer(contentsOfURL: bgmURL, error: nil)
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
    }

    func stopBGM() {
        audioPlayer.stop()
    }

    /**
     *  Create a player bird object.
     */
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
        
        scene.rootNode.addChildNode(playerBird)
        
        let playerBirdShape = SCNPhysicsShape(node: playerBird, options: nil)
        playerBird.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: playerBirdShape)
    }
    
    
    /**
     *  Create walls as up and down.
     */
    func createWall() -> (SCNNode, SCNNode) {
        let wallHeight: CGFloat = 10.0
        let interval = CGFloat(1.2)
        let wallUp   = SCNNode()
        let wallDown = SCNNode()
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.03, green: 0.59, blue: 0.25, alpha: 1)

        material.specular.contents = UIColor.grayColor()
        material.locksAmbientWithDiffuse = true
        
        let wallGeo   = SCNCylinder(radius: 0.8, height: wallHeight)
        let wallShape = SCNPhysicsShape(geometry: wallGeo, options: nil)
        wallGeo.firstMaterial = material
        wallDown.geometry    = wallGeo
        wallDown.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: wallShape)
        let posYDown         = CFloat(-wallHeight / 2.0 - interval / 2.0 + 1.0)
        wallDown.position    = SCNVector3(x: 0, y: posYDown, z: 0)
        
        wallUp.geometry    = wallGeo
        wallUp.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: wallShape)
        let posYUp         = CFloat(wallHeight / 2.0 + interval / 2.0 + 1.0)
        wallUp.position    = SCNVector3(x: 0, y: posYUp, z: 0)
        
        return (wallUp, wallDown)
    }
    
    
    /**
     *  Set up walls.
     */
    func setupWalls() {
        for i in 0..groundNum {
            let (wallUp, wallDown) = createWall()
            let z = -CFloat(Float(i + 1) * groundLength)
            let delta: CFloat = CFloat(arc4random_uniform(UInt32(10))) / 10
            wallUp.position.z    = z
            wallUp.position.y   += delta
            wallDown.position.z  = z
            wallDown.position.y += delta
            scene.rootNode.addChildNode(wallUp)
            scene.rootNode.addChildNode(wallDown)
            walls += wallUp
            walls += wallDown
        }
    }
    
    /**
     *  Set up field.
     */
    func setupField() {
        let width:  CGFloat = 20.0
        let height: CGFloat = 0.5
        
        let groundGeo  = SCNBox(width: width, height: height, length: CGFloat(groundLength), chamferRadius: 0)
//        let material = SCNMaterial()
//        material.diffuse.contents  = UIImage(named: "ground")
//        material.diffuse.wrapT     = SCNWrapMode.Repeat
//        material.diffuse.wrapS     = SCNWrapMode.Repeat
//        material.specular.contents = UIColor.grayColor()
//        material.locksAmbientWithDiffuse = true
        
//        for i in 0..groundNum {
//            let groundNode = SCNNode()
//            groundNode.geometry = groundGeo
//            groundNode.position = SCNVector3(x: 0, y: -1.0, z: -CFloat(Float(i) * groundLength))
//            scene.rootNode.addChildNode(groundNode)
//            
//            groundNode.geometry.firstMaterial = material
//            grounds.append(groundNode)
//        }
        
        // for hit test ground.
        let groundNode = SCNNode()
        groundNode.geometry = groundGeo
        groundNode.position = SCNVector3(x: 0, y: -1.0, z: 0)
        groundNode.opacity = 0
        scene.rootNode.addChildNode(groundNode)
        
        let groundShape = SCNPhysicsShape(geometry: groundGeo, options: nil)
        groundNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: groundShape)
        
        // create a floor.
        let floorNode = SCNNode()
        let floor = SCNFloor()
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.grayColor()
        floor.firstMaterial = floorMaterial
        floor.reflectivity = 0.1
        floorNode.geometry = floor
        floorNode.position = SCNVector3(x: 0, y: -0.9, z: 0)
        scene.rootNode.addChildNode(floorNode)
    }
    
    /**
     *  Set up environment.
     */
    func setupEnv() {
        // create and add a light to the scene
        let lightOmniNode = SCNNode()
        lightOmniNode.position = SCNVector3(x: 0, y: 10, z: 10)
        lightOmniNode.light = SCNLight()
        lightOmniNode.light.type = SCNLightTypeOmni
        scene.rootNode.addChildNode(lightOmniNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light.type  = SCNLightTypeAmbient
        ambientLightNode.light.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        // configure a physics world.
        let bridge = PhysWorldBridge()
        // bridge.physicsDelegate(scene)
        bridge.physicsGravity(scene, withGravity: SCNVector3(x: 0, y: -2.98, z: 0))
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
        // scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a gameloop as delegate
        scnView.delegate = self
        
//        LobiRec.setCurrentContext(scnView.eaglContext, withGLView: scnView)
    }
    

    /**
     *  @override
     *  viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene()
        scene.fogStartDistance = 13.0
        scene.fogEndDistance   = 25.0
        scene.fogColor         = UIColor.whiteColor()
        
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
        cameraNode.position = SCNVector3(x: 2.5, y: 1.5, z: 3.5)
        cameraNode.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: 0.40)
        scene.rootNode.addChildNode(cameraNode)
        
        // Create a player.
        createPlayer()
        
        // Set up environment.
        setupEnv()
        
        // Set up field.
        setupField()
        
        // Set up walls
        setupWalls()
        
        // Configure a view.
        configureView()
        
        // Set up handle tap.
        setupHandleTap()
        
        // Start game loop.
        startGameLoop()
        
        // Start BGM.
        playBGM()
    }
    
    override func viewWillAppear(animated: Bool)  {
        audioPlayer.play()
    }
    

    /**
     *  Update the scene.
     */
    func update(displayLink: CADisplayLink) {
        
        if gameover {
            return
        }

        gameover = playerBird.presentationNode().position.z != 0
        
        if gameover {
            stopBGM()
            playFailSound()
//            LobiRec.stopCapturing()
            
//            if LobiRec.hasMovie() {
//                LobiRec.presentLobiPostWithTitle("title",
//                    postDescrition: "description",
//                    postScore: 30,
//                    postCategory: "category",
//                    prepareHandler: nil,
//                    afterHandler: nil)
//            }
        }
        
        currentPos += speed
        
        let limitPos: Float = 4.0
        
//        for (i, g) in enumerate(grounds) {
//            var pos: SCNVector3 = g.position
//            pos.z += speed
//            
//            if pos.z > limitPos {
//                pos.z -= Float(groundNum) * groundLength
//                g.position = pos
//            }
//            else {
//                g.position = pos
//            }
//        }
        
        for var i = 0, l = walls.count; i < l; i += 2 {
            let w1 = walls[i + 0]
            let w2 = walls[i + 1]
            
            var pos: SCNVector3 = w1.position
            pos.z += speed
            
            if pos.z > limitPos {
                pos.z -= Float(groundNum) * groundLength
                w1.position = pos
                w2.position.z = pos.z
            }
            else {
                w1.position = pos
                w2.position.z = pos.z
            }
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
        
        let power: Float = 1.8
        playerBird.physicsBody.applyForce(SCNVector3(x: 0, y: power, z: 0), impulse: true)
        playBoundSound()
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
