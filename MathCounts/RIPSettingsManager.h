//
//  RIPSettingsManager.h
//  MathCounts
//
//  Created by Nick Stanley on 7/18/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPSettingsManager : NSObject
<NSCoding>

+ (instancetype)sharedManager;

- (BOOL)saveSettings;

@property (nonatomic) BOOL dropboxEnabled;
@property (nonatomic) BOOL passwordEnabled;
@property (copy, nonatomic) NSString *password;

@end
