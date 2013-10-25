//
//  RDDrawVC.m
//  RomoDoodle
//  A UIViewController that controls the view that users draw on. Takes the
//  users' drawings, performs calculations, then passes a move queue through the
//  RDDrawView delegacy.
//
//  Created by Dominick Lim on 7/13/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import "RDDrawVC.h"
#import "RDDrawView.h"

#import "RDRecreateVC.h"

#import "RDAppDelegate.h"

#define CM_PER_SEC      60
#define DEGREES(rad)    (rad)*(180.0/M_PI)

@interface RDDrawVC() <RDDrawViewDelegate>

@property (nonatomic, retain) RDDrawView *view;

@property (nonatomic, retain) NSMutableArray *bezierPointArray;
@property (nonatomic, retain) NSMutableArray *moveQueue;

@property (nonatomic) float drawingHeight;
@property (nonatomic) float secsPerDegLeft;
@property (nonatomic) float secsPerDegRight;

- (float)degreesFromDx:(float)dx andDy:(float)dy;
- (float)differenceBetweenFirstAngle:(float)first andSecondAngle:(float)second;

- (NSArray *)moveQueueWithPointArray:(NSArray *)pointArray;

- (void)recreateDrawing;

@end

@implementation RDDrawVC

#pragma mark -- Object lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -- View lifecycle

- (void)loadView
{   
    self.view = [[RDDrawView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view.playButton addTarget:self
                             action:@selector(recreateDrawing)
                   forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- Private Properties

- (NSMutableArray *)bezierPointArray
{
    if (!_bezierPointArray) {
        _bezierPointArray = [[NSMutableArray alloc] init];
    }
    
    return _bezierPointArray;
}

- (NSMutableArray *)moveQueue
{
    if (!_moveQueue) {
        _moveQueue = [[NSMutableArray alloc] init];
    }
    
    return _moveQueue;
}

#pragma mark -- Creation of arrays for recreation
/**
 *  If there is more than one point in the point array received, perform 
 *  calculations and send the produced move queue along with the simplified
 *  point array to the app delegate to recreate the drawing. If the point
 *  array has one or less points, tell the user that they need to draw first.
 */
- (void)recreateDrawing
{
    [self.view animateIndicator];
    
    if (!((RDAppDelegate *)[UIApplication sharedApplication].delegate).robot) {
        [self.view showNeedRobot];
    } else if ([self.bezierPointArray count] <= 1) {
        [self.view showNeedDrawing];
    } else {
        [self heightOfDrawingWithPointArray:self.bezierPointArray];
        [self moveQueueWithPointArray:self.bezierPointArray];
        
        [self.navigationController pushViewController:[[RDRecreateVC alloc] initWithMoveQueue:self.moveQueue] animated:YES];
    }

    [self.view stopIndicator];
}

/**
 *  Makes an array of degrees to turn (negative degrees correspond to left 
 *  turns, positive degrees correspond to right turns) and an array of
 *  seconds to move forward.
 */
- (NSArray *)moveQueueWithPointArray:(NSArray *)pointArray
{
    self.moveQueue = nil;
    
    float diff;
    float dist;
    float lastDeg;
    NSDictionary *move;
    
    NSValue *p = pointArray[0];
    CGPoint point = p.CGPointValue;
    CGPoint prevPoint = point;
    
    for (int i = 1; i < [pointArray count]; ++i) {
        p = pointArray[i];
        point = p.CGPointValue;
        
        float dx = point.x - prevPoint.x;
        float dy = point.y - prevPoint.y;
        
        dist = sqrtf((dx * dx) + (dy * dy));
        
        // If the distance of the segment is of significant length (greater than
        // 1/10 the drawing height) or it is the last segment,
        if (dist > self.drawingHeight * 0.1 || i == [pointArray count] - 1) {
            float degs = [self degreesFromDx:dx andDy:dy];
            // If this is the first angle (lastDeg has not been set yet), set
            // diff to degs
            // Else, the diff is the difference between degs and lastDegs
            diff = @(lastDeg) ? [self differenceBetweenFirstAngle:degs andSecondAngle:lastDeg] : degs;
            
            // fwdSec equals the time it takes to go the given distance scaled
            // such that the entire drawing is no bigger than 30 cm
            float fwdSec = ((dist / self.drawingHeight) * 30) / CM_PER_SEC;
            
            // If no forward moves have been added, don't add a turn move;
            // instead, set lastDegs to degs
            // Else, add a turn move
            if ([self.moveQueue count] == 0) {
                lastDeg = degs;
            } else {
                // If diff is negligible (10 degrees or less), ignore it (set it
                // to 0.0)
                if (fabsf(diff) <= 10) {
                    diff = 0.0;
                } else {
                    lastDeg = degs;
                }
                
                move = @{@"mode": @1, @"degrees": @(diff)};
                [self.moveQueue addObject:move];
            }
            
            move = @{@"mode": @0, @"time": @(fwdSec), @"point": [NSValue valueWithCGPoint:point]};
            
            [self.moveQueue addObject:move];
            
            prevPoint = point;
        }
    }
    
    return self.moveQueue;
}

- (float)heightOfDrawingWithPointArray:(NSArray *)pointArr
{
    float smallestX = self.view.frame.size.width;
    float largestX = 0;
    float smallestY = self.view.frame.size.height;
    float largestY = 0;
    
    for (NSValue *value in pointArr) {
        CGPoint point = value.CGPointValue;
        
        float x = point.x;
        float y = point.y;
        
        if (x < smallestX) {
            smallestX = x;
        } else if (x > largestX) {
            largestX = x;
        }
        
        if (y < smallestY) {
            smallestY = y;
        } else if (y >largestY) {
            largestY = y;
        }
    }
    
    float width = largestX - smallestX;
    
    self.drawingHeight = largestY - smallestY;
    
    if (width > self.drawingHeight) {
        self.drawingHeight = width;
    }
    
    return self.drawingHeight;
}

/**
 *  Returns the angle (in degrees) that Romo should make with 0 degrees in 
 *  order to get from his previous position to this current position.
 */
- (float)degreesFromDx:(float)dx andDy:(float)dy
{
    float degs = DEGREES(atanf(dy/dx));
    if (dx < 0)
        degs += 180;
    else if (dy < 0)
        degs += 360;
    return degs;
}

/** 
 *  Returns the angle (in degrees) that Romo must turn in order to achieve
 *  the desired angle.
 */
- (float)differenceBetweenFirstAngle:(float)first andSecondAngle:(float)second
{
    float diff = first - second;
    if (diff > 180)
        diff -= 360;
    else if (diff < -180)
        diff += 360;
    return diff;
}

#pragma mark -- RDDrawViewDelegate Methods

- (void)drawView:(RDDrawView *)drawView didFinishDrawingBezierPath:(UIBezierPath *)path
{
    self.bezierPointArray = nil;
    
    CGPathRef yourCGPath = path.CGPath;
    CGPathApply(yourCGPath, (__bridge void *)(self.bezierPointArray), MyCGPathApplierFunc);
}

/**
 *  Returns the angle (in degrees) that Romo must turn in order to achieve
 *  the desired angle.
 */
void MyCGPathApplierFunc (void *info, const CGPathElement *element) {
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    
    CGPoint *points = element->points;
    CGPathElementType type = element->type;
    
    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
            
        case kCGPathElementAddLineToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;
            
        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            break;
            
        case kCGPathElementAddCurveToPoint: // contains 3 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[2]]];
            break;
            
        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}


@end
