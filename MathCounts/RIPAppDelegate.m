//
//  RIPAppDelegate.m
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPAppDelegate.h"
#import "RIPHomePageViewController.h"
#import "RIPDataManager.h"
#import <Dropbox/Dropbox.h>

@implementation RIPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //Creates Dropbox accountManager and filesystem if available
    DBAccountManager *accountManager =
    [[DBAccountManager alloc] initWithAppKey:@"ugz7chkom1kuenb" secret:@"hrkqjp3yj3wh2hg"];
    [DBAccountManager setSharedManager:accountManager];
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        if (![DBFilesystem sharedFilesystem]) {
            DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
            [DBFilesystem setSharedFilesystem:filesystem];
        }
    }
    
    self.window.tintColor = [UIColor whiteColor];
    
    //Sets UINavigationBar, UIBarButtonItem, and status bar text colors to white
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:navbarTitleTextAttributes forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Creates home page controller and places it in a navigation controller
    RIPHomePageViewController *home = [[RIPHomePageViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:home];
    navController.navigationBar.backgroundColor = [UIColor darkGrayColor];
    
    self.window.rootViewController = navController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[RIPDataManager sharedManager] saveTest];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[RIPDataManager sharedManager] saveTest];
}

@end
