@import Foundation;
@import SceneKit;

@interface PhysWorldBridge : NSObject<SCNPhysicsContactDelegate>

- (void)physicsWorldSpeed:(SCNScene *)scene withSpeed:(float)speed;
- (void)physicsGravity:(SCNScene *)scene withGravity:(SCNVector3)gravity;
- (void)physicsDelegate:(SCNScene *)scene;
- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact;
- (void)physicsWorld:(SCNPhysicsWorld *)world didUpdateContact:(SCNPhysicsContact *)contact;
- (void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact;

@end

