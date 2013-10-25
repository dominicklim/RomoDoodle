//
//  RDRecreateVC.m
//  RomoDoodle
//  A UIViewController that controls the view that drawings are recreated on.
//  Is initialized with a move queue of the moves that need to be carried out to
//  recreate the drawing, both on the screen and with Romo.
//
//  Created by Dominick Lim on 8/9/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import "RDRecreateVC.h"
#import "RDRecreateView.h"

@interface RDRecreateVC()

@property (nonatomic, retain) RDRecreateView *view;
@property (nonatomic, retain) RDMovement *movement;
@property (nonatomic, retain) NSArray *moveQueue;

- (void)goToDrawingBoard;

@end

@implementation RDRecreateVC

#pragma mark -- Object Lifecycle

- (id)initWithMoveQueue:(NSArray *)moveQueue
{
    if (self = [super init]) {
        _moveQueue = moveQueue;
    }
    
    return self;
}

- (void)dealloc
{
    self.movement.delegate = nil;
    self.movement = nil;
}

#pragma mark -- View Lifecycle

- (void)loadView
{
    self.view = [[RDRecreateView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view.stopButton addTarget:self action:@selector(goToDrawingBoard)
                   forControlEvents:UIControlEventTouchUpInside];
    
    [self.view.easterEggButton addTarget:self.view action:@selector(showEasterEgg)
                        forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.movement.moveQueue = self.moveQueue;
    [self.movement startMoveQueue];
}

#pragma mark -- Private Properties

- (RDMovement *)movement
{
    if (!_movement) {
        _movement = [[RDMovement alloc] init];
        _movement.delegate = self;
    }

    return _movement;
}

#pragma mark -- View Events

/**
 *  Interrupts the move queue, stops all motors, and returns to the
 *  drawing board.
 */
- (void)goToDrawingBoard
{
    [self.movement stopMoveQueue];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- RDMovementDelegate Methods

- (void)movement:(RDMovement *)movement didBeginMoveQueue:(NSArray *)moveQueue
{
    NSValue *pointValue = moveQueue[0][@"point"];
    
    if (pointValue) {
        [self.view moveToPoint:[pointValue CGPointValue]];
    }
}

- (void)movement:(RDMovement *)movement didFinishMoveQueue:(NSArray *)moveQueue
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)movement:(RDMovement *)movement didBeginMove:(NSDictionary *)move
{
}

- (void)movement:(RDMovement *)movement didFinishMove:(NSDictionary *)move
{
    NSValue *pointValue = move[@"point"];
    
    if (pointValue) {
        [self.view addLineToPoint:[pointValue CGPointValue]];
    }
}

- (void)movement:(RDMovement *)movement didInterruptMove:(NSDictionary *)move
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
