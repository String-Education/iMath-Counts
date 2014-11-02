//
//  RIPCircleView.h
//  Math Counts
//
//  Created by Nick Stanley on 7/21/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPCircleView : UIView

- (void)animateCircleExpand;
- (void)animateCircleContract;

@property (strong, nonatomic) UIColor *circleColor;

@end
