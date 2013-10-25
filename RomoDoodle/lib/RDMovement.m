//
//  RDMovement.m
//  RomoDoodle
//
//  Created by Dominick Lim on 4/20/13.
//
//

#import "RDMovement.h"
#import "RDAppDelegate.h"
#import <RMCore/RMCore.h>

#define SIGN(n) n / ABS(n)

@interface RDMovement()

@property (nonatomic, strong) RMCoreRobot<DifferentialDriveProtocol> *robot;
@property (nonatomic) BOOL isRunning;
@property (nonatomic) dispatch_queue_t movementDispatchQueue;

- (void)executeMoveAtStepNumber:(int)stepNumber;
- (void)executeMove:(NSDictionary *)move completion:(void(^)(BOOL finished))completion;

- (void)driveForwardForSeconds:(float)seconds completion:(void (^)(BOOL finished))completion;
- (void)rotateByAngle:(float)angle completion:(void (^)(BOOL finished))completion;

@end

@implementation RDMovement

- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark -- Private Properties

- (dispatch_queue_t)movementDispatchQueue
{
    if (!_movementDispatchQueue) {
        _movementDispatchQueue = dispatch_queue_create("com.romotive.movement", DISPATCH_QUEUE_SERIAL);
    }
    
    return _movementDispatchQueue;
}

- (RMCoreRobot<DifferentialDriveProtocol> *)robot
{
    return (RMCoreRobot<DifferentialDriveProtocol> *)((RDAppDelegate *)[UIApplication sharedApplication].delegate).robot;
}

#pragma mark -- Public Methods

- (void)startMoveQueue
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate movement:self didBeginMoveQueue:self.moveQueue];
    });
    
    self.isRunning = YES;
    
    dispatch_async(self.movementDispatchQueue, ^{
        [self executeMoveAtStepNumber:0];
    });
}

- (void)stopMoveQueue
{
    self.isRunning = NO;
    [self.robot stopAllMotion];
}

- (void)executeMoveAtStepNumber:(int)stepNumber
{
    NSDictionary *move = self.moveQueue[stepNumber];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate movement:self didBeginMove:move];
    });

    // Do the move
    [self executeMove:self.moveQueue[stepNumber] completion:^(BOOL finished) {
        // Received a command to stop
        if (!finished) {
            [self.robot stopAllMotion];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate movement:self didInterruptMove:move];
            });

            return;
        }

        // Delegate methods for finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate movement:self didFinishMove:move];
        });
        
        // If it's the last move, finished
        if (stepNumber == self.moveQueue.count - 1) {
            [self.robot stopAllMotion];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate movement:self didFinishMoveQueue:self.moveQueue];
            });
            return;
        }
        
        // Do the next move
        [self executeMoveAtStepNumber:stepNumber + 1];
    }];
}

- (void)executeMove:(NSDictionary *)move completion:(void (^)(BOOL))completion
{
    // If commanded to stop, don't do anything
    if (!self.isRunning) {
        completion(NO);
        return;
    }

    // Do the move
    switch ([move[@"mode"] intValue]) {
        case 0: // Forward mode
            [self driveForwardForSeconds:[move[@"time"] floatValue] completion:completion];
            break;
        case 1: // Turn mode
            [self rotateByAngle:[move[@"degrees"] floatValue] completion:completion];
            break;
        default: // Mode is not recognized
            completion(YES);
            break;
    }
}

- (void)driveForwardForSeconds:(float)seconds completion:(void (^)(BOOL))completion
{
    if (self.robot) {
        [self.robot driveForwardWithSpeed:0.5];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            completion(YES);
        });
    } else {
        completion(NO);
    }
}

- (void)rotateByAngle:(float)angle completion:(void (^)(BOOL))completion
{
    if (self.robot) {
        if (angle != 0) {
            [self.robot turnByAngle:-angle
                         withRadius:RM_DRIVE_RADIUS_TURN_IN_PLACE
                    finishingAction:RMCoreTurnFinishingActionDriveForward
                         completion:^(BOOL success, float heading) {
                             completion(YES);
                         }];
        } else {
            completion(YES);
        }
    } else {
        completion(NO);
    }
}

@end
