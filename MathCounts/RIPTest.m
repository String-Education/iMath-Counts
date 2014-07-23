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
    //Initializes test and generates an .xls document if Dropbox option is enabled
    RIPTest *t = [[RIPTest alloc] initPrivate];
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        dispatch_queue_t uploader = dispatch_queue_create("backgroundUploader", NULL);
        dispatch_async(uploader, ^{
            [t generateXLS];
            DBPath *testPath = [[DBPath root] childPath:[t XLSName]];
            //DBError *error = [[DBError alloc] init];
            DBFile *test = [[DBFilesystem sharedFilesystem] createFile:testPath error:nil];
            [test writeContentsOfFile:[t XLSPath] shouldSteal:YES error:nil];});
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

- (NSString *)XLSName
{
    NSDateFormatter *dateFormatter;
    NSString *dateTaken;
    
    //@"yyyy-MM-dd '@' hh/mm/ss a"
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd '@' hh/mm/ss a"];
    dateTaken = [dateFormatter stringFromDate:self.dateTaken];
    return [NSString stringWithFormat:@"%@ %@.xls", self.name, self.dateTaken];
}

- (NSString *)XLSPath
{
    
    NSString *documentName;
    
    
    documentName = [self XLSName];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:documentName];
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

- (void)generateXLS
{
    JXLSCell *cell;
    NSString *difficulty;
    double percentCorrect;
    
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
    cell = [workSheet setCellAtRow:1 column:0 toString:[NSString stringWithFormat:@"%@", self.name]];
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
    cell = [workSheet setCellAtRow:1 column:1 toString:[NSString stringWithFormat:@"%@", difficulty]];
    [cell setHorizontalAlignment:HALIGN_CENTER];
    [cell setFontHeight:160];
    
    //Displays test operation
    cell = [workSheet setCellAtRow:1 column:2 toString:[NSString stringWithFormat:@"%@", self.operation]];
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
        cell = [workSheet setCellAtRow:1 column:3 toString:[NSString stringWithFormat:@"%d", self.time]];
        [cell setHorizontalAlignment:HALIGN_CENTER];
        [cell setFontHeight:160];
        
        cell = [workSheet setCellAtRow:1 column:4 toString:[NSString stringWithFormat:@"%d", self.timeRemaining]];
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
