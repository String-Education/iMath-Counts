//
//  RIPCardViewController.m
//  MathCounts
//
//  Created by Nick Stanley on 6/21/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPCardViewController.h"
#import "RIPDataManager.h"
#import "RIPCard.h"
#import "RIPTimeTestViewController.h"

@interface RIPCardViewController ()
<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *questionNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *operationLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerField;

@end

#pragma mark

@implementation RIPCardViewController

#pragma mark Initializers

- (instancetype)initWithCardIndex:(NSInteger)index
{
    self = [super init];
    if (self)
        self.cardIndex = index;
    return self;
}

#pragma mark Keyboard methods

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}*/

- (void)doneEditing:(NSNotification *)note
{
    //Configures card's inputAnswer and viewed state
    if (![self.answerField.text isEqual:@""]) {
        self.displayedCard.isAnswered = YES;
        self.displayedCard.inputAnswer = [self.answerField.text integerValue];
    } else {
        self.displayedCard.isAnswered = NO;
        self.displayedCard.inputAnswer = 0;
        self.answerField.text = @"";
    }
    if (self.displayedCard.inputAnswer == self.displayedCard.answer && ![self.answerField.text isEqual:@""]) {
        self.displayedCard.isCorrect = YES;
    } else {
        self.displayedCard.isCorrect = NO;
    }
    
    //Posts custom notification for callback in RIPTimeTestViewController
    NSNotification *doneEditing = [NSNotification notificationWithName:@"doneEditing" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:doneEditing];
}

#pragma mark View methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //Caps text field length to 3 characters
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 3) ? NO : YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Loads sharedManager to access its cardStore
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //Gets card at index
    self.displayedCard = sharedManager.cardStore[self.cardIndex];
    
    self.questionNumLabel.text = [NSString stringWithFormat:@"#%d", (self.cardIndex + 1)];
    
    //Configures subviews according to selected card
    //Reminder: don't use == when comparing strings
    self.firstNumLabel.text = [NSString stringWithFormat:@"%d", self.displayedCard.firstNum];
    self.secondNumLabel.text = [NSString stringWithFormat:@"%d", self.displayedCard.secondNum];
    if ([sharedManager.operation isEqualToString:ADDITION])
        self.operationLabel.text = @"+";
    else if ([sharedManager.operation isEqualToString:SUBTRACTION])
        self.operationLabel.text = @"-";
    else if ([sharedManager.operation isEqualToString:MULTIPLICATION])
        self.operationLabel.text = @"x";
    else if ([sharedManager.operation isEqualToString:DIVISION])
        self.operationLabel.text = @"÷";
    self.answerField.borderStyle = UITextBorderStyleRoundedRect;
    if (self.displayedCard.inputAnswer)
        self.answerField.text = [NSString stringWithFormat:@"%d", self.displayedCard.inputAnswer];
    self.displayedCard.isViewed = YES;
    
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];

    if ([sharedManager.operation isEqualToString:ADDITION])
        keyboardDoneButtonView.barTintColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:SUBTRACTION])
        keyboardDoneButtonView.barTintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.5 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:MULTIPLICATION])
        keyboardDoneButtonView.barTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:DIVISION])
        keyboardDoneButtonView.barTintColor = [UIColor purpleColor];
    else
        keyboardDoneButtonView.barTintColor = [UIColor darkGrayColor];
    
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *paddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:nil
                                                                                 action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(doneEditing:)];
    doneItem.tintColor = [UIColor darkTextColor];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:paddingItem, doneItem, paddingItem, nil]];
    self.answerField.inputAccessoryView = keyboardDoneButtonView;
    
    
    //Callback for when keyboard is dismissed
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(doneEditing:)
    //                                             name:UITextFieldTextDidEndEditingNotification
    //                                           object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
