//
//  RIPNumberPadView.m
//  Math Counts
//
//  Created by Tynan Douglas on 7/27/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPNumberPadView.h"
#import "RIPDataManager.h"

@interface RIPNumberPadView ()
<UITextFieldDelegate>

@property (strong, nonatomic) UIButton *zero;
@property (strong, nonatomic) UIButton *one;
@property (strong, nonatomic) UIButton *two;
@property (strong, nonatomic) UIButton *three;
@property (strong, nonatomic) UIButton *four;
@property (strong, nonatomic) UIButton *five;
@property (strong, nonatomic) UIButton *six;
@property (strong, nonatomic) UIButton *seven;
@property (strong, nonatomic) UIButton *eight;
@property (strong, nonatomic) UIButton *nine;
@property (strong, nonatomic) UIButton *delete;

@end

@implementation RIPNumberPadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.target.delegate = self;
    }
    return self;
}

- (void)addNumber:(id)sender
{
    if (self.target.text.length < 3) {
        if (sender == self.one)
            [self.target insertText:@"1"];
        else if (sender == self.two)
            [self.target insertText:@"2"];
        else if (sender == self.three)
            [self.target insertText:@"3"];
        else if (sender == self.four)
            [self.target insertText:@"4"];
        else if (sender == self.five)
            [self.target insertText:@"5"];
        else if (sender == self.six)
            [self.target insertText:@"6"];
        else if (sender == self.seven)
            [self.target insertText:@"7"];
        else if (sender == self.eight)
            [self.target insertText:@"8"];
        else if (sender == self.nine)
            [self.target insertText:@"9"];
        else if (sender == self.zero)
            [self.target insertText:@"0"];
    }
}

- (void)clearTextField:(id)sender
{
    [self.target setText:@""];
}

- (void)doneEditing:(id)sender
{
    NSNotification *doneClicked = [NSNotification notificationWithName:@"doneClicked" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:doneClicked];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Caps text field length to 3 characters
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 3) ? NO : YES;
}

- (void)drawRect:(CGRect)rect
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    CGRect testBorder = CGRectMake(0, 0, rect.size.width, ((rect.size.height - 3.0) / 9.0));
    UIView *border = [[UIView alloc] initWithFrame:testBorder];
    if ([sharedManager.operation isEqualToString:ADDITION])
        border.backgroundColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:SUBTRACTION])
        border.backgroundColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.7 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:MULTIPLICATION])
        border.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:DIVISION])
        border.backgroundColor = [UIColor purpleColor];
    else
        border.backgroundColor = [UIColor darkGrayColor];
    [self addSubview:border];
    
    CGRect button = CGRectMake(0, 0, ((rect.size.width - 2.0) / 3.0), ((2.0 * (rect.size.height - 3.0)) / 9.0));
    CGRect columnTwo = CGRectMake((button.size.width + 1.0), 0, 0, 0);
    CGRect columnThree = CGRectMake((2.0 * (button.size.width + 1.0)), 0, 0, 0);
    CGRect rowTwo = CGRectMake(0, (button.size.height + 1.0 + testBorder.size.height), 0, 0);
    CGRect rowThree = CGRectMake(0, (2.0 * (button.size.height + 1.0) + testBorder.size.height), 0, 0);
    CGRect rowFour = CGRectMake(0, (3.0 * (button.size.height + 1.0) + testBorder.size.height), 0, 0);
    
    [[UIButton appearance] setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [[UIButton appearance] setBackgroundColor:[UIColor clearColor]];
    [[UIButton appearance] setBackgroundImage:[UIImage imageNamed:@"NumberNormal"] forState:UIControlStateNormal];
    [[UIButton appearance] setBackgroundImage:[UIImage imageNamed:@"NumberSelected"] forState:UIControlStateHighlighted];
    
    
    self.one = [UIButton buttonWithType:UIButtonTypeCustom];
    self.two = [UIButton buttonWithType:UIButtonTypeCustom];
    self.three = [UIButton buttonWithType:UIButtonTypeCustom];
    self.four = [UIButton buttonWithType:UIButtonTypeCustom];
    self.five = [UIButton buttonWithType:UIButtonTypeCustom];
    self.six = [UIButton buttonWithType:UIButtonTypeCustom];
    self.seven = [UIButton buttonWithType:UIButtonTypeCustom];
    self.eight = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nine = [UIButton buttonWithType:UIButtonTypeCustom];
    self.zero = [UIButton buttonWithType:UIButtonTypeCustom];
    self.delete = [UIButton buttonWithType:UIButtonTypeCustom];
    self.done = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        CGFloat fontSize = 32;
        [[self.one titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.two titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.three titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.four titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.five titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.six titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.seven titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.eight titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.nine titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.zero titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.delete titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
        [[self.done titleLabel] setFont:[UIFont systemFontOfSize:fontSize]];
    }

    [self.one setTitle:@"1" forState:UIControlStateNormal];
    [self.one setFrame:CGRectMake(rect.origin.x, rowThree.origin.y, button.size.width, button.size.height)];
    [self.one addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.one];
    
    
    [self.two setTitle:@"2" forState:UIControlStateNormal];
    [self.two setFrame:CGRectMake(columnTwo.origin.x, rowThree.origin.y, button.size.width, button.size.height)];
    [self.two addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.two];
    
    
    [self.three setTitle:@"3" forState:UIControlStateNormal];
    [self.three setFrame:CGRectMake(columnThree.origin.x, rowThree.origin.y, button.size.width, button.size.height)];
    [self.three addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.three];
    
    [self.four setTitle:@"4" forState:UIControlStateNormal];
    [self.four setFrame:CGRectMake(rect.origin.x, rowTwo.origin.y, button.size.width, button.size.height)];
    [self.four addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.four];
    
    [self.five setTitle:@"5" forState:UIControlStateNormal];
    [self.five setFrame:CGRectMake(columnTwo.origin.x, rowTwo.origin.y, button.size.width, button.size.height)];
    [self.five addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.five];
    
    [self.six setTitle:@"6" forState:UIControlStateNormal];
    [self.six setFrame:CGRectMake(columnThree.origin.x, rowTwo.origin.y, button.size.width, button.size.height)];
    [self.six addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.six];
    
    [self.seven setTitle:@"7" forState:UIControlStateNormal];
    [self.seven setFrame:CGRectMake(rect.origin.x, rect.origin.y + testBorder.size.height, button.size.width, button.size.height)];
    [self.seven addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.seven];
    
    
    [self.eight setTitle:@"8" forState:UIControlStateNormal];
    [self.eight setFrame:CGRectMake(columnTwo.origin.x, rect.origin.y + testBorder.size.height, button.size.width, button.size.height)];
    [self.eight addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.eight];
    
    [self.nine setTitle:@"9" forState:UIControlStateNormal];
    [self.nine setFrame:CGRectMake(columnThree.origin.x, rect.origin.y + testBorder.size.height, button.size.width, button.size.height)];
    [self.nine addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.nine];
    
    
    [self.zero setTitle:@"0" forState:UIControlStateNormal];
    [self.zero setFrame:CGRectMake(columnTwo.origin.x, rowFour.origin.y, button.size.width, button.size.height)];
    [self.zero addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.zero];
    
    [[UIButton appearance] setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Normal", sharedManager.operation]] forState:UIControlStateNormal];
    [[UIButton appearance] setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Normal", sharedManager.operation]] forState:UIControlStateDisabled];
    [[UIButton appearance] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.delete setTitle:@"Delete" forState:UIControlStateNormal];
    [self.delete setFrame:CGRectMake(rect.origin.x, rowFour.origin.y, button.size.width, button.size.height)];
    [self.delete addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.delete];
    
    [self.done setTitle:@"Done" forState:UIControlStateNormal];
    [self.done setFrame:CGRectMake(columnThree.origin.x, rowFour.origin.y, button.size.width, button.size.height)];
    [self.done addTarget:self action:@selector(doneEditing:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.done];
    
    [[UIButton appearance] setBackgroundImage:nil forState:UIControlStateNormal];
    [[UIButton appearance] setBackgroundImage:nil forState:UIControlStateHighlighted];
 
}

@end
