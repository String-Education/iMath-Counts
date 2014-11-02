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
#import "RIPHomePageViewController.h"

@interface RIPMainMenuViewController ()
<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *addRect;
@property (weak, nonatomic) IBOutlet UIView *subtractRect;
@property (weak, nonatomic) IBOutlet UIView *multiplyRect;
@property (weak, nonatomic) IBOutlet UIView *divideRect;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

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
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:SUBTRACTION])
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.7 alpha:1.0];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    if ([sharedManager.operation isEqualToString:ADDITION]) {
        [self.addButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1.0];
    } else if ([sharedManager.operation isEqualToString:SUBTRACTION]) {
        [self.subtractButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.7 alpha:1.0];
    } else if ([sharedManager.operation isEqualToString:MULTIPLICATION]) {
        [self.multiplyButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    } else if ([sharedManager.operation isEqualToString:DIVISION]) {
        [self.divideButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.instructionLabel.text = @"Tap a Symbol";
        [self.addButton.button setSelected:NO];
        [self.subtractButton.button setSelected:NO];
        [self.multiplyButton.button setSelected:NO];
        [self.divideButton.button setSelected:NO];

    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.addButton setFrame:self.addRect.frame];
    [self.subtractButton setFrame:self.subtractRect.frame];
    [self.multiplyButton setFrame:self.multiplyRect.frame];
    [self.divideButton setFrame:self.divideRect.frame];
    
    [self.view layoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
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
    
    if ([sharedManager.operation isEqualToString:ADDITION]) {
        [self.addButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1.0];
    } else if ([sharedManager.operation isEqualToString:SUBTRACTION]) {
        [self.subtractButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.7 alpha:1.0];
    } else if ([sharedManager.operation isEqualToString:MULTIPLICATION]) {
        [self.multiplyButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    } else if ([sharedManager.operation isEqualToString:DIVISION]) {
        [self.divideButton.button setSelected:YES];
        self.navigationController.navigationBar.barTintColor = [UIColor purpleColor];
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        self.instructionLabel.font = [UIFont systemFontOfSize:32];
    self.instructionLabel.text = @"Tap a symbol";
    
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
