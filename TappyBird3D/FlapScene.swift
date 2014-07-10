
import UIKit
import QuartzCore
import AudioToolbox
import OpenGLES
import AVFoundation
import SceneKit

let groundCategory: Int = 0x1 << 0
let playerCategory: Int = 0x1 << 1
let pipeCategory: Int   = 0x1 << 2

class FlapScene : SCNScene, SCNPhysicsContactDelegate {
    
    var playerBird: SCNNode!
    var cameraNode: SCNNode!
    var grounds   : [SCNNode] = [SCNNode]()
    var walls     : [SCNNode] = [SCNNode]()
    var currentPos: Float = 0
    var speed     : Float = 0.02
    var view      : SCNView

    var gameover  : Bool = false
    var audioPlayer = AVAudioPlayer()
    
    let groundNum: Int = 6
    let groundLength: Float = 4.0

    /**
     *  Initializer
     */
    init(view: SCNView) {
        self.view = view
//        self.view.allowsCameraControl = true
        
        super.init()
        
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
        
        // create and add a camera to the scene
        cameraNode = SCNNode()
        cameraNode.camera   = SCNCamera()
        cameraNode.position = SCNVector3(x: 2.5, y: 1.5, z: 3.5)
        cameraNode.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: 0.40)
        rootNode.addChildNode(cameraNode)
        
        // Create a player.
        createPlayer()
        
        // Set up environment.
        setupEnv()
        
        // Set up field.
        setupField()
        
        // Set up walls
        setupWalls()
        
        // Set up tap handler.
        setupHandleTap()
        
        // Start game loop.
        startGameLoop()
        
        // Start BGM.
        playNormalBGM()
    }
    
    /**
     *  Play bound sound.
     */
    func playBoundSound() {
        struct sound {
            static let url: NSURL = NSBundle.mainBundle().URLForResource("flap1", withExtension: "mp3")
        }
        playSound(sound.url)
    }
    
    /**
     *  Play fail sound.
     */
    func playFailSound() {
        struct sound {
            static let url: NSURL = NSBundle.mainBundle().URLForResource("fail1", withExtension: "mp3")
        }
        playSound(sound.url)
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
     *  Play normal BGM.
     */
    func playNormalBGM() {
        var bgmURL = NSBundle.mainBundle().URLForResource("bgm1", withExtension: "mp3")
        playBGM(bgmURL)
    }
    
    /**
     *  Play game over BGM.
     */
    func playGameoverBGM() {
        var bgmURL = NSBundle.mainBundle().URLForResource("fail_bgm1", withExtension: "mp3")
        playBGM(bgmURL)
    }
    
    /**
     *  Play BGM.
     */
    func playBGM(url: NSURL) {
        stopBGM()
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }

    /**
     *  Stop BGM.
     */
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
        
        rootNode.addChildNode(playerBird)
        
        let playerBirdShape = SCNPhysicsShape(node: playerBird, options: nil)
        playerBird.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: playerBirdShape)
        playerBird.physicsBody.categoryBitMask  = playerCategory
        playerBird.physicsBody.collisionBitMask = 0//pipeCategory | groundCategory
        println(pipeCategory | groundCategory)
    }
    
    
    /**
     *  Create walls as up and down.
     */
    func createWall() -> (SCNNode, SCNNode) {
        let wallHeight: CGFloat = 7.0
        let interval: CGFloat   = 1.5
        let url         = NSBundle.mainBundle().URLForResource("pipe", withExtension: "dae")
        let sceneSource = SCNSceneSource(URL: url, options: nil)
        let wallUp   = sceneSource.entryWithIdentifier("pipe_top", withClass: SCNNode.self) as SCNNode
        let wallDown = wallUp.clone() as SCNNode
        
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor(red: 0.03, green: 0.59, blue: 0.25, alpha: 1)
//
//        material.specular.contents = UIColor.grayColor()
//        material.locksAmbientWithDiffuse = true
        
        let wallGeo   = SCNCylinder(radius: 0.8, height: wallHeight)
//        let wallShape = SCNPhysicsShape(geometry: wallGeo, options: nil)
        let wallShape = SCNPhysicsShape(node: wallDown, options: nil)
//        wallGeo.firstMaterial = material
//        wallDown.geometry    = wallGeo
        wallDown.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: wallShape)
        wallDown.physicsBody.categoryBitMask  = pipeCategory
        wallDown.physicsBody.collisionBitMask = playerCategory
        let posYDown         = CFloat(-wallHeight / 2.0 - interval / 2.0 + 1.0)
        wallDown.position    = SCNVector3(x: 0, y: posYDown, z: 0)
        wallDown.rotation    = SCNVector4(x: 1, y: 0, z: 0, w: CFloat(M_PI / 2))
        
//        wallUp.geometry    = wallGeo
        wallUp.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: wallShape)
        wallUp.physicsBody.categoryBitMask  = pipeCategory
        wallUp.physicsBody.collisionBitMask = playerCategory
        let posYUp         = CFloat(wallHeight / 2.0 + interval / 2.0 + 1.0)
        wallUp.position    = SCNVector3(x: 0, y: posYUp, z: 0)
        
        return (wallUp, wallDown)
    }
    
    
    /**
     *  Set up walls.
     */
    func setupWalls() {
        for i in 0...groundNum {
            let (wallUp, wallDown) = createWall()
            let z = -CFloat(Float(i + 1) * groundLength)
            let delta: CFloat = CFloat(arc4random_uniform(UInt32(10))) / 10
            wallUp.position.z    = z
            wallUp.position.y   += delta
            wallDown.position.z  = z
            wallDown.position.y += delta
            rootNode.addChildNode(wallUp)
            rootNode.addChildNode(wallDown)
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
        
        // for hit test ground.
        let groundNode = SCNNode()
        groundNode.geometry = groundGeo
        groundNode.position = SCNVector3(x: 0, y: -1.0, z: 0)
        groundNode.opacity  = 0
        rootNode.addChildNode(groundNode)
        
        let groundShape = SCNPhysicsShape(geometry: groundGeo, options: nil)
        groundNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: groundShape)
        groundNode.physicsBody.categoryBitMask  = groundCategory
        groundNode.physicsBody.collisionBitMask = 0//playerCategory
        
        // create a floor.
        let floorNode     = SCNNode()
        let floor         = SCNFloor()
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.grayColor()
        floor.firstMaterial = floorMaterial
        floor.reflectivity  = 0.0
        floorNode.geometry = floor
        floorNode.position = SCNVector3(x: 0, y: -0.9, z: 0)
        rootNode.addChildNode(floorNode)
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
        rootNode.addChildNode(lightOmniNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light.type  = SCNLightTypeAmbient
        ambientLightNode.light.color = UIColor.darkGrayColor()
        rootNode.addChildNode(ambientLightNode)
        
        // configure a physics world.
        self.physicsWorld.gravity = SCNVector3(x: 0, y: -2.98, z: 0)
        self.physicsWorld.contactDelegate = self
//        let bridge = PhysWorldBridge()
//        // bridge.physicsDelegate(scene)
//        bridge.physicsGravity(self, withGravity: SCNVector3(x: 0, y: -2.98, z: 0))
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
     *  Do game over.
     */
    func doGameover() {
        playGameoverBGM()
        playFailSound()
    }
    
    func checkGameover() -> Bool {
        gameover =  playerBird.presentationNode().position.z != 0
        return gameover
    }

    /**
     *  Update the scene.
     */
    func update(displayLink: CADisplayLink) {
        
        if gameover {
            return
        }
        
        if gameover {
            doGameover()
//            LobiRec.stopCapturing()
            
//            if LobiRec.hasMovie() {
//                LobiRec.presentLobiPostWithTitle("title",
//                    postDescrition: "description",
//                    postScore: 30,
//                    postCategory: "category",
//                    prepareHandler: nil,
//                    afterHandler: nil)
//            }
            return
        }
        
        currentPos += speed
        
        let limitPos: Float = 4.0
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
    
    /**
    *  Set up to handel tap
    */
    func setupHandleTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        gestureRecognizers.addObjectsFromArray(view.gestureRecognizers)
        view.gestureRecognizers = gestureRecognizers
    }
    
    func physicsWorld(world: SCNPhysicsWorld!, didBeginContact contact: SCNPhysicsContact!) {
        println(contact)
    }
}