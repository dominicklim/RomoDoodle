//
//  RDRecreateView.m
//  RomoDoodle
//  A UIView that drawings are recreated on.
//
//  Created by Dominick Lim on 7/13/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import "RDRecreateView.h"
#import "RDStroke.h"

@interface RDRecreateView()

@property (nonatomic, retain) UIBezierPath *drawPath;

- (void)clearScreen;

@end

@implementation RDRecreateView

#pragma mark -- Init

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.stopButton];
        [self addSubview:self.easterEggButton];
    }
    return self;
}

- (void)layoutSubviews
{
    CGSize size = self.frame.size;
    
    self.stopButton.frame = (CGRect){0, 0, size.height * 0.2, size.height * 0.2};
    self.stopButton.center = (CGPoint){size.width * 0.5, size.height * 0.9};
    
    self.easterEggButton.frame = (CGRect){0, 0, size.width * 0.5, size.height * 0.5};
    self.easterEggButton.center = (CGPoint){size.width * 0.5, size.height * 0.5};
}

#pragma mark -- Drawing methods

/**
 *  Sets up brush stroke attributes.
 */
- (void)drawRect:(CGRect)rect
{
    [ROMO_BLUE setStroke];
    [self.drawPath stroke];
}

/**
 *  Clears the screen.
 */
- (void)clearScreen
{
    [self.drawPath removeAllPoints];
    [self setNeedsDisplay];
}

#pragma mark -- Public Properties

- (UIButton *)stopButton
{
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopButton setImage:[UIImage imageNamed:@"RDUI_square"] forState:UIControlStateNormal];
    }
    
    return _stopButton;
}

- (UIButton *)easterEggButton
{
    if (!_easterEggButton) {
        _easterEggButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    
    return _easterEggButton;
}

#pragma mark -- Private Properties

- (UIBezierPath *)drawPath
{
    if(!_drawPath) {
        _drawPath = [[UIBezierPath alloc] init];
        _drawPath.lineCapStyle = kCGLineCapRound;
        _drawPath.miterLimit = 0;
        _drawPath.lineWidth = LINE_WIDTH;
    }
    
    return _drawPath;
}

#pragma mark -- Public Methods
/**
 *  Clears the screen and moves to the first point in the
 *  recreation of the drawing.
 */
- (void)moveToPoint:(CGPoint)point
{
    [self clearScreen];
    [self.drawPath moveToPoint:point];
}

/**
 *  Adds a line from the last point added to the draw path and the given point.
 */
- (void)addLineToPoint:(CGPoint)point
{
    [self.drawPath addLineToPoint:point];
    [self setNeedsDisplay];
}

/**
 *  Displays a UIAlertView with an easter egg.
 */
- (void)showEasterEgg
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"RomoDoodle"
                                                      message:@"Developed by Dominick Lim\nat Romotive in Las Vegas\nJuly 2012"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles: nil];
    [message show];
}

@end
