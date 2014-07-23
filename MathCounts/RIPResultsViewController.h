//
//  RIPResultsViewController.h
//  MathCounts
//
//  Created by Nick Stanley on 6/30/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPTest.h"

@interface RIPResultsViewController : UIViewController

- (instancetype)initWithNewTest:(BOOL)isNew;

@property (strong, nonatomic) RIPTest *selectedTest;

@end
