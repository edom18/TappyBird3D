
import UIKit
import QuartzCore
import AudioToolbox
import OpenGLES
import AVFoundation
import SceneKit

let groundCategory: Int = 1 << 2
let playerCategory: Int = 1 << 3
let pipeCategory: Int   = 1 << 4

class FlapScene : SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    var playerBird: SCNNode!
    var cameraNode: SCNNode!
    var grounds   : [SCNNode] = [SCNNode]()
    var walls     : [SCNNode] = [SCNNode]()
    var currentPos: Float = 0
    var currentPipe: Int = 0
    var limitInterval: Float = 5.5
    var speed     : Float = -1.00
    var view      : SCNView

    var gameover  : Bool = false
    var audioPlayer = AVAudioPlayer()
    
    let groundNum: Int = 6
    let groundLength: Float = 4.0
    let cameraPos: SCNVector3 = SCNVector3(x: 2.5, y: 1.5, z: 3.5)
    
    var frameBuffer: GLint = 0

    /**
     *  Initializer
     */
    init(view: SCNView) {
        self.view = view
        // self.view.allowsCameraControl = true
        
        super.init()
        
        LobiRec.setCurrentContext(self.view.eaglContext, withGLView: self.view)
        
        self.view.delegate = self
        
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
        cameraNode.position = cameraPos
        cameraNode.rotation = SCNVector4(x: 0, y: 1.0, z: 0, w: 0.40)
        rootNode.addChildNode(cameraNode)
        
        // Create a player.
        createPlayer()
        
        // Set up environment.
        setupEnv()
        
        // Set up field.
        // setupField()
        
        // Set up walls
        setupWalls()
        
        // Set up tap handler.
        setupHandleTap()
        
        // Start BGM.
        playNormalBGM()
        
        // view.pointOfView = cameraNode
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
        
        println("--------------- Create a player bird. -----------------")
        
        let url = NSBundle.mainBundle().URLForResource("bird", withExtension: "dae")
        let sceneSource = SCNSceneSource(URL: url, options: nil)
        
        playerBird = SCNNode()
        playerBird.position.y = 1.5
        
        let nodeNames = sceneSource.identifiersOfEntriesWithClass(SCNNode.self)
        let body   = sceneSource.entryWithIdentifier("body",   withClass: SCNNode.self) as SCNNode
        let wing_L = sceneSource.entryWithIdentifier("wing_L", withClass: SCNNode.self) as SCNNode
        let wing_R = sceneSource.entryWithIdentifier("wing_R", withClass: SCNNode.self) as SCNNode
        playerBird.addChildNode(body)
        playerBird.addChildNode(wing_L)
        playerBird.addChildNode(wing_R)
        
        // println(sceneSource.identifiersOfEntriesWithClass(CAAnimation.self))
        let bodyAnim = sceneSource.entryWithIdentifier("body_location_X", withClass: CAAnimation.self) as CAAnimation
        playerBird.addAnimation(bodyAnim, forKey: "flap")
        
        rootNode.addChildNode(playerBird)
        
        let playerBirdGeo      = SCNSphere(radius: 0.2)
        let playerBirdShape    = SCNPhysicsShape(geometry: playerBirdGeo, options: nil)
        playerBird.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Dynamic, shape: playerBirdShape)
        // playerBird.physicsBody.categoryBitMask  = playerCategory
        // playerBird.physicsBody.collisionBitMask = pipeCategory | groundCategory
    }
    
    
    /**
     *  Create walls as up and down.
     */
    func createWall() -> SCNNode {
        let wallHeight: CGFloat = 20.0
        let interval: CGFloat   = 1.5
        let posYDown = CFloat(-wallHeight / 2.0 - interval / 2.0 + 1.0)
        let posYUp   = CFloat( wallHeight / 2.0 + interval / 2.0 + 1.0)
        
        var wall     = SCNNode()
        var wallUp   = SCNNode()
        var wallDown = SCNNode()
        
        // a bit heavy to use a model.
        var useModel = false
        if useModel {
            let url         = NSBundle.mainBundle().URLForResource("pipe", withExtension: "dae")
            let sceneSource = SCNSceneSource(URL: url, options: nil)
            wallUp   = sceneSource.entryWithIdentifier("pipe_top", withClass: SCNNode.self) as SCNNode
            wallDown = wallUp.clone() as SCNNode
            
            let wallShape = SCNPhysicsShape(node: wallDown, options: nil)
            wallDown.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: wallShape)
            // wallDown.physicsBody.categoryBitMask  = pipeCategory
            // wallDown.physicsBody.collisionBitMask = playerCategory
            wallDown.position    = SCNVector3(x: 0, y: posYDown, z: 0)
            wallDown.rotation    = SCNVector4(x: 1, y: 0, z: 0, w: CFloat(M_PI / 2))
            
            wallUp.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: wallShape)
            // wallUp.physicsBody.categoryBitMask  = pipeCategory
            // wallUp.physicsBody.collisionBitMask = playerCategory
            wallUp.position = SCNVector3(x: 0, y: posYUp, z: 0)
        }
        else {
            let material = SCNMaterial()
            // material.diffuse.contents  = UIColor(red: 0.03, green: 0.59, blue: 0.25, alpha: 1)
            material.diffuse.contents  = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            material.specular.contents = UIColor.grayColor()
            material.reflective.contents = [
                UIImage(named: "right"),
                UIImage(named: "left"),
                UIImage(named: "top"),
                UIImage(named: "bottom"),
                UIImage(named: "front"),
                UIImage(named: "back")
            ]
            material.locksAmbientWithDiffuse = true
            
            let wallGeo   = SCNCylinder(radius: 0.8, height: wallHeight)
            let wallShape = SCNPhysicsShape(geometry: wallGeo, options: nil)
            wallGeo.firstMaterial = material
            wallDown.geometry    = wallGeo
            wallDown.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: wallShape)
            // wallDown.physicsBody.categoryBitMask  = pipeCategory
            // wallDown.physicsBody.collisionBitMask = playerCategory
            wallDown.position    = SCNVector3(x: 0, y: posYDown, z: 0)
            
            wallUp.geometry    = wallGeo
            wallUp.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Kinematic, shape: wallShape)
            // wallUp.physicsBody.categoryBitMask  = pipeCategory
            // wallUp.physicsBody.collisionBitMask = playerCategory
            wallUp.position = SCNVector3(x: 0, y: posYUp, z: 0)
        }
        
        wall.addChildNode(wallUp)
        wall.addChildNode(wallDown)
        
        return wall
    }
    
    
    /**
     *  Set up walls.
     */
    func setupWalls() {
        for i in 0...(groundNum - 1) {
            let wall = createWall()
            let z = -CFloat(Float(i + 1) * groundLength)
            let delta: CFloat = CFloat(arc4random_uniform(UInt32(10))) / 10
            wall.position.z  = z
            wall.position.y += delta
            rootNode.addChildNode(wall)
            walls += wall
        }
    }
    
    
    /**
     *  Swap walls.
     */
    func swapWall() {
        // pickup 2 walls.
        let tmp = walls[0]
        let pipePos = groundNum + currentPipe
        let z: CFloat = -CFloat(Float(pipePos) * groundLength)
        let delta: CFloat = CFloat(arc4random_uniform(UInt32(10))) / 10
        tmp.position.z  = z
        tmp.position.y += delta
        
        walls[0...(walls.count - 2)] = walls[1...(walls.count - 1)]
        walls[walls.count - 1] = tmp
    }
    
    
    /**
     *  Set up field.
     */
    func setupField() {
        // create a floor.
        let floorNode     = SCNNode()
        let floor         = SCNFloor()
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.grayColor()
        floor.firstMaterial   = floorMaterial
        floor.reflectivity    = 0.0
        floorNode.geometry    = floor
        let floorPysicsShape  = SCNPhysicsShape(geometry: floor, options: nil)
        floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.Static, shape: floorPysicsShape)
        floorNode.position    = SCNVector3(x: 0, y: -0.9, z: 0)
        rootNode.addChildNode(floorNode)
    }
    
    /**
     *  Set up environment.
     */
    func setupEnv() {
        // create and add a light to the scene
        let lightOmniNode = SCNNode()
        lightOmniNode.position   = SCNVector3(x: 0, y: 10, z: 10)
        lightOmniNode.light      = SCNLight()
        lightOmniNode.light.type = SCNLightTypeOmni
        rootNode.addChildNode(lightOmniNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light       = SCNLight()
        ambientLightNode.light.type  = SCNLightTypeAmbient
        ambientLightNode.light.color = UIColor.darkGrayColor()
        rootNode.addChildNode(ambientLightNode)
        
        // configure a physics world.
        self.physicsWorld.gravity = SCNVector3(x: 0, y: -2.98, z: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    
    /**
     *  Do game over.
     */
    func doGameover() {
        
        if self.gameover {
            return
        }
        
        self.gameover = true
        self.playGameoverBGM()
        self.playFailSound()
        
        LobiRec.stopCapturing()
        
        if LobiRec.hasMovie() {
            let delay = 2 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                LobiRec.presentLobiPostWithTitle(
                    "title",
                    postDescrition: "description",
                    postScore     : Int64(self.currentPipe),
                    postCategory  : "category",
                    prepareHandler: nil,
                    afterHandler  : nil
                )
            })
        }
        
        // let delay = 10.5 * Double(NSEC_PER_SEC)
        // let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        // dispatch_after(time, dispatch_get_main_queue(), {
        //     for gesture in self.view.gestureRecognizers {
        //         self.view.removeGestureRecognizer(gesture as UIGestureRecognizer)
        //     }
        //     self.stopBGM()
        //     self.view.scene = OpeningScene(view: self.view)
        // });
    }
    
    func checkGameover() -> Bool {
        return (playerBird.presentationNode().position.y < 0 ||
                playerBird.presentationNode().position.y > 4)
    }

    /**
     *  Update the scene.
     */
    func update() {
        
        if self.gameover {
            return
        }
        
        if self.checkGameover() {
            self.doGameover()
            return
        }
        
        var pos = self.playerBird.presentationNode().position
        self.playerBird.physicsBody.applyForce(SCNVector3(x: 0, y: 0, z: self.speed), impulse: false)
        self.currentPos = pos.z
        pos.x += self.cameraPos.x
        pos.y  = self.cameraPos.y
        pos.z += self.cameraPos.z
        self.cameraNode.position = pos
        
        let now = Int(-self.currentPos / self.limitInterval)
        // println("currentPos: \(currentPos)")
        // println("now: \(now)")
        // println(currentPipe)
        if now > self.currentPipe {
            self.currentPipe = now
            println("-------- need to swap walls. currentPipe is \(self.currentPipe) --------")
            self.swapWall()
        }
    }
    
    /**
     *  Handle tap gesture.
     *
     *  @param {UIGestureRecognizer} gestureRecognize
     */
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        
        if self.gameover {
            return
        }
        
        let power: Float = 1.8
        self.playerBird.physicsBody.applyForce(SCNVector3(x: 0, y: power, z: 0), impulse: true)
        self.playBoundSound()
    }
    
    /**
    *  Set up to handel tap
    */
    func setupHandleTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        gestureRecognizers.addObjectsFromArray(self.view.gestureRecognizers)
        self.view.gestureRecognizers = gestureRecognizers
    }
    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - SCNPhysicsContactDelegate
    func physicsWorld(world: SCNPhysicsWorld!, didBeginContact contact: SCNPhysicsContact!) {
        self.doGameover()
    }
    
    
    ////////////////////////////////////////////////////////////////
    // MARK: - SCNSceneRendererDelegate
    func renderer(aRenderer: SCNSceneRenderer!, updateAtTime time: NSTimeInterval) {
        self.update();
    }
    
    func renderer(aRenderer: SCNSceneRenderer!, willRenderScene scene: SCNScene!, atTime time: NSTimeInterval) {
        if (self.frameBuffer == 0) {
            println("---------------- set up framebuffer ---------------------")
            glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &self.frameBuffer)
            LobiRec.createFramebuffer(GLuint(self.frameBuffer))
            LobiRec.startCapturing()
        }
        LobiRec.prepareFrame()
    }
    
    func renderer(aRenderer: SCNSceneRenderer!, didRenderScene scene: SCNScene!, atTime time: NSTimeInterval) {
        LobiRec.appendFrame(GLuint(self.frameBuffer))
    }
    
}