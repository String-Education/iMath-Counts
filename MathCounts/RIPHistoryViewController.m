//
//  RIPHistoryViewController.m
//  MathCounts
//
//  Created by Nick Stanley on 7/1/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPHistoryViewController.h"
#import "RIPDataManager.h"
#import "RIPTestCell.h"
#import "RIPTest.h"
#import "RIPResultsViewController.h"
#import "RIPSettingsManager.h"

@interface RIPHistoryViewController ()
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *nameSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *testTableView;
@property (copy, nonatomic) NSString *searchText;
@property (strong, nonatomic) NSIndexPath *cellIndexPath;
@property (strong, nonatomic) UIAlertView *passwordPrompt;
@property (strong, nonatomic) UIAlertView *deleteAllPrompt;
@property (nonatomic) BOOL deleteAll;

@end

#pragma mark

@implementation RIPHistoryViewController

#pragma mark Test management

- (void)deleteAllTests:(id)sender
{
    RIPSettingsManager *sharedManager = [RIPSettingsManager sharedManager];
    self.deleteAll = YES;
    if (sharedManager.passwordEnabled) {
        [self.passwordPrompt show];
    } else
        [self.deleteAllPrompt show];
}

- (void)dismissHistory:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteOneTest
{
    RIPDataManager *dataManager = [RIPDataManager sharedManager];
    NSMutableArray *tempTestStore;
    NSInteger i;
    
    i = dataManager.testStore.count - self.cellIndexPath.row - 1;
    RIPTest *t = dataManager.testStore[i];
    
    if (self.searchText) {
        tempTestStore = [[NSMutableArray alloc] init];
        for (RIPTest *test in dataManager.testStore) {
            if ([test.name rangeOfString:self.searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [tempTestStore addObject:test];
            }
        }
        i = tempTestStore.count - self.cellIndexPath.row - 1;
        t = tempTestStore[i];
    }
    [dataManager removeTest:t];
    [dataManager saveTest];
    [self.testTableView deleteRowsAtIndexPaths:@[self.cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark UITextField methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchText = searchText;
    if ([searchText isEqualToString:@""])
        self.searchText = nil;
    [self.testTableView reloadData];
}

#pragma mark UIAlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    RIPSettingsManager *settingsManager = [RIPSettingsManager sharedManager];
    RIPDataManager *dataManager = [RIPDataManager sharedManager];
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (alertView == self.passwordPrompt) {
        NSString *inputPassword = [[alertView textFieldAtIndex:0] text];
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            if ([inputPassword isEqualToString:settingsManager.password]) {
                if (!self.deleteAll)
                    [self deleteOneTest];
                else
                    [self.deleteAllPrompt show];
            } else {
                UIAlertView *incorrectPassword = [[UIAlertView alloc] initWithTitle:@"Incorrect Password"
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                [incorrectPassword show];
            }
        }
    } else if (alertView == self.deleteAllPrompt) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [dataManager removeAllTests];
            [dataManager saveTest];
            [self.testTableView reloadData];
        }
    }
}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    NSMutableArray *tempTestStore;
    NSInteger i;
    
    //Fetches a test from the testStore
    i = sharedManager.testStore.count - indexPath.row - 1;
    RIPTest *t = sharedManager.testStore[i];
    
    //If text is in the search bar, fills separate testStore with tests matching
    //the name being searched for and fetches a test from this array instead
    if (self.searchText) {
        tempTestStore = [[NSMutableArray alloc] init];
        for (RIPTest *test in sharedManager.testStore) {
            if ([test.name rangeOfString:self.searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [tempTestStore addObject:test];
            }
        }
        i = tempTestStore.count - indexPath.row - 1;
        t = tempTestStore[i];
    }
    //Deselects row and pushes results view displaying the appropriate test
    [self.testTableView deselectRowAtIndexPath:indexPath animated:YES];
    RIPResultsViewController *results = [[RIPResultsViewController alloc] initWithNewTest:NO];
    results.selectedTest = t;
    [self.navigationController pushViewController:results animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Removes deleted cell and removes corresponding test from the testStore
        RIPSettingsManager *settingsManager = [RIPSettingsManager sharedManager];
        self.cellIndexPath = indexPath;
        if (settingsManager.password) {
            [self.passwordPrompt show];
        } else {
            [self deleteOneTest];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    NSMutableArray *tempTestStore;
    
    //Returns number of tests matching the searched name if one is specified
    //Otherwise returns all tests
    if (self.searchText) {
        tempTestStore = [[NSMutableArray alloc] init];
        for (RIPTest *test in sharedManager.testStore) {
            if ([test.name rangeOfString:self.searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [tempTestStore addObject:test];
            }
        }
        return tempTestStore.count;
    }
    return [sharedManager.testStore count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIPTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RIPTestCell" forIndexPath:indexPath];
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    NSMutableArray *tempTestStore;
    NSInteger i;
    
    //Fetches a test from the testStore
    i = sharedManager.testStore.count - indexPath.row - 1;
    RIPTest *t = sharedManager.testStore[i];

    //If text is in the search bar, fills separate testStore with tests matching the name being searched for
    //and fetches a test from this array instead
    if (self.searchText) {
        tempTestStore = [[NSMutableArray alloc] init];
        for (RIPTest *test in sharedManager.testStore) {
            if ([test.name rangeOfString:self.searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [tempTestStore addObject:test];
            }
        }
        i = tempTestStore.count - indexPath.row - 1;
        t = tempTestStore[i];
    }
    
    //Displays name
    if ([t.name isEqualToString:@""])
        cell.nameLabel.text = @"No Name";
    else
        cell.nameLabel.text = t.name;
    
    //Displays questions correct out of questions total
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d/%d", t.questionsCorrect, t.questionsTotal];
    
    //Displays operation
    if ([t.operation isEqualToString:ADDITION]) {
        cell.operationLabel.text = @"+";
        cell.operationLabel.textColor = [UIColor redColor];
    } else if ([t.operation isEqualToString:SUBTRACTION]) {
        cell.operationLabel.text = @"-";
        cell.operationLabel.textColor = [UIColor blueColor];
    } else if ([t.operation isEqualToString:MULTIPLICATION]) {
        cell.operationLabel.text = @"x";
        cell.operationLabel.textColor = [UIColor greenColor];
    } else if ([t.operation isEqualToString:DIVISION]) {
        cell.operationLabel.text = @"÷";
        cell.operationLabel.textColor = [UIColor purpleColor];
    }
    
    //Displays the date the test was taken
    cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:t.dateTaken dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.testTableView setEditing:editing animated:animated];
}

#pragma mark View methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
    UINib *testCellNib;
    UIBarButtonItem *deleteAllItem;
    UIBarButtonItem *doneItem;
    
    //Registers custom UITableViewCell nib and configures navigationItem
    deleteAllItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                  target:self
                                                                  action:@selector(deleteAllTests:)];
    doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                             target:self
                                                             action:@selector(dismissHistory:)];
    testCellNib = [UINib nibWithNibName:@"RIPTestCell" bundle:nil];
    [self.testTableView registerNib:testCellNib forCellReuseIdentifier:@"RIPTestCell"];
    self.navigationItem.title = @"History";
    self.navigationItem.rightBarButtonItems = @[deleteAllItem, self.editButtonItem];
    self.navigationItem.leftBarButtonItem = doneItem;
    
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
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
    
    self.nameSearchBar.placeholder = @"Name";
    
    //Configures 2 different alert views
    self.passwordPrompt = [[UIAlertView alloc] initWithTitle:@"Enter Password"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil];
    [self.passwordPrompt setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    self.deleteAllPrompt = [[UIAlertView alloc] initWithTitle:nil
                                                      message:@"Are you sure you want to delete all tests?"
                                                     delegate:self
                                            cancelButtonTitle:@"No"
                                            otherButtonTitles:@"Yes", nil];
    
    //Configures search keyboard to have return key
    for (UIView *subview in self.nameSearchBar.subviews)
    {
        for (UIView *subSubview in subview.subviews)
        {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)])
            {
                UITextField *textField = (UITextField *)subSubview;
                textField.delegate = self;
                [textField setKeyboardAppearance: UIKeyboardAppearanceDefault];
                textField.returnKeyType = UIReturnKeyDone;
                break;
            }
        }
    }
    [self.testTableView setAlwaysBounceVertical:NO];
    self.testTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.testTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
}

@end
