//
//  RIPTimeTestViewController.m
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPTimeTestViewController.h"
#import "RIPDataManager.h"
#import "RIPCardViewController.h"
#import "RIPResultsViewController.h"

@interface RIPTimeTestViewController ()
<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate>

@property (copy, nonatomic) NSString *timerLabel;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UIBarButtonItem *submitItem;

@end

#pragma mark

@implementation RIPTimeTestViewController

#pragma mark Callback methods

- (void)returnToMainMenu:(id)sender
{
    //Configures and displays alert warning user of exiting the quiz
     UIAlertView *quitAlert = [[UIAlertView alloc] initWithTitle:@"Quiz in progress"
                                                 message:@"Are you sure you want to stop the quiz?"
                                                delegate:self
                                       cancelButtonTitle:@"No"
                                       otherButtonTitles:@"Yes", nil];
    [quitAlert show];
}

- (void)timerTick:(NSTimer *)timer
{
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    //Adjusts the displayed timer each second
    if (sharedManager.timeRemaining > 0) {
        sharedManager.timeRemaining--;
        minutes = sharedManager.timeRemaining / 60;
        seconds = sharedManager.timeRemaining % 60;
        self.timerLabel = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        self.navigationItem.title = self.timerLabel;
    } else if (sharedManager.timeRemaining == 0) {
        RIPResultsViewController *results = [[RIPResultsViewController alloc] init];
        [self.timer invalidate];
        [self.navigationController pushViewController:results animated:YES];
    }
}

- (void)scroll:(NSNotification *)note
{
    //pos used to find the index of the currently displayed card
    //index used to find the index of the next card to scroll to
    NSInteger pos = 0;
    NSInteger index = 0;
    BOOL unansweredCardFound = NO;
    RIPCardViewController *cardViewToDisplay;
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    __weak UIPageViewController *pageController = self.pageController;

    //Gets the displayed RIPCard for the currently displayed view
    RIPCard *displayedCard = [(RIPCardViewController *)self.pageController.viewControllers[0] displayedCard];
    
    //Finds the index of the index of the currently displayed card in the cardStore
    for (int i = 0; i < sharedManager.cardStore.count; i++) {
        if ([sharedManager.cardStore[i] isEqual:displayedCard]) {
            pos = i;
            break;
        }
    }
    //First looks for any unviewed card after the current index
    for (int i = pos + 1; i < [sharedManager.cardStore count]; i++) {
        if (![(RIPCard *)sharedManager.cardStore[i] isAnswered]) {
            index = i;
            unansweredCardFound = YES;
            break;
        }
    }
    //If none are found, looks before the current index
    if (!unansweredCardFound) {
        for (int i = 0; i < pos; i++) {
            if (![(RIPCard *)sharedManager.cardStore[i] isAnswered]) {
                index = i;
                unansweredCardFound = YES;
                break;
            }
        }
    }
    //If a card is found, creates a view controller with it and displays it
    if (unansweredCardFound) {
        cardViewToDisplay = [[RIPCardViewController alloc] initWithCardIndex:index];
        if (index > pos) {
            if ((index - pos) > 1) {
                [self.pageController setViewControllers:@[cardViewToDisplay]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:YES
                                             completion:^(BOOL finished) {
                                                 UIPageViewController* pvcs = pageController;
                                                 if (!pvcs) return;
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [pvcs setViewControllers:@[cardViewToDisplay]
                                                                    direction:UIPageViewControllerNavigationDirectionForward
                                                                     animated:NO
                                                                   completion:nil];
                                                 });
                                             }];
            } else {
                [self.pageController setViewControllers:@[cardViewToDisplay]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:YES
                                             completion:nil];
            }
        } else if (index < pos) {
            if ((pos - index) > 1) {
                [self.pageController setViewControllers:@[cardViewToDisplay]
                                              direction:UIPageViewControllerNavigationDirectionReverse
                                               animated:YES
                                             completion:^(BOOL finished) {
                                                 UIPageViewController* pvcs = pageController;
                                                 if (!pvcs) return;
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [pvcs setViewControllers:@[cardViewToDisplay]
                                                                    direction:UIPageViewControllerNavigationDirectionReverse
                                                                     animated:NO
                                                                   completion:nil];
                                                 });
                                             }];
            } else {
                [self.pageController setViewControllers:@[cardViewToDisplay]
                                              direction:UIPageViewControllerNavigationDirectionReverse
                                               animated:YES
                                             completion:nil];
            }
        }
        if (index == [sharedManager.cardStore indexOfObject:[sharedManager.cardStore lastObject]]) {
            [self.submitItem setEnabled:YES];
        }
    } else {
        [self.submitItem setEnabled:YES];
    }
}

- (void)submitTest:(id)sender
{
    RIPResultsViewController *results = [[RIPResultsViewController alloc] init];
    [self.timer invalidate];
    [self.navigationController pushViewController:results animated:YES];
}

#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        sharedManager.quit = YES;
        //Generates .xls if Dropbox option is enabled
        //Consider different way of doing this
        RIPTest *t = [RIPTest generateTest];
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark UIPageViewControllerDataSource methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed && !self.submitItem.enabled) {
        RIPDataManager *sharedManager = [RIPDataManager sharedManager];
        BOOL allCardsViewed = YES;
        for (RIPCard *c in sharedManager.cardStore) {
            if (!c.isViewed)
                allCardsViewed = NO;
        }
        if (allCardsViewed)
            [self.submitItem setEnabled:YES];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [(RIPCardViewController *)viewController cardIndex];
    if (index == 0)
        return nil;
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [(RIPCardViewController *)viewController cardIndex];
    index++;
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    if (index == [sharedManager.cardStore count])
        return nil;
    return [self viewControllerAtIndex:index];
}

- (RIPCardViewController *)viewControllerAtIndex:(NSInteger)index
{
    RIPCardViewController *cardViewController = [[RIPCardViewController alloc] initWithCardIndex:index];
    return cardViewController;
}

#pragma mark View methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger time;
    NSInteger minutes;
    NSInteger seconds;
    UIBarButtonItem *returnItem;
    NSArray *viewControllers;
    RIPCardViewController *initialViewController;
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
    //Creates and displays the timer with an initial time
    time = sharedManager.time;
    if (time) {
        minutes = time / 60;
        seconds = time % 60;
        self.timerLabel = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        self.navigationItem.title = self.timerLabel;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(timerTick:)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer
                                     forMode:NSDefaultRunLoopMode];
    }
    //Configures and displays custom back button
    returnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                               target:self
                                                               action:@selector(returnToMainMenu:)];
    self.navigationItem.leftBarButtonItem = returnItem;
    
    self.submitItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitTest:)];
    
    [self.submitItem setEnabled:NO];
    self.navigationItem.rightBarButtonItem = self.submitItem;
    
    //Gets first cardViewController and puts it in an array
    initialViewController = [self viewControllerAtIndex:0];
    viewControllers = [NSArray arrayWithObject:initialViewController];
    
    //Disables navigation via gestures
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    //Registers self as observer for notification posted by cardViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scroll:)
                                                 name:@"doneEditing"
                                               object:nil];
    
    //Initializes, configures, and displays pageViewController
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    CGRect viewBounds = [[self view] bounds];
    CGRect pageControllerBounds = CGRectMake(viewBounds.origin.x, viewBounds.origin.y, viewBounds.size.width, (viewBounds.size.height / 2.0));
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    self.pageController.automaticallyAdjustsScrollViewInsets = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    [[self.pageController view] setFrame:pageControllerBounds];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.timer invalidate];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
