//
//  RDDrawView.h
//  RomoDoodle
//  A UIView that users draw on.
//
//  Created by Dominick Lim on 7/13/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RDDrawViewDelegate;

@interface RDDrawView : UIView

@property (nonatomic, weak) id <RDDrawViewDelegate> delegate;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, retain) UIButton *playButton;

- (void)animateIndicator;
- (void)stopIndicator;
- (void)showNeedDrawing;
- (void)showNeedRobot;

@end

@protocol RDDrawViewDelegate <NSObject>
- (void)drawView:(RDDrawView *)drawView didFinishDrawingBezierPath:(UIBezierPath *)path;
@end
