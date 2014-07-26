//
//  RIPTest.m
//  MathCounts
//
//  Created by Nick Stanley on 7/1/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPTest.h"
#import "RIPDataManager.h"
#import "RIPCard.h"
#import <JXLS/JXLS.h>
#import <Dropbox/Dropbox.h>

@interface RIPTest ()

@property (nonatomic) NSMutableArray *privateCardStore;


@end

@implementation RIPTest

#pragma mark Initializers

+ (instancetype)generateTest
{
    NSString *monthYear;
    NSString *day;
    
    //Initializes test and generates an .xls document if Dropbox option is enabled
    RIPTest *t = [[RIPTest alloc] initPrivate];
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MMMM y"];
    monthYear = [dateFormatter stringFromDate:t.dateTaken];
    
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    day = [dateFormatter stringFromDate:t.dateTaken];
    
    DBPath *monthYearPath = [[DBPath alloc] initWithString:monthYear];
    DBPath *dayPath = [monthYearPath childPath:day];
    
    DBPath *testsPath = [dayPath childPath:@"Tests"];
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        dispatch_queue_t uploader = dispatch_queue_create("backgroundUploader", NULL);
        dispatch_async(uploader, ^{
            DBFile *todaysTests;
            
            [t generateXLS];
            [sharedManager addToTodaysTests:t];
            [t generateTodaysTests];
            DBPath *testPath = [testsPath childPath:[t XLSName]];
            DBPath *todaysTestsPath = [dayPath childPath:[t todaysTestsXLSName]];
            //DBError *error = [[DBError alloc] init];
            if (!todaysTestsPath)
                todaysTests = [[DBFilesystem sharedFilesystem] createFile:todaysTestsPath error:nil];
            else
                todaysTests = [[DBFilesystem sharedFilesystem] openFile:todaysTestsPath error:nil];
            DBFile *test = [[DBFilesystem sharedFilesystem] createFile:testPath error:nil];
            [todaysTests writeContentsOfFile:[t todaysTestsXLSPath] shouldSteal:YES error:nil];
            [test writeContentsOfFile:[t XLSPath] shouldSteal:YES error:nil];
        });
    }
    return t;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        //Copies the current card manager values and creates an NSDate for when the test is completed
        RIPDataManager *sharedManager = [RIPDataManager sharedManager];
        self.operation = sharedManager.operation;
        self.time = sharedManager.time;
        self.timeRemaining = sharedManager.timeRemaining;
        self.difficulty = sharedManager.difficulty;
        self.name = sharedManager.name;
        self.questionsCorrect = 0;
        for (RIPCard *c in sharedManager.cardStore) {
            if (c.isCorrect)
                self.questionsCorrect++;
        }
        self.questionsTotal = sharedManager.cardStore.count;
        self.privateCardStore = [NSMutableArray arrayWithArray:sharedManager.cardStore];
        self.quit = sharedManager.quit;
        self.dateTaken = [NSDate date];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"" reason:@"" userInfo:nil];
}

#pragma mark Encoder methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _operation = [aDecoder decodeObjectForKey:@"operation"];
        _time = [aDecoder decodeIntegerForKey:@"time"];
        _timeRemaining = [aDecoder decodeIntegerForKey:@"timeRemaining"];
        _difficulty = [aDecoder decodeIntegerForKey:@"difficulty"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _questionsCorrect = [aDecoder decodeIntegerForKey:@"questionsCorrect"];
        _questionsTotal = [aDecoder decodeIntegerForKey:@"questionsTotal"];
        _dateTaken = [aDecoder decodeObjectForKey:@"dateTaken"];
        _privateCardStore = [aDecoder decodeObjectForKey:@"cardStore"];
        _quit = [aDecoder decodeBoolForKey:@"quit"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.operation forKey:@"operation"];
    [aCoder encodeInteger:self.time forKey:@"time"];
    [aCoder encodeInteger:self.timeRemaining forKey:@"timeRemaining"];
    [aCoder encodeInteger:self.difficulty forKey:@"difficulty"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.questionsCorrect forKey:@"questionsCorrect"];
    [aCoder encodeInteger:self.questionsTotal forKey:@"questionsTotal"];
    [aCoder encodeObject:self.dateTaken forKey:@"dateTaken"];
    [aCoder encodeObject:self.privateCardStore forKey:@"cardStore"];
    [aCoder encodeBool:self.quit forKey:@"quit"];
}

#pragma mark JXLS methods

- (NSString *)todaysTestsXLSName
{
    return @"Today's Tests.xls";
}

- (NSString *)todaysTestsXLSPath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[self todaysTestsXLSName]];
}

- (NSString *)XLSName
{
    NSDateFormatter *dateFormatter;
    NSString *dateTaken;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd '@' h-mm-ss a"];
    dateTaken = [dateFormatter stringFromDate:self.dateTaken];
    if (self.name && ![self.name isEqualToString:@""])
        return [NSString stringWithFormat:@"%@ %@.xls", self.name, dateTaken];
    else
        return [NSString stringWithFormat:@"%@.xls", dateTaken];
}

- (NSString *)XLSPath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[self XLSName]];
}

- (void)formatCell:(JXLSCell *)cell inWorksheet:(JXLSWorkSheet *)sheet atRow:(uint32_t)row column:(uint32_t)column toHeader:(NSString *)name
{
    //Short method used to quickly format a cell for the header sections in the .xls document
    cell = [sheet setCellAtRow:row column:column toString:name];
    [cell setHorizontalAlignment:HALIGN_CENTER];
    [cell setFontBold:BOLDNESS_BOLD];
    [cell setWraps:YES];
    [cell setFontHeight:160];
}

- (void)generateTodaysTests
{
    JXLSCell *cell;
    NSString *difficulty;
    double percentCorrect;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    NSString *totalTime;
    NSString *timeRemaining;
    
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    JXLSWorkBook *workBook = [JXLSWorkBook new];
    JXLSWorkSheet *workSheet = [workBook workSheetWithName:@"First Sheet"];
    
    [workSheet setHeight:500 forRow:0 defaultFormat:NULL];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:0 toHeader:@"Name"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:1 toHeader:@"Score"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:2 toHeader:@"Difficulty Level"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:3 toHeader:@"Operation"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:4 toHeader:@"Time Allowed"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:5 toHeader:@"Time Remaining"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:6 toHeader:@"Quit?"];
    
    for (uint32_t i = 0; i < sharedManager.todaysTests.count; i++) {
        RIPTest *t = sharedManager.todaysTests[i];
        uint32_t idx = i + 1;
        
        [workSheet setHeight:500 forRow:idx defaultFormat:NULL];
        
        cell = [workSheet setCellAtRow:idx column:0 toString:[NSString stringWithFormat:@"%@", t.name]];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        [cell setWraps:YES];
        
        percentCorrect = ((double)t.questionsCorrect / (double)t.questionsTotal) * 100.0;
        cell = [workSheet setCellAtRow:idx column:1 toString:[NSString stringWithFormat:@"%d/%d (%.02f%%)", t.questionsCorrect, t.questionsTotal, percentCorrect]];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        [cell setWraps:YES];
        
        if ([t.operation isEqualToString:ADDITION] || [t.operation isEqualToString:SUBTRACTION]) {
            switch (self.difficulty) {
                case 1: difficulty = @"Easy"; break;
                case 2: difficulty = @"Medium"; break;
                case 3: difficulty = @"Hard"; break;
                case 4: difficulty = @"Expert"; break;
                default: difficulty = @""; break;
            }
        } else {
            if (t.difficulty == 13)
                difficulty = @"All";
            else
                difficulty = [NSString stringWithFormat:@"%d", t.difficulty];
        }
        cell = [workSheet setCellAtRow:idx column:2 toString:difficulty];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        [cell setWraps:YES];
        
        cell = [workSheet setCellAtRow:idx column:3 toString:t.operation];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        [cell setWraps:YES];

        if (t.time == 0) {
            cell = [workSheet setCellAtRow:idx column:4 toString:@"-"];
            [cell setHorizontalAlignment:HALIGN_CENTER];
            [cell setFontHeight:160];
            [cell setWraps:YES];

            cell = [workSheet setCellAtRow:idx column:5 toString:@"-"];
            [cell setHorizontalAlignment:HALIGN_CENTER];
            [cell setFontHeight:160];
            [cell setWraps:YES];
        } else {
            minutes = t.timeRemaining / 60;
            seconds = t.timeRemaining % 60;
            timeRemaining = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
            minutes = t.time / 60;
            seconds = t.time % 60;
            totalTime = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
            
            cell = [workSheet setCellAtRow:idx column:4 toString:totalTime];
            [cell setHorizontalAlignment:HALIGN_CENTER];
            [cell setFontHeight:160];
            [cell setWraps:YES];

            cell = [workSheet setCellAtRow:idx column:5 toString:timeRemaining];
            [cell setHorizontalAlignment:HALIGN_CENTER];
            [cell setFontHeight:160];
            [cell setWraps:YES];
        }
        
        if (t.quit)
            cell = [workSheet setCellAtRow:idx column:6 toString:@"Yes"];
        else
            cell = [workSheet setCellAtRow:idx column:6 toString:@"No"];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        [cell setWraps:YES];
    }
    
    int success = [workBook writeToFile:[self todaysTestsXLSPath]];
    NSLog(@"success = %d", success);
}

- (void)generateXLS
{
    JXLSCell *cell;
    NSString *difficulty;
    double percentCorrect;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    NSString *totalTime;
    NSString *timeRemaining;
    
    JXLSWorkBook *workBook = [JXLSWorkBook new];
    JXLSWorkSheet *workSheet = [workBook workSheetWithName:@"First Sheet"];
    
    //Formats titles in first row
    [workSheet setHeight:500 forRow:0 defaultFormat:NULL];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:0 toHeader:@"Name"];
    if ([self.operation isEqualToString:MULTIPLICATION])
        [self formatCell:cell inWorksheet:workSheet atRow:0 column:1 toHeader:@"Multiplier"];
    else if ([self.operation isEqualToString:DIVISION])
        [self formatCell:cell inWorksheet:workSheet atRow:0 column:1 toHeader:@"Divisor"];
    else
        [self formatCell:cell inWorksheet:workSheet atRow:0 column:1 toHeader:@"Difficulty Level"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:2 toHeader:@"Operation"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:3 toHeader:@"Time Allowed"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:4 toHeader:@"Time Remaining"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:5 toHeader:@"Score"];
    [self formatCell:cell inWorksheet:workSheet atRow:0 column:6 toHeader:@"Quit?"];
    
    //Displays entered name
    cell = [workSheet setCellAtRow:1 column:0 toString:self.name];
    [cell setHorizontalAlignment:HALIGN_CENTER];
    [cell setFontHeight:160];
    
    //Displays appropriate difficulty/multiplier/divisor
    if ([self.operation isEqualToString:ADDITION] || [self.operation isEqualToString:SUBTRACTION]) {
        switch (self.difficulty) {
            case 1: difficulty = @"Easy"; break;
            case 2: difficulty = @"Medium"; break;
            case 3: difficulty = @"Hard"; break;
            case 4: difficulty = @"Expert"; break;
            default: difficulty = @""; break;
        }
    } else {
        if (self.difficulty == 13)
            difficulty = @"All";
        else
            difficulty = [NSString stringWithFormat:@"%d", self.difficulty];
    }
    cell = [workSheet setCellAtRow:1 column:1 toString:difficulty];
    [cell setHorizontalAlignment:HALIGN_CENTER];
    [cell setFontHeight:160];
    
    //Displays test operation
    cell = [workSheet setCellAtRow:1 column:2 toString:self.operation];
    [cell setHorizontalAlignment:HALIGN_CENTER];
    [cell setFontHeight:160];
    
    //Displays timer if one was set
    if (self.time == 0) {
        cell = [workSheet setCellAtRow:1 column:3 toString:@"-"];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        
        cell = [workSheet setCellAtRow:1 column:4 toString:@"-"];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
    } else {
        minutes = self.timeRemaining / 60;
        seconds = self.timeRemaining % 60;
        timeRemaining = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        minutes = self.time / 60;
        seconds = self.time % 60;
        totalTime = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        cell = [workSheet setCellAtRow:1 column:3 toString:totalTime];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        
        cell = [workSheet setCellAtRow:1 column:4 toString:timeRemaining];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
    }
    
    //Displays score and percent correct
    percentCorrect = ((double)self.questionsCorrect / (double)self.questionsTotal) * 100.0;
    cell = [workSheet setCellAtRow:1 column:5 toString:[NSString stringWithFormat:@"%d/%d (%.02f%%)", self.questionsCorrect, self.questionsTotal, percentCorrect]];
    [cell setHorizontalAlignment:HALIGN_CENTER];
    [cell setFontHeight:160];
    
    //Displays whether or not test was quit
    if (self.quit)
        cell = [workSheet setCellAtRow:1 column:6 toString:@"Yes"];
    else
        cell = [workSheet setCellAtRow:1 column:6 toString:@"No"];
    [cell setHorizontalAlignment:HALIGN_CENTER];
    [cell setFontHeight:160];
    
    //Formats titles in fourth row
    [workSheet setHeight:500 forRow:3 defaultFormat:NULL];
    [self formatCell:cell inWorksheet:workSheet atRow:3 column:0 toHeader:@"Question #"];
    [self formatCell:cell inWorksheet:workSheet atRow:3 column:1 toHeader:@"Question"];
    [self formatCell:cell inWorksheet:workSheet atRow:3 column:2 toHeader:@"Correct Answer"];
    [self formatCell:cell inWorksheet:workSheet atRow:3 column:3 toHeader:@"Student Answer"];
    
    //Generates a row of data for each card
    //If a question is unanswered the row is displayed with a red font
    for (uint32_t i = 0; i < self.cardStore.count; i++) {
        RIPCard *c = self.cardStore[i];
        
        //Displays card number
        cell = [workSheet setCellAtRow:(i + 4) column:0 toString:[NSString stringWithFormat:@"%d", (i + 1)]];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        if (!c.isAnswered)
            [cell setFontColor:COLOR_RED];
        
        //Displays the question on the card
        if ([self.operation isEqualToString:ADDITION])
            cell = [workSheet setCellAtRow:(i + 4) column:1 toString:[NSString stringWithFormat:@"%d + %d", c.firstNum, c.secondNum]];
        else if ([self.operation isEqualToString:SUBTRACTION])
            cell = [workSheet setCellAtRow:(i + 4) column:1 toString:[NSString stringWithFormat:@"%d - %d", c.firstNum, c.secondNum]];
        else if ([self.operation isEqualToString:MULTIPLICATION])
            cell = [workSheet setCellAtRow:(i + 4) column:1 toString:[NSString stringWithFormat:@"%d x %d", c.firstNum, c.secondNum]];
        else if ([self.operation isEqualToString:DIVISION])
            cell = [workSheet setCellAtRow:(i + 4) column:1 toString:[NSString stringWithFormat:@"%d ÷ %d", c.firstNum, c.secondNum]];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        if (!c.isAnswered)
            [cell setFontColor:COLOR_RED];
        
        //Displays the correct answer
        cell = [workSheet setCellAtRow:(i + 4) column:2 toString:[NSString stringWithFormat:@"%d", c.answer]];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        if (!c.isAnswered)
            [cell setFontColor:COLOR_RED];
        
        //Displays the student answer if one is given
        if (c.isAnswered)
            cell = [workSheet setCellAtRow:(i + 4) column:3 toString:[NSString stringWithFormat:@"%d", c.inputAnswer]];
        else
            cell = [workSheet setCellAtRow:(i + 4) column:3 toString:@"-"];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        if (!c.isAnswered)
            [cell setFontColor:COLOR_RED];
    }

    int test = [workBook writeToFile:[self XLSPath]];
    NSLog(@"test = %d", test);
}

#pragma mark Custom getters

- (NSArray *)cardStore
{
    return self.privateCardStore;
}

@end
