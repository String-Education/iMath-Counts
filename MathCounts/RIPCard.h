//
//  RIPCard.h
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPCard : NSObject
<NSCoding>

@property (nonatomic) NSInteger firstNum;
@property (nonatomic) NSInteger secondNum;
@property (nonatomic) NSInteger answer;
@property (nonatomic) NSInteger inputAnswer;
@property (nonatomic) BOOL isViewed;
@property (nonatomic) BOOL isCorrect;
@property (nonatomic) BOOL isAnswered;

@end
