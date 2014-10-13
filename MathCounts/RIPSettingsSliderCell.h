//
//  RIPSettingsSliderCell.h
//  MathCounts
//
//  Created by Tynan Douglas on 7/17/14.
//  Copyright (c) 2014 GetMoney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPSettingsSliderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *toggle;
@end
