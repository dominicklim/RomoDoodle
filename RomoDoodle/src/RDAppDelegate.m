//
//  RDAppDelegate.m
//  RomoDoodle
//
//  Created by Dominick Lim on 7/13/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import "RDAppDelegate.h"
#import "RDDrawVC.h"
#import <RMCore/RMCore.h>

@interface RDAppDelegate()<RMCoreDelegate>

@property (nonatomic, strong) RDDrawVC *drawVC;
@property (nonatomic, strong, readwrite) RMCoreRobot *robot;

@end

@implementation RDAppDelegate

#pragma mark -- Object Lifecycle

- (id)init
{
    if (self = [super init]) {

    }
    
    return self;
}

#pragma mark -- Private Properties

- (RDDrawVC *)drawVC
{
    if (!_drawVC) {
        _drawVC = [[RDDrawVC alloc] init];
    }
    
    return _drawVC;
}

#pragma mark -- UIApplicationDelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.drawVC];
    [navigationController setNavigationBarHidden:YES animated:NO];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    [RMCore setDelegate:self];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:NO];
}

#pragma mark -- RMCoreDelegate Methods

- (void)robotDidConnect:(RMCoreRobot *)robot
{
    if ([robot isDrivable]) {
        self.robot = robot;
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot
{
    if (robot == self.robot) {
        self.robot = nil;
    }
}

@end