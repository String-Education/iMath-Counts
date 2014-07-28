//
//  RIPMainMenuViewController.h
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPOperationButton.h"

@interface RIPMainMenuViewController : UIViewController

@property (strong, nonatomic) RIPOperationButton *addButton;
@property (strong, nonatomic) RIPOperationButton *subtractButton;
@property (strong, nonatomic) RIPOperationButton *multiplyButton;
@property (strong, nonatomic) RIPOperationButton *divideButton;

@end
