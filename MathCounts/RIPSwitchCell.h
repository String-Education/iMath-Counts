//
//  RIPSettingsSliderCell.h
//  MathCounts
//
//  Created by Nick Stanley on 7/17/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggle;

@end
