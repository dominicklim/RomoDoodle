//
//  RDDrawView.m
//  RomoDoodle
//  A UIView that users draw on.
//
//  Created by Dominick Lim on 7/13/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import "RDDrawView.h"
#import "RDStroke.h"

@interface RDDrawView()

@property (nonatomic, retain) UIBezierPath *drawPath;

@end

@implementation RDDrawView

/** 
 *  Sets the background color and the brush color.
 */
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.playButton];
        [self addSubview:self.activityView];
    }
    
    return self;
}

/**
 *  Sets up brush stroke attributes.
 */
- (void)drawRect:(CGRect)rect
{
    [ROMO_BLUE setStroke];
    [self.drawPath stroke];
}

- (void)layoutSubviews
{
    CGSize size = self.frame.size;
    
    self.playButton.frame = (CGRect) {0, 0, size.height * 0.2, size.height * 0.2};
    self.playButton.center = (CGPoint) {size.width * 0.5, size.height * 0.9};
    
    self.activityView.center = self.playButton.center;
}

#pragma mark -- Public Properties

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_playButton setImage:[UIImage imageNamed:@"RDUI_play"]
                     forState:UIControlStateNormal];
    }
    
    return _playButton;
}

- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.center = self.playButton.center;
    }
    
    return _activityView;
}

#pragma mark -- Private Properties

- (UIBezierPath *)drawPath
{
    if (!_drawPath) {
        _drawPath = [[UIBezierPath alloc] init];
        _drawPath.lineCapStyle = kCGLineCapRound;
        _drawPath.miterLimit = 0;
        _drawPath.lineWidth = LINE_WIDTH;
    }
    
    return _drawPath;
}

#pragma mark -- Public Methods

- (void)animateIndicator
{
    [self.activityView startAnimating];
    [self.playButton removeFromSuperview];
}

- (void)stopIndicator
{
    [self.activityView stopAnimating];
    [self addSubview:self.playButton];
}

/**
  *  Displays a UIAlertView to ask the user to draw something first.
  */
- (void)showNeedDrawing
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please draw something first."
                                                      message:@""
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

/**
 *  Displays a UIAlertView to ask the user to draw something first.
 */
- (void)showNeedRobot
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Please connect me to my base first."
                                                      message:@""
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

#pragma mark -- UIResponder Event Handlers

/** 
 *  Clears the screen and registers the point that the user is touching as the 
 *  first point of the draw path.
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.drawPath removeAllPoints];
    [self setNeedsDisplay];
    
    UITouch *touch = [touches allObjects][0];
    [self.drawPath moveToPoint:[touch locationInView:self]];
}

/** 
 *  Registers the point that the user is touching as the next point of the 
 *  drawing and adds a line to the point on the draw path.
 */
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches allObjects][0];
    [self.drawPath addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

/** 
 *  When the user picks up their finger from the screen, the array of points is 
 *  sent to this view's UIViewController through the delegate method.
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate drawView:self didFinishDrawingBezierPath:self.drawPath];
}

@end
