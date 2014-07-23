//
//  RIPOperationButton.h
//  Math Counts
//
//  Created by Nick Stanley on 7/21/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPCircleView.h"

@interface RIPOperationButton : UIView

- (instancetype)initWithFrame:(CGRect)frame circleColor:(UIColor *)circleColor imageName:(NSString *)name;
- (void)deselectButton;

@property (strong, nonatomic) NSString *operationName;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) RIPCircleView *bgCircle;

@end
