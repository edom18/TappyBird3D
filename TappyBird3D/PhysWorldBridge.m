
#import "PhysWorldBridge.h"

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

@end
