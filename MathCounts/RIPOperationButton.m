//
//  RIPOperationButton.m
//  Math Counts
//
//  Created by Nick Stanley on 7/21/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPOperationButton.h"
#import "RIPDataManager.h"

@interface RIPOperationButton ()

@property (strong, nonatomic) UIColor *grayColor;
@property (strong, nonatomic) UIColor *operationColor;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *imageHighlight;

@end

@implementation RIPOperationButton

- (instancetype)initWithFrame:(CGRect)frame circleColor:(UIColor *)circleColor imageName:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        //Configures properties according to passed in arguments
        self.backgroundColor = [UIColor clearColor];
        self.grayColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.22];
        if (circleColor)
            self.operationColor = circleColor;
        else
            self.operationColor = self.grayColor;
        self.operationName = name;
        self.image = [UIImage imageNamed:name];
        self.imageHighlight = [UIImage imageNamed:[NSString stringWithFormat:@"%@Selected", name]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame circleColor:nil imageName:nil];
    return self;
}

- (void)enableButton:(id)sender
{
    [self.button setEnabled:YES];
}

- (void)changeButton:(id)sender
{
    //Configures button properties based on if it's selected or not
    if ([self.button isSelected]) {
        [self.button setImage:self.image forState:UIControlStateHighlighted]; //come back to this later
        self.bgCircle.circleColor = self.grayColor;
        [self.button setSelected:NO];
        [RIPDataManager sharedManager].operation = nil;
        NSNotification *buttonDisabled = [NSNotification notificationWithName:@"buttonDisabled" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:buttonDisabled];
    } else {
        [self.button setImage:self.imageHighlight forState:UIControlStateHighlighted];
        self.bgCircle.circleColor = self.operationColor;
        [self.button setSelected:YES];
        [RIPDataManager sharedManager].operation = self.operationName;
        NSNotification *buttonEnabled = [NSNotification notificationWithName:@"buttonEnabled" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:buttonEnabled];
    }
    [self.button setEnabled:NO];
    [self performSelector:@selector(enableButton:) withObject:nil afterDelay:0.25];
    [self.bgCircle animateCircle];
}

- (void)deselectButton
{
    //Deselects button if it is currently selected, and disables it while the selected button animates
    if ([self.button isSelected]) {
        [self.button setImage:self.image forState:UIControlStateHighlighted];
        self.bgCircle.circleColor = self.grayColor;
        [self.button setSelected:NO];
    }
    [self.button setImage:self.image forState:UIControlStateDisabled];
    [self.button setEnabled:NO];
    [self performSelector:@selector(enableButton:) withObject:nil afterDelay:0.25];
}


- (void)drawRect:(CGRect)rect
{
    //Adds animated circle to view
    self.bgCircle = [[RIPCircleView alloc] initWithFrame:self.bounds];
    [self addSubview:self.bgCircle];
    
    //Configures and and adds button to view
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setImage:self.image forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(changeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.button setImage:self.imageHighlight forState:UIControlStateSelected];
    self.button.frame = self.bounds;
    [self addSubview:self.button];
}
    
@end
