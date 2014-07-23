//
//  RIPCircleView.m
//  Math Counts
//
//  Created by Nick Stanley on 7/21/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPCircleView.h"

@interface RIPCircleView ()

@property (nonatomic) CGFloat resizeRatio;
@property (nonatomic) CAShapeLayer *pathLayer;

@end

@implementation RIPCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Configures pathLayer to create a circle
        self.backgroundColor = [UIColor clearColor];
        
        self.circleColor = [UIColor grayColor];
        if (self.pathLayer == nil) {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];

            shapeLayer.path = [[self circlePath] CGPath];
            shapeLayer.frame = self.bounds;
            shapeLayer.bounds = self.bounds;
            shapeLayer.fillColor = [self.circleColor CGColor];
            shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
            
            [self.layer addSublayer:shapeLayer];
            self.pathLayer = shapeLayer;

        }
    }
    return self;
}

- (UIBezierPath *)circlePath
{
    CGRect bounds;
    CGPoint center;
    double maxRadius;
    double radius = 0.01;
    UIBezierPath *circlePath;
    
    bounds = self.bounds;
    
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;
    
    maxRadius = MIN(bounds.size.width / 2.0, bounds.size.height / 2.0);
    self.resizeRatio = maxRadius / radius;
    
    circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                radius:radius
                                            startAngle:0.0
                                              endAngle:2.0 * M_PI
                                             clockwise:YES];
    [circlePath fill];
    return circlePath;
}

- (void)animateCircle
{
    //Animates the circle to expand/contract
    self.pathLayer.fillColor = [self.circleColor CGColor];
    [self.pathLayer setNeedsDisplay];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.25;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(self.resizeRatio, self.resizeRatio, 1.0)];
    [self.pathLayer addAnimation:anim forKey:nil];
}

@end
