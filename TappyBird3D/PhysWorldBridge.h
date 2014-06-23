@import Foundation;
@import SceneKit;

@interface PhysWorldBridge : NSObject

- (void)physicsWorldSpeed:(SCNScene *)scene withSpeed:(float)speed;
- (void)physicsGravity:(SCNScene *)scene withGravity:(SCNVector3)gravity;

@end

