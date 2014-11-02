//
//  RIPSettingsViewController.m
//  MathCounts
//
//  Created by Nick Stanley on 7/17/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPSettingsViewController.h"
#import "RIPSettingsManager.h"
#import "RIPSwitchCell.h"
#import "RIPDataManager.h"
#import <Dropbox/Dropbox.h>

@interface RIPSettingsViewController ()
<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;
@property (strong, nonatomic) NSIndexPath *dropboxPath;
@property (strong, nonatomic) NSIndexPath *passwordPath;

@end

@implementation RIPSettingsViewController

- (void)updateSettings:(id)sender
{
    RIPSettingsManager *sharedManager = [RIPSettingsManager sharedManager];
    RIPSwitchCell *dropboxCell = (RIPSwitchCell *)[self.settingsTableView cellForRowAtIndexPath:self.dropboxPath];
    RIPSwitchCell *passwordCell = (RIPSwitchCell *)[self.settingsTableView cellForRowAtIndexPath:self.passwordPath];
    
    if (sender == dropboxCell.toggle) {
        if (dropboxCell.toggle.on) {
            [[DBAccountManager sharedManager] linkFromController:self];
        } else {
            DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
            if (account)
                [account unlink];
        }
        [self.settingsTableView reloadRowsAtIndexPaths:@[self.dropboxPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (sender == passwordCell.toggle) {
        if (passwordCell.toggle.on) {
            sharedManager.passwordEnabled = YES;
            [self showCreatePasswordPrompt];
        } else {
            sharedManager.passwordEnabled = NO;
            sharedManager.password = nil;
        }
    }
    [sharedManager saveSettings];
}

- (void)dismissSettings:(id)sender
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopover" object:self];
    else
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCreatePasswordPrompt
{
    UIAlertView *setPasswordAlert;
    UITextField *firstPassword;
    UITextField *secondPassword;
    
    setPasswordAlert = [[UIAlertView alloc] initWithTitle:@"New Password"
                                                  message:@"The password must be re-entered correctly to continue."
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"OK", nil];
    
    //Configures first password field
    [setPasswordAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[setPasswordAlert textFieldAtIndex:0] setSecureTextEntry:YES];
    firstPassword = [setPasswordAlert textFieldAtIndex:0];
    [firstPassword setPlaceholder:@"Enter Password"];
    
    //Second password field
    secondPassword = [setPasswordAlert textFieldAtIndex:1];
    [secondPassword setPlaceholder:@"Re-enter"];
    [setPasswordAlert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *firstPassword;
    NSString *secondPassword;
    
    //Password can only be set if they match
    firstPassword = [[alertView textFieldAtIndex:0] text];
    secondPassword = [[alertView textFieldAtIndex:1] text];
    if ([firstPassword length] > 0 && [firstPassword isEqualToString:secondPassword])
        return YES;
    else
        return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *firstPassword;
    RIPSettingsManager *sharedManager = [RIPSettingsManager sharedManager];
    RIPSwitchCell *passwordCell = (RIPSwitchCell *)[self.settingsTableView cellForRowAtIndexPath:self.passwordPath];
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        [passwordCell.toggle setOn:NO animated:YES];
        sharedManager.passwordEnabled = NO;
    } else if (buttonIndex == alertView.firstOtherButtonIndex) {
        firstPassword = [[alertView textFieldAtIndex:0] text];
        [sharedManager setPassword:firstPassword];
        [sharedManager saveSettings];
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIPSettingsManager *sharedManager = [RIPSettingsManager sharedManager];
    RIPSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RIPSwitchCell" forIndexPath:indexPath];
    [cell.toggle addTarget:self action:@selector(updateSettings:) forControlEvents:UIControlEventValueChanged];
    switch (indexPath.section) {
        //Section 1: Storage
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"Dropbox storage";
                    if ([[DBAccountManager sharedManager] linkedAccount]) {
                        cell.descriptionLabel.text = @"Dropbox storage enabled";
                        [cell.toggle setOn:YES];
                    } else {
                        cell.descriptionLabel.text = @"Dropbox storage disabled";
                        [cell.toggle setOn:NO];
                    }
                    self.dropboxPath = indexPath;
                    break;
                default: break;
            }
            break;
        //Section 2: Security
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.titleLabel.text = @"Password protect";
                    cell.descriptionLabel.text = @"To prevent changes to settings";
                    if (sharedManager.passwordEnabled)
                        [cell.toggle setOn:YES];
                    else
                        [cell.toggle setOn:NO];
                    self.passwordPath = indexPath;
                default: break;
            }
            break;
        default: break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //Set settings group headers here
    //Pad 4 spaces for now
    UILabel *header = [[UILabel alloc] init];
    switch (section) {
        case 0: header.text = @"    Storage"; break;
        case 1: header.text = @"    Security"; break;
        default: header.text = nil; break;
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
    //Registers custom UITableViewCell nib and configures navigationItem
    UINib *settingsCellNib = [UINib nibWithNibName:@"RIPSwitchCell" bundle:nil];
    [self.settingsTableView registerNib:settingsCellNib forCellReuseIdentifier:@"RIPSwitchCell"];
    
    self.navigationItem.title = @"Settings";
    
    //Sets the navigation bar color
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
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
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(dismissSettings:)];
    self.navigationItem.leftBarButtonItem = doneItem;
    
    //Sets observer status to refresh the Dropbox toggle cell if enabled and create/shut down a filesystem appropriately
    [[DBAccountManager sharedManager] addObserver:self block:^(DBAccount *account){
        [self.settingsTableView reloadRowsAtIndexPaths:@[self.dropboxPath] withRowAnimation:UITableViewRowAnimationFade];
        DBAccount *linkedAccount = [[DBAccountManager sharedManager] linkedAccount];
        if (linkedAccount) {
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:linkedAccount];
            [DBFilesystem setSharedFilesystem:filesystem];
        } else {
//            if ([DBFilesystem sharedFilesystem])
                [[DBFilesystem sharedFilesystem] shutDown];
        }
    }];
}

- (void)dealloc
{
    [[DBAccountManager sharedManager] removeObserver:self];
}

@end
