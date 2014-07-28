//
//  RIPCardViewController.h
//  MathCounts
//
//  Created by Nick Stanley on 6/21/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPCard.h"

@interface RIPCardViewController : UIViewController

- (instancetype)initWithCardIndex:(NSInteger)index;

@property (weak, nonatomic) IBOutlet UITextField *answerField;
@property (weak, nonatomic) RIPCard *displayedCard;
@property (nonatomic) NSInteger cardIndex;

@end
