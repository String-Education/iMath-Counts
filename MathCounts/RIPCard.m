//
//  RIPCard.m
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPCard.h"

@interface RIPCard ()

@end

#pragma mark

@implementation RIPCard

#pragma mark Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isViewed = NO;
        _isCorrect = NO;
        _isAnswered = NO;
    }
    return self;
}

#pragma mark Encoder methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _firstNum = [aDecoder decodeIntegerForKey:@"firstNum"];
        _secondNum = [aDecoder decodeIntegerForKey:@"secondNum"];
        _answer = [aDecoder decodeIntegerForKey:@"answer"];
        _inputAnswer = [aDecoder decodeIntegerForKey:@"inputAnswer"];
        _isViewed = [aDecoder decodeBoolForKey:@"isViewed"];
        _isCorrect = [aDecoder decodeBoolForKey:@"isCorrect"];
        _isAnswered = [aDecoder decodeBoolForKey:@"isAnswered"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.firstNum forKey:@"firstNum"];
    [aCoder encodeInteger:self.secondNum forKey:@"secondNum"];
    [aCoder encodeInteger:self.answer forKey:@"answer"];
    [aCoder encodeInteger:self.inputAnswer forKey:@"inputAnswer"];
    [aCoder encodeBool:self.isViewed forKey:@"isViewed"];
    [aCoder encodeBool:self.isCorrect forKey:@"isCorrect"];
    [aCoder encodeBool:self.isAnswered forKey:@"isAnswered"];
}

@end