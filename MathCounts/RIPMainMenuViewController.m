//
//  RIPMainMenuViewController.m
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPMainMenuViewController.h"
#import "RIPDataManager.h"
#import "RIPTestConfigViewController.h"
#import "RIPHistoryViewController.h"
#import "RIPSettingsViewController.h"
#import "RIPSettingsManager.h"
#import "RIPOperationButton.h"

@interface RIPMainMenuViewController ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *addRect;
@property (weak, nonatomic) IBOutlet UIView *subtractRect;
@property (weak, nonatomic) IBOutlet UIView *multiplyRect;
@property (weak, nonatomic) IBOutlet UIView *divideRect;

@property (strong, nonatomic) RIPOperationButton *addButton;
@property (strong, nonatomic) RIPOperationButton *subtractButton;
@property (strong, nonatomic) RIPOperationButton *multiplyButton;
@property (strong, nonatomic) RIPOperationButton *divideButton;

@end

@implementation RIPMainMenuViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = @"Math Counts";
    }
    return self;
}

- (void)disableOtherButtons:(NSNotification *)note
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    RIPOperationButton *selectedOperation = (RIPOperationButton *)note.object;
    NSArray *buttons = [NSArray arrayWithObjects:self.addButton, self.subtractButton, self.multiplyButton, self.divideButton, nil];
    NSMutableArray *otherButtons = [[NSMutableArray alloc] init];
    
    //Places all the buttons except the selected one into an array and deselects them
    for (RIPOperationButton *b in buttons) {
        if (b != selectedOperation)
            [otherButtons addObject:b];
    }
    for (RIPOperationButton *b in otherButtons) {
        [b deselectButton];
    }
    //Adjusts the navigation bar color based on the selected operation
    if ([sharedManager.operation isEqualToString:ADDITION])
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:SUBTRACTION])
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.5 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:MULTIPLICATION])
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:DIVISION])
        self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];
    else
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
}

- (void)defaultNavBar:(NSNotification *)note
{
    self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Configures and displays buttons based on empty views in .xib
    UIColor *additionColor = [UIColor colorWithRed:0.86 green:0.0 blue:0.0 alpha:0.32];
    UIColor *subtractionColor = [UIColor colorWithRed:0.0 green:0.46 blue:0.68 alpha:0.32];
    UIColor *multiplicationColor = [UIColor colorWithRed:0.32 green:0.98 blue:0.0 alpha:0.32];
    UIColor *divisionColor = [UIColor colorWithRed:0.95 green:0.0 blue:0.93 alpha:0.32];
    self.addButton = [[RIPOperationButton alloc] initWithFrame:self.addRect.frame circleColor:additionColor imageName:ADDITION];
    self.subtractButton = [[RIPOperationButton alloc] initWithFrame:self.subtractRect.frame circleColor:subtractionColor imageName:SUBTRACTION];
    self.multiplyButton = [[RIPOperationButton alloc] initWithFrame:self.multiplyRect.frame circleColor:multiplicationColor imageName:MULTIPLICATION];
    self.divideButton = [[RIPOperationButton alloc] initWithFrame:self.divideRect.frame circleColor:divisionColor imageName:DIVISION];
    [self.view addSubview:self.addButton];
    [self.view addSubview:self.subtractButton];
    [self.view addSubview:self.multiplyButton];
    [self.view addSubview:self.divideButton];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkGrayColor]];
    
    //Notifications posted by OperationButtons when enabled/disabled
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableOtherButtons:)
                                                 name:@"buttonEnabled"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(defaultNavBar:)
                                                 name:@"buttonDisabled"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end