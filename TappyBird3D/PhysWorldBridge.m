
#import "PhysWorldBridge.h"

@interface PhysWorldBridge ()

//@property (nonatomic, copy) (^contactCallBack)();

@end

@implementation PhysWorldBridge

- (id)init
{
    if (self = [super init]) {
        //
    }
    return self;
}

- (void)physicsWorldSpeed:(SCNScene *)scene
                withSpeed:(float)speed
{
    scene.physicsWorld.speed = speed;
}

- (void)physicsGravity:(SCNScene *)scene
           withGravity:(SCNVector3)gravity
{
    scene.physicsWorld.gravity = gravity;
}

- (void)physicsDelegate:(SCNScene *)scene
{
    scene.physicsWorld.contactDelegate = self;
//    self.contactCallBack = completion;
}

- (void)physicsWorld:(SCNPhysicsWorld *)world
     didBeginContact:(SCNPhysicsContact *)contact
{
    NSLog(@"hoge");
}
- (void)physicsWorld:(SCNPhysicsWorld *)world
    didUpdateContact:(SCNPhysicsContact *)contact
{
    
}
- (void)physicsWorld:(SCNPhysicsWorld *)world
       didEndContact:(SCNPhysicsContact *)contact
{
    
}

@end
