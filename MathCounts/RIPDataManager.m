//
//  RIPCardManager.m
//  MathCounts
//
//  Created by Nick Stanley on 6/19/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPDataManager.h"
#import "RIPCard.h"

@interface RIPDataManager ()

@property (strong, nonatomic) NSMutableArray *privateCardStore;
@property (strong, nonatomic) NSMutableArray *privateTestStore;
@property (strong, nonatomic) NSMutableArray *privateTodaysTests;
@property (nonatomic) NSInteger numQuestions;

@end

#pragma mark

@implementation RIPDataManager

#define ItoN(x) [NSNumber numberWithInteger:x]
#define NtoI(x) [x integerValue]

#pragma mark Initializers

+ (instancetype)sharedManager
{
    //Creates single cardManager instance
    static RIPDataManager *sharedManager = nil;
    
    //Creates thread-safe singleton; has to do with multithreading; research this more
    static dispatch_once_t token;
    dispatch_once(&token, ^{ sharedManager = [[self alloc] initPrivate]; });
    return sharedManager;
}

- (instancetype)initPrivate
{
    //Private init method
    self = [super init];
    
    NSString *testDate;
    NSString *currentDate;
    
    if (self) {
        self.privateTestStore = [NSKeyedUnarchiver unarchiveObjectWithFile:[self testArchivePath]];
        if (!self.privateTestStore)
            self.privateTestStore = [[NSMutableArray alloc] init];
        
        self.privateTodaysTests = [NSKeyedUnarchiver unarchiveObjectWithFile:[self todaysTestsArchivePath]];
        if (self.privateTodaysTests) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            RIPTest *t = self.privateTodaysTests[0];
            testDate = [dateFormatter stringFromDate:t.dateTaken];
            currentDate = [dateFormatter stringFromDate:[NSDate date]];
        }
        if (!self.privateTodaysTests || ![currentDate isEqualToString:testDate])
            self.privateTodaysTests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)init
{
    //Throws an exception and corrects the user on what to do
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use + [RIPDataManager sharedManager]"
                                 userInfo:nil];
    return nil;
}

#pragma mark Instance methods

- (void)changeSettings:(NSInteger)numQuestions difficulty:(NSInteger)difficulty operation:(NSString *)operation time:(NSInteger)time name:(NSString *)name
{
    //Adjusts settings according to parameter input
    if (operation)
        self.operation = operation;
    if (numQuestions)
        self.numQuestions = numQuestions;
    if (difficulty)
        self.difficulty = difficulty;
    self.time = time;
    self.timeRemaining = time;
    if (name)
        self.name = name;
    self.quit = NO;

}

- (NSString *)todaysTestsArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories[0];
    return [documentDirectory stringByAppendingPathComponent:@"todaysTests.archive"];
}


- (BOOL)saveTodaysTests
{
    return [NSKeyedArchiver archiveRootObject:self.todaysTests toFile:[self todaysTestsArchivePath]];
}

- (void)addToTodaysTests:(RIPTest *)test
{
    [_privateTodaysTests addObject:test];
    [_privateTodaysTests sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSString *first = [(RIPTest *)obj1 name];
        NSString *second = [(RIPTest *)obj2 name];
        return [first compare:second];
    }];
    [self saveTodaysTests];
}

- (NSString *)testArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories[0];
    return [documentDirectory stringByAppendingPathComponent:@"tests.archive"];
}

- (BOOL)saveTest
{
    return [NSKeyedArchiver archiveRootObject:self.testStore toFile:[self testArchivePath]];
}

- (void)addTest:(RIPTest *)test
{
    [_privateTestStore addObject:test];
}

- (void)removeTest:(RIPTest *)test
{
    [_privateTestStore removeObjectIdenticalTo:test];
}

- (void)removeAllTests
{
    [_privateTestStore removeAllObjects];
}

#pragma mark Number generation algorithms

- (void)generateCards
{
    NSArray *testValues;
    self.privateCardStore = [[NSMutableArray alloc] init];
    
    //Generates questions based on operation, diffiulty, and number of questions
    if ([self.operation isEqualToString:ADDITION]) {
        testValues = getAdditionRandy(self.difficulty, self.numQuestions);
    } else if ([self.operation isEqualToString:SUBTRACTION]) {
        testValues = getSubtractionRandy(self.difficulty, self.numQuestions);
    } else if ([self.operation isEqualToString:MULTIPLICATION]) {
        testValues = getMultiplicationRandy(self.difficulty, self.numQuestions);
    } else if ([self.operation isEqualToString:DIVISION]) {
        testValues = getDivisionRandy(self.difficulty, self.numQuestions);
    }
    //Populates the card store with generated values
    for (int i = 0; i < self.numQuestions; i++) {
        RIPCard *card = [[RIPCard alloc] init];
        card.firstNum = NtoI(testValues[i][0]);
        card.secondNum = NtoI(testValues[i][1]);
        card.answer = NtoI(testValues[i][2]);
        [self.privateCardStore addObject:card];
    }
}

BOOL checkExists(NSArray *questionValues, NSInteger index, NSInteger repeats)
{
    NSInteger counter = 0;
    NSInteger firstNum = (NSInteger)questionValues[index][0];
    NSInteger secondNum = (NSInteger)questionValues[index][1];
    
    //Limits number of repeats in addition/subtraction questions
    for(int i = 0; i < index; i++) {
        if((NSInteger)questionValues[i][0] == firstNum || (NSInteger)questionValues[i][1] == secondNum) {
            counter++;
        }
    }
    if(counter > repeats)
        return true;
    return false;
}

BOOL checkExistsRepeats(NSArray *questionValues, NSInteger index, NSInteger firstNum, NSInteger secondNum, NSInteger repeats)
{
    NSInteger counter = 0;
    
    //Limits number of repeats in multiplication/division questions
    for (int i = 0; i < index; i++) {
        if ((NSInteger)questionValues[i][0] == firstNum && (NSInteger)questionValues[i][1] == secondNum) {
            if (i == (index - 1)) {
                return true;
            }
            counter++;
        }
        if (counter > repeats) {
            return true;
        }
    }
    return false;
}

double getNormalDist()
{
    //Effectively returns a normally distributed number between -3 and 3
    return (drand48()*2 - 1) + (drand48()*2 - 1) + (drand48()*2 - 1);
}

NSInteger getWeightedRandom(NSInteger mean, NSInteger stdDeviation)
{
    //Returns a value based on a given standard deviation and mean
    return (NSInteger)round(getNormalDist()*stdDeviation + mean);
}

NSArray *getAdditionRandy(NSInteger level, NSInteger numQuestions)
{
    switch (level) {
        case 1:
            return getEasyAddition(numQuestions);
        case 2:
            return getMediumAddition(numQuestions);
        case 3:
            return getHardAddition(numQuestions);
        case 4:
            return getExpertAddition(numQuestions);
        default:
            return getEasyAddition(numQuestions);
    }
}

NSArray *getSubtractionRandy(NSInteger level, NSInteger numQuestions)
{
    switch (level) {
        case 1:
            return getEasySubtraction(numQuestions);
        case 2:
            return getMediumSubtraction(numQuestions);
        case 3:
            return getHardSubtraction(numQuestions);
        case 4:
            return getExpertSubtraction(numQuestions);
        default:
            return getEasySubtraction(numQuestions);
    }
}

NSArray *getEasyAddition(NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    
    //Nests the questionValues array with an array of ints wrapped in NSNumbers for each question
    //This is performed at the beginning of each getOperation
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    //Assigns each value to a value between 0 and 10, with 0 being slightly less likely
    for (int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(2) == 0) {
                questionValues[i][0] = ItoN(arc4random_uniform(10) + 1);
                questionValues[i][1] = ItoN(arc4random_uniform(10) + 1);
            } else {
                questionValues[i][0] = ItoN(arc4random_uniform(11));
                questionValues[i][1] = ItoN(arc4random_uniform(11));
            }
        } while (checkExists(questionValues, i, numQuestions / 7));
        questionValues[i][2] = ItoN(NtoI(questionValues[i][0]) + NtoI(questionValues[i][1]));
    }
    return questionValues;
}

NSArray *getMediumAddition(NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    //Assigns each value to a number along one of two normal distributions with a mean of 15
    for (int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(10) > 3) {
                do {
                    questionValues[i][0] = ItoN(getWeightedRandom(15, 6));
                } while (NtoI(questionValues[i][0]) > 15 || NtoI(questionValues[i][0]) < 5);
            } else {
                do {
                    questionValues[i][0] = ItoN(getWeightedRandom(15, 4));
                } while (NtoI(questionValues[i][0]) <= 15 || NtoI(questionValues[i][0]) > 25);
            }
            if (arc4random_uniform(10) > 3) {
                do {
                    questionValues[i][1] = ItoN(getWeightedRandom(15, 6));
                } while (NtoI(questionValues[i][1]) > 15 || NtoI(questionValues[i][1]) < 5);
            } else {
                do {
                    questionValues[i][1] = ItoN(getWeightedRandom(15, 4));
                } while (NtoI(questionValues[i][1]) <= 15 || NtoI(questionValues[i][1]) > 25);
            }
        } while (checkExists(questionValues, i, numQuestions / 10));
        questionValues[i][2] = ItoN(NtoI(questionValues[i][0]) + NtoI(questionValues[i][1]));
    }
    return questionValues;
}

NSArray *getHardAddition(NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    //Assigns each value to a number along one of two normal distributions with a mean of 40
    for (int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(10) > 3) {
                do {
                    questionValues[i][0] = ItoN(getWeightedRandom(40, 40));
                } while (NtoI(questionValues[i][0]) > 40 || NtoI(questionValues[i][0]) < 5);
            } else {
                do {
                    questionValues[i][0] = ItoN(getWeightedRandom(40, 15));
                } while (NtoI(questionValues[i][0]) <= 40);
            }
            if (arc4random_uniform(10) > 3) {
                do {
                    questionValues[i][1] = ItoN(getWeightedRandom(40, 40));
                } while (NtoI(questionValues[i][1]) > 40 || NtoI(questionValues[i][1]) < 5);
            } else {
                do {
                    questionValues[i][1] = ItoN(getWeightedRandom(40, 15));
                } while (NtoI(questionValues[i][1]) <= 40);
            }
        } while (checkExists(questionValues, i, numQuestions/10));
        questionValues[i][2] = ItoN(NtoI(questionValues[i][0]) + NtoI(questionValues[i][1]));
    }
    return questionValues;
}

NSArray *getExpertAddition(NSInteger numQuestions)
{
    NSInteger mean = 750;
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    //Assigns each value to a number along one of two normal distributions with a mean of 750
    for (int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(1000) > 1) {
                do {
                    questionValues[i][0] = ItoN(getWeightedRandom(mean, 500));
                } while (NtoI(questionValues[i][0]) > mean || NtoI(questionValues[i][0]) < 50);
            } else {
                do {
                    questionValues[i][0] = ItoN(getWeightedRandom(mean, 40));
                } while (NtoI(questionValues[i][0]) <= mean);
            }
            
            if (arc4random_uniform(1000) > 1) {
                do {
                    questionValues[i][1] = ItoN(getWeightedRandom(mean, 500));
                } while (NtoI(questionValues[i][1]) > mean || NtoI(questionValues[i][1]) < 50);
            } else {
                do {
                    questionValues[i][1] = ItoN(getWeightedRandom(mean, 40));
                } while (NtoI(questionValues[i][1]) <= mean);
            }
        } while (checkExists(questionValues, i, 0) || (NtoI(questionValues[i][0]) + NtoI(questionValues[i][1]) > 999));
        questionValues[i][2] = ItoN(NtoI(questionValues[i][0]) + NtoI(questionValues[i][1]));
    }
    return questionValues;
}

NSArray *getEasySubtraction(NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    NSInteger firstNum;
    NSInteger secondNum;
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    for(int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(2) == 0) {
                firstNum = arc4random_uniform(10) + 1;
                secondNum = arc4random_uniform(10) + 1;
            } else {
                firstNum = arc4random_uniform(11);
                secondNum = arc4random_uniform(11);
            }
        } while (checkExistsRepeats(questionValues, i, firstNum, secondNum, numQuestions / 7));
        
        questionValues[i][0] = ItoN(firstNum + secondNum);
        questionValues[i][1] = ItoN(firstNum);
        questionValues[i][2] = ItoN(secondNum);
    }
    return questionValues;
}

NSArray *getMediumSubtraction(NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    NSInteger firstNum;
    NSInteger secondNum;
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    for (int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(10) > 2) {
                do {
                    firstNum = getWeightedRandom(15, 6);
                } while (firstNum > 15 || firstNum < 5);
            } else {
                do {
                    firstNum = getWeightedRandom(15, 4);
                } while (firstNum <= 15);
            }
            if (arc4random_uniform(10) > 2) {
                do {
                    secondNum = getWeightedRandom(15, 6);
                } while (secondNum > 15 || secondNum < 5);
            } else {
                do {
                    secondNum = getWeightedRandom(15, 4);
                } while (secondNum <= 15);
            }
        } while (checkExistsRepeats(questionValues, i, firstNum, secondNum, numQuestions/10));
        
        questionValues[i][0] = ItoN(firstNum + secondNum);
        questionValues[i][1] = ItoN(firstNum);
        questionValues[i][2] = ItoN(secondNum);
    }
    return questionValues;
}

NSArray *getHardSubtraction(NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    NSInteger firstNum;
    NSInteger secondNum;
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    for (int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(10) > 2) {
                do {
                    firstNum = getWeightedRandom(50, 35);
                } while (firstNum > 50 || firstNum < 5);
            } else {
                do {
                    firstNum = getWeightedRandom(50, 10);
                } while (firstNum <= 50);
            }
            if (arc4random_uniform(10) > 2) {
                do {
                    secondNum = getWeightedRandom(50, 35);
                } while (secondNum > 50 || secondNum < 5);
            } else {
                do {
                    secondNum = getWeightedRandom(50, 10);
                } while (secondNum <= 50);
            }
            
        } while (checkExistsRepeats(questionValues, i, firstNum, secondNum, numQuestions/10));
        
        questionValues[i][0] = ItoN(firstNum + secondNum);
        questionValues[i][1] = ItoN(firstNum);
        questionValues[i][2] = ItoN(secondNum);
    }
    return questionValues;
}

NSArray *getExpertSubtraction(NSInteger numQuestions)
{
    NSInteger mean = 750;
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    NSInteger firstNum;
    NSInteger secondNum;
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    for (int i = 0; i < numQuestions; i++) {
        do {
            if (arc4random_uniform(1000) > 1) {
                do {
                    firstNum = getWeightedRandom(mean, 500);
                } while (firstNum > mean || firstNum < 50);
            } else {
                do {
                    firstNum = getWeightedRandom(mean, 40);
                } while (firstNum <= mean);
            }
            if (arc4random_uniform(1000) > 1) {
                do {
                    secondNum = getWeightedRandom(mean, 500);
                } while (secondNum > mean || secondNum < 50);
            } else {
                do {
                    secondNum = getWeightedRandom(mean, 40);
                } while (secondNum <= mean);
            }
        } while (checkExistsRepeats(questionValues, i, firstNum, secondNum, 0) || (firstNum + secondNum > 999));
        
        questionValues[i][0] = ItoN(firstNum + secondNum);
        questionValues[i][1] = ItoN(firstNum);
        questionValues[i][2] = ItoN(secondNum);
    }
    return questionValues;
}

NSArray *getMultiplicationRandy(NSInteger level, NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    NSInteger firstNum;
    NSInteger secondNum;
    NSInteger repeats = numQuestions / 12;
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    //Assigns values to any random number between 2 and 12
    if(level == 13) {
        for (int i = 0; i < numQuestions; i++) {
            do {
                firstNum = arc4random_uniform(11) + 2;
                secondNum = arc4random_uniform(11) + 2;
            } while (checkExistsRepeats(questionValues, i, firstNum, secondNum, repeats));
            
            questionValues[i][0] = ItoN(firstNum);
            questionValues[i][1] = ItoN(secondNum);
            questionValues[i][2] = ItoN(firstNum * secondNum);
        }
    } else {
        //Otherwise assigns one number to the passed in multiplier and the other to a random
        //between 0 and 12, slightly less likely to be 0
        for (int i = 0; i < numQuestions; i++) {
            do {
                if (arc4random_uniform(2) == 0) {
                    firstNum = level;
                    
                    if (arc4random_uniform(10) > 1)
                        secondNum = arc4random_uniform(11) + 2;
                    else
                        secondNum = arc4random_uniform(13);
                } else {
                    if (arc4random_uniform(10) > 1)
                        firstNum = arc4random_uniform(11) + 2;
                    else
                        firstNum = arc4random_uniform(13);
                    
                    secondNum = level;
                }
                
            } while (checkExistsRepeats(questionValues, i, firstNum, secondNum, repeats));
            
            questionValues[i][0] = ItoN(firstNum);
            questionValues[i][1] = ItoN(secondNum);
            questionValues[i][2] = ItoN(firstNum * secondNum);
        }
    }
    return questionValues;
}

NSArray *getDivisionRandy(NSInteger level, NSInteger numQuestions)
{
    NSMutableArray *questionValues = [[NSMutableArray alloc] init];
    NSInteger firstNum;
    NSInteger secondNum;
    NSInteger repeats = numQuestions / 12;
    
    for (int i = 0; i < numQuestions; i++) {
        NSInteger firstNum = 0;
        NSInteger secondNum = 0;
        NSInteger answer = 0;
        
        NSMutableArray *a = [NSMutableArray arrayWithObjects:ItoN(firstNum), ItoN(secondNum), ItoN(answer), nil];
        [questionValues addObject:a];
    }
    
    if(level == 13) {
        for (int i = 0; i < numQuestions; i++) {
            do {
                firstNum = arc4random_uniform(11) + 2;
                secondNum = arc4random_uniform(11) + 2;
            } while (checkExistsRepeats(questionValues, i, firstNum * secondNum, secondNum, repeats));
            
            questionValues[i][0] = ItoN(firstNum * secondNum);
            questionValues[i][1] = ItoN(secondNum);
            questionValues[i][2] = ItoN(firstNum);
        }
    } else {
        for (int i = 0; i < numQuestions; i++) {
            do {
                secondNum = level;
                
                if (arc4random_uniform(10) > 1)
                    firstNum = arc4random_uniform(11) + 2;
                else
                    firstNum = arc4random_uniform(12) + 1;
                
            } while (checkExistsRepeats(questionValues, i, firstNum * secondNum, secondNum, repeats));
            
            questionValues[i][0] = ItoN(firstNum * secondNum);
            questionValues[i][1] = ItoN(secondNum);
            questionValues[i][2] = ItoN(firstNum);
        }
    }
    return questionValues;
}

#pragma mark Custom getters

- (NSArray *)cardStore
{
    return self.privateCardStore;
}

- (NSArray *)testStore
{
    return self.privateTestStore;
}

- (NSArray *)todaysTests
{
    return self.privateTodaysTests;
}

@end
