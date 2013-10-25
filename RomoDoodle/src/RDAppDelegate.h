//
//  RDAppDelegate.h
//  RomoDoodle
//
//  Created by Dominick Lim on 7/13/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RMCoreRobot;

@interface RDAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong, readonly) RMCoreRobot *robot;

@end
