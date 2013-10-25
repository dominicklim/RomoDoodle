//
//  RDRecreateView.h
//  RomoDoodle
//  A UIView that drawings are recreated on.
//
//  Created by Dominick Lim on 7/13/12.
//  Copyright (c) 2012 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RDRecreateView : UIView

@property (nonatomic, retain) UIButton *stopButton;
@property (nonatomic, retain) UIButton *easterEggButton;

- (void)moveToPoint:(CGPoint)point;
- (void)addLineToPoint:(CGPoint)point;

- (void)showEasterEgg;

@end
