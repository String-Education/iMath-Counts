//
//  RIPCardCell.h
//  MathCounts
//
//  Created by Nick Stanley on 6/30/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPCardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *questionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionAnswerLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionCorrectLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctAnswerLabel;

@end
