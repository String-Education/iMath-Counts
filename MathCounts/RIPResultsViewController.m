//
//  RIPResultsViewController.m
//  MathCounts
//
//  Created by Nick Stanley on 6/30/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPResultsViewController.h"
#import "RIPDataManager.h"
#import "RIPCard.h"
#import "RIPCardCell.h"
#import <Dropbox/Dropbox.h>

@interface RIPResultsViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *questionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (weak, nonatomic) IBOutlet UILabel *difficultyTitle;
@property (weak, nonatomic) IBOutlet UITableView *cardTableView;
@property (nonatomic) BOOL isNewTest;

@end

#pragma mark

@implementation RIPResultsViewController

#pragma mark Initializers

- (instancetype)initWithNewTest:(BOOL)isNew
{
    self = [super init];
    if (self) {
        //New tests are those that have just been finished
        //Old tests are those contained within the cardManager's testStore
        if (isNew)
            _isNewTest = YES;
        else
            _isNewTest = NO;
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithNewTest:YES];
    return self;
}

#pragma mark Callbacks

- (void)returnToMainMenu:(id)sender
{
    [[RIPDataManager sharedManager] clearSettings];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resultsShown" object:self];
}

#pragma mark UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    if (self.isNewTest)
        return sharedManager.cardStore.count;
    else
        return self.selectedTest.cardStore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger questionNumber = 0;
    NSInteger firstNum = 0;
    NSInteger secondNum = 0;
    NSInteger inputAnswer = 0;
    NSString *operation;
    RIPCard *card;
    RIPCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RIPCardCell" forIndexPath:indexPath];
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    //Adjusts card source based on whether or not the test is new
    if (self.isNewTest)
        card = sharedManager.cardStore[indexPath.row];
    else
        card = self.selectedTest.cardStore[indexPath.row];
    
    //Displays question number
    questionNumber = indexPath.row + 1;
    cell.questionNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)questionNumber];
    
    //Displays the card's question
    firstNum = card.firstNum;
    secondNum = card.secondNum;
    inputAnswer = card.inputAnswer;
    if (self.isNewTest) {
        if ([sharedManager.operation isEqualToString:ADDITION])
            operation = @"+";
        else if ([sharedManager.operation isEqualToString:SUBTRACTION])
            operation = @"-";
        else if ([sharedManager.operation isEqualToString:MULTIPLICATION])
            operation = @"x";
        else if ([sharedManager.operation isEqualToString:DIVISION])
            operation = @"÷";
    } else {
        if ([self.selectedTest.operation isEqualToString:ADDITION])
            operation = @"+";
        else if ([self.selectedTest.operation isEqualToString:SUBTRACTION])
            operation = @"-";
        else if ([self.selectedTest.operation isEqualToString:MULTIPLICATION])
            operation = @"x";
        else if ([self.selectedTest.operation isEqualToString:DIVISION])
            operation = @"÷";
    }
    cell.questionDetailLabel.text = [NSString stringWithFormat:@"%ld %@ %ld =", (long)firstNum, operation, (long)secondNum];
    
    //Displays the input answer if one was entered
    if (inputAnswer)
        cell.questionAnswerLabel.text = [NSString stringWithFormat:@"%ld", (long)inputAnswer];
    else
        cell.questionAnswerLabel.text = [NSString stringWithFormat:@""];
    
    //Displays the correct answer if the entered one was incorrect
    if (!card.isCorrect) {
        cell.questionCorrectLabel.text = @"x";
        cell.questionCorrectLabel.textColor = [UIColor redColor];
        cell.correctAnswerLabel.text = [NSString stringWithFormat:@"(%ld)", (long)card.answer];
    } else {
        cell.questionCorrectLabel.text = @"✓";
        cell.questionCorrectLabel.textColor = [UIColor greenColor];
        cell.correctAnswerLabel.text = @"";
    }
    return cell;
}

#pragma mark View methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger totalQuestions;
    NSInteger correctQuestions;
    NSInteger minutes;
    NSInteger seconds;
    NSString *timeRemaining;
    NSString *totalTime;
    UINib *cardCellNib;
    UIBarButtonItem *homeItem;
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
    correctQuestions = 0;
    if (self.isNewTest) {
        
        //Displays the name of the test taker as the title
        self.navigationItem.title = [NSString stringWithFormat:@"%@", sharedManager.name];
        
        //Determines number of correct questions and total questions
        totalQuestions = sharedManager.cardStore.count;
        for (RIPCard *c in sharedManager.cardStore) {
            if (c.isCorrect)
                correctQuestions++;
        }
    
        //Displays the used and allotted times
        if (sharedManager.time != 0) {
            minutes = sharedManager.timeRemaining / 60;
            seconds = sharedManager.timeRemaining % 60;
            timeRemaining = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
            minutes = sharedManager.time / 60;
            seconds = sharedManager.time % 60;
            totalTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
            self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", timeRemaining, totalTime];
        } else {
            self.timeLabel.text = [NSString stringWithFormat:@"Off"];
        }
    
        //Displays the difficulty/divisor/multiplier
        if ([sharedManager.operation isEqualToString:ADDITION] || [sharedManager.operation isEqualToString:SUBTRACTION]) {
            self.difficultyTitle.text = @"Difficulty";
            switch (sharedManager.difficulty) {
                case 1: self.difficultyLabel.text = [NSString stringWithFormat:@"Easy"]; break;
                case 2: self.difficultyLabel.text = [NSString stringWithFormat:@"Medium"]; break;
                case 3: self.difficultyLabel.text = [NSString stringWithFormat:@"Hard"]; break;
                case 4: self.difficultyLabel.text = [NSString stringWithFormat:@"Expert"]; break;
                default: break;
            }
        } else {
            if ([sharedManager.operation isEqualToString:MULTIPLICATION])
                self.difficultyTitle.text = @"Multiplier";
            else
                self.difficultyTitle.text = @"Divisor";
            if (sharedManager.difficulty == 13)
                self.difficultyLabel.text = [NSString stringWithFormat:@"All"];
            else
                self.difficultyLabel.text = [NSString stringWithFormat:@"%ld", (long)sharedManager.difficulty];
        }
        
        //If the test is new, sets custom home button and adds the test to the testStore
        homeItem = [[UIBarButtonItem alloc] initWithTitle:@"Home"
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:@selector(returnToMainMenu:)];
        self.navigationItem.leftBarButtonItem = homeItem;
        RIPTest *test = [RIPTest generateTest];
        [[RIPDataManager sharedManager] addTest:test];
        [[RIPDataManager sharedManager] saveTest];
    } else {
        //Performs the same operations as those in the if statement, but uses the test instance's variables instead
        //and doesn't generate a new test
        self.navigationItem.title = [NSString stringWithFormat:@"%@", self.selectedTest.name];
        
        totalQuestions = self.selectedTest.cardStore.count;
        for (RIPCard *c in self.selectedTest.cardStore) {
            if (c.isCorrect)
                correctQuestions++;
        }
        
        if (self.selectedTest.time != 0) {
            minutes = self.selectedTest.timeRemaining / 60;
            seconds = self.selectedTest.timeRemaining % 60;
            timeRemaining = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
            minutes = self.selectedTest.time / 60;
            seconds = self.selectedTest.time % 60;
            totalTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
            self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", timeRemaining, totalTime];
        } else {
            self.timeLabel.text = [NSString stringWithFormat:@"Off"];
        }
        
        if ([self.selectedTest.operation isEqualToString:ADDITION] || [self.selectedTest.operation isEqualToString:SUBTRACTION]) {
            self.difficultyTitle.text = @"Difficulty";
            switch (self.selectedTest.difficulty) {
                case 1: self.difficultyLabel.text = [NSString stringWithFormat:@"Easy"]; break;
                case 2: self.difficultyLabel.text = [NSString stringWithFormat:@"Medium"]; break;
                case 3: self.difficultyLabel.text = [NSString stringWithFormat:@"Hard"]; break;
                case 4: self.difficultyLabel.text = [NSString stringWithFormat:@"Expert"]; break;
                default: break;
            }
        } else {
            if ([self.selectedTest.operation isEqualToString:MULTIPLICATION])
                self.difficultyTitle.text = @"Multiplier";
            else
                self.difficultyTitle.text = @"Divisor";
            if (self.selectedTest.difficulty == 13)
                self.difficultyLabel.text = [NSString stringWithFormat:@"All"];
            else
                self.difficultyLabel.text = [NSString stringWithFormat:@"%ld", (long)self.selectedTest.difficulty];
        }
    }
    //Displays the number of questions total and correct
    self.questionsLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)correctQuestions, (long)totalQuestions];
    
    //Registers custom UITableViewCell nib
    cardCellNib = [UINib nibWithNibName:@"RIPCardCell" bundle:nil];
    [self.cardTableView registerNib:cardCellNib forCellReuseIdentifier:@"RIPCardCell"];
    [self.cardTableView setAllowsSelection:NO];
    [self.cardTableView setAlwaysBounceVertical:NO];
    self.cardTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.cardTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
}

@end
