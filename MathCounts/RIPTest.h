//
//  RIPTest.h
//  MathCounts
//
//  Created by Nick Stanley on 7/1/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPTest : NSObject
<NSCoding>

+ (instancetype)generateTest;

@property (copy, nonatomic) NSArray *cardStore;
@property (copy, nonatomic) NSString *operation;
@property (nonatomic) NSInteger time;
@property (nonatomic) NSInteger timeRemaining;
@property (nonatomic) NSInteger difficulty;
@property (strong, nonatomic) NSDate *dateTaken;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) NSInteger questionsTotal;
@property (nonatomic) NSInteger questionsCorrect;
@property (nonatomic) BOOL quit;

@end
