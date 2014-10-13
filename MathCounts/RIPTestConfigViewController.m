//
//  RIPSettingsViewController.m
//  MathCounts
//
//  Created by Nick Stanley on 6/20/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPTestConfigViewController.h"
#import "RIPDataManager.h"
#import "RIPTimeTestViewController.h"

@interface RIPTestConfigViewController ()
<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIPickerView *settingsPicker;
@property (nonatomic) NSInteger numQuestions;
@property (nonatomic) NSInteger difficulty;
@property (nonatomic) NSInteger time;
@property (copy, nonatomic) NSArray *numbers;
@property (copy, nonatomic) NSArray *difficulties;
@property (copy, nonatomic) NSArray *times;

@end

#pragma mark

@implementation RIPTestConfigViewController

#pragma mark Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.startItem = [[UIBarButtonItem alloc] initWithTitle:@"Start"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(startQuiz:)];
    }
    return self;
}

#pragma mark UITextField methods

#define ALPHA_NUMERIC @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890"

- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)characters
{

    NSCharacterSet *charactersToBlock = [[NSCharacterSet characterSetWithCharactersInString:ALPHA_NUMERIC] invertedSet];
    return ([characters rangeOfCharacterFromSet:charactersToBlock].location == NSNotFound);
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark Callbacks

- (void)startQuiz:(id)sender
{
    NSArray *components;
    
    //Gets the position of each slider
    NSInteger timerIndex = [self.settingsPicker selectedRowInComponent:0];
    NSInteger difficultyIndex = [self.settingsPicker selectedRowInComponent:1];
    NSInteger questionsIndex = [self.settingsPicker selectedRowInComponent:2];
    
    //Finds the index of the slider position in each array
    NSString *difficulty = self.difficulties[difficultyIndex];
    NSString *questions = self.numbers[questionsIndex];
    NSString *time = self.times[timerIndex];
    
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    if (self.nameField.text)
        sharedManager.name = self.nameField.text;
    else
        sharedManager.name = nil;
    [self.nameField resignFirstResponder];
        
    
    //Parses number of questions to an int
    self.numQuestions = [questions intValue];
    
    //Parses difficulty string to an int
    if ([sharedManager.operation isEqualToString:ADDITION] || [sharedManager.operation isEqualToString:SUBTRACTION]) {
        if ([difficulty isEqualToString:@"Easy"])
            self.difficulty = 1;
        else if ([difficulty isEqualToString:@"Medium"])
            self.difficulty = 2;
        else if ([difficulty isEqualToString:@"Hard"])
            self.difficulty = 3;
        else if ([difficulty isEqualToString:@"Expert"])
            self.difficulty = 4;
    } else {
        if ([difficulty isEqualToString:@"All"])
            self.difficulty = 13;
        else
            self.difficulty = [difficulty integerValue];
    }
    
    //Parses the time string to an int
    components = [time componentsSeparatedByString:@":"];
    if ([components count] == 1) {
        self.time = 0;
    } else {
        NSInteger minutes = [components[0] integerValue];
        NSInteger seconds = [components[1] integerValue];
        NSInteger totalTime = (minutes * 60) + seconds;
        self.time = totalTime;
    }
    
    //Accesses the card manager and set its question count, difficulty, and operation
    [sharedManager changeSettings:self.numQuestions
                     difficulty:self.difficulty
                      operation:nil
                           time:self.time
                           name:self.nameField.text];
    
    //Generates cards; cards are put into the cardManager's cardStore
    [sharedManager generateCards];
    
    //Generates and pushes a timeTestViewController
    NSNotification *startTest = [NSNotification notificationWithName:@"startTest" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:startTest];
}

#pragma mark UIPickerView methods

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        return 72;
//    }
    return 32;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    switch (component) {
        case 0: return 21; break;
        case 1:
            if ([sharedManager.operation isEqualToString:ADDITION] || [sharedManager.operation isEqualToString:SUBTRACTION]) {
                return 4;
                break;
            } else {
                return 13;
                break;
            }
        case 2: return 20; break;
        default: return 0; break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    if (!sharedManager.operation)
        return nil;
    //Creates and configures a UILabel to display in the pickerView
    UILabel *tView = (UILabel *)view;
    
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont systemFontOfSize:20];
        tView.textAlignment = NSTextAlignmentCenter;
    }
    
    //Determines the title source of each component; sources are defined in viewWillAppear:animated
    switch (component) {
        case 0: tView.text = self.times[row]; break;
        case 1: tView.text = self.difficulties[row]; break;
        case 2: tView.text = self.numbers[row]; break;
        default: tView.text = nil; break;
    }
    return tView;
}

#pragma mark View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
    //Configures navigation bar to display the title the name
    //of the operation as well as a button to start the quiz
    self.nameField.delegate = self;
    [self.nameField setEnablesReturnKeyAutomatically:NO];
    [self.nameField setKeyboardAppearance: UIKeyboardAppearanceDefault];
    self.nameField.returnKeyType = UIReturnKeyDone;
    
    if ([sharedManager.operation isEqualToString:ADDITION]) {
        [self.backgroundLabel setBackgroundColor:[UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0]];
        [self.backgroundView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0]];
    } else if ([sharedManager.operation isEqualToString:SUBTRACTION]) {
        [self.backgroundLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.3 blue:0.5 alpha:1.0]];
        [self.backgroundView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.3 blue:0.5 alpha:1.0]];
    } else if ([sharedManager.operation isEqualToString:MULTIPLICATION]) {
        [self.backgroundLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0]];
        [self.backgroundView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0]];
    } else if ([sharedManager.operation isEqualToString:DIVISION]) {
        [self.backgroundLabel setBackgroundColor:[UIColor purpleColor]];
        [self.backgroundView setBackgroundColor:[UIColor purpleColor]];
    }
    
    if ([sharedManager.operation isEqualToString:MULTIPLICATION])
        self.difficultyLabel.text = @"Multiplier";
    else if ([sharedManager.operation isEqualToString:DIVISION])
        self.difficultyLabel.text = @"Divisor";
    else
        self.difficultyLabel.text = @"Difficulty";
    
    //Defines the contents of the UIPickerView
    _numbers = @[@"5", @"10", @"15", @"20", @"25", @"30", @"35", @"40", @"45", @"50", @"55", @"60", @"65", @"70", @"75", @"80", @"85", @"90", @"95", @"100"];
    if ([sharedManager.operation isEqualToString:ADDITION] || [sharedManager.operation isEqualToString:SUBTRACTION])
        _difficulties = @[@"Easy", @"Medium", @"Hard", @"Expert"];
    else
        _difficulties = @[@"All", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
    _times = @[@"Off", @"00:30", @"01:00", @"01:30", @"02:00", @"02:30", @"03:00", @"03:30", @"04:00", @"04:30", @"05:00", @"05:30", @"06:00", @"06:30", @"07:00", @"07:30", @"08:00", @"08:30", @"09:00", @"09:30", @"10:00"];
}

@end
