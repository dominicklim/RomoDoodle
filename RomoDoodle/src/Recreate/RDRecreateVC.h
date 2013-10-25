//
//  RDRecreateVC.h
//  RomoDoodle
//  A UIViewController that controls the view that drawings are recreated on.
//  Is initialized with a move queue of the moves that need to be carried out to
//  recreate the drawing, both on the screen and with Romo.
//
//  Created by Dominick Lim on 8/9/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDMovement.h"

@interface RDRecreateVC : UIViewController <RDMovementDelegate>

- (id)initWithMoveQueue:(NSArray *)moveQueue;

@end
