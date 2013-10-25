//
//  RDMovement.h
//  RomoDoodle
//
//  Created by Dominick Lim on 4/20/13.
//
//

#import <Foundation/Foundation.h>

@protocol RDMovementDelegate;

@interface RDMovement : NSObject

@property (nonatomic, strong) NSArray *moveQueue;
@property (nonatomic, weak) id <RDMovementDelegate> delegate;

- (void)startMoveQueue;
- (void)stopMoveQueue;

@end

@protocol RDMovementDelegate <NSObject>

- (void)movement:(RDMovement *)movement didBeginMoveQueue:(NSArray *)moveQueue;
- (void)movement:(RDMovement *)movement didFinishMoveQueue:(NSArray *)moveQueue;

- (void)movement:(RDMovement *)movement didBeginMove:(NSDictionary *)move;
- (void)movement:(RDMovement *)movement didFinishMove:(NSDictionary *)move;
- (void)movement:(RDMovement *)movement didInterruptMove:(NSDictionary *)move;

@end
