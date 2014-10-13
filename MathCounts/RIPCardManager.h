//
//  RIPCardManager.h
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 GetMoney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIPTest.h"

//Public constants used in lieu of hard coding strings
static NSString *const ADDITION = @"Addition";
static NSString *const SUBTRACTION = @"Subtraction";
static NSString *const MULTIPLICATION = @"Multiplication";
static NSString *const DIVISION = @"Division";

@interface RIPCardManager : NSObject

+ (instancetype)sharedManager;

- (void)changeSettings:(NSInteger)numQuestions difficulty:(NSInteger)difficulty operation:(NSString *)operation time:(NSInteger)time name:(NSString *)name;
- (void)generateCards;
- (BOOL)saveTest;
- (void)addTest:(RIPTest *)test;
- (void)removeTest:(RIPTest *)test;

@property (readonly, nonatomic) NSArray *testStore;
@property (readonly, nonatomic) NSArray *cardStore;
@property (copy, nonatomic) NSString *operation;
@property (nonatomic) NSInteger time;
@property (nonatomic) NSInteger timeRemaining;
@property (nonatomic) NSInteger difficulty;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) BOOL quit;
@property (nonatomic) BOOL dropboxEnabled;
@property (nonatomic) BOOL passwordEnabled;

@end
