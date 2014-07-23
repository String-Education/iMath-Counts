//
//  RIPSettingsManager.m
//  MathCounts
//
//  Created by Nick Stanley on 7/18/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPSettingsManager.h"

@interface RIPSettingsManager ()

@end

@implementation RIPSettingsManager

+ (instancetype)sharedManager
{
    static RIPSettingsManager *sharedManager = nil;
    
    //Creates thread-safe singleton
    static dispatch_once_t token;
    dispatch_once(&token, ^{ sharedManager = [[self alloc] initPrivate]; });
    return sharedManager;
}

- (instancetype)initPrivate
{
    //Private init method
    self = [super init];
    if (self) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self settingsArchivePath]])
            self = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingsArchivePath]];
    }
    return self;
}

- (instancetype)init
{
    //Throws an exception and corrects the user on what to do
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use + [RIPSettingsManager sharedManager]"
                                 userInfo:nil];
    return nil;
}

- (NSString *)settingsArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories[0];
    return [documentDirectory stringByAppendingPathComponent:@"settings.archive"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _dropboxEnabled = [aDecoder decodeBoolForKey:@"dropboxEnabled"];
        _passwordEnabled = [aDecoder decodeBoolForKey:@"passwordEnabled"];
        _password = [aDecoder decodeObjectForKey:@"password"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.dropboxEnabled forKey:@"dropboxEnabled"];
    [aCoder encodeBool:self.passwordEnabled forKey:@"passwordEnabled"];
    [aCoder encodeObject:self.password forKey:@"password"];
}

- (BOOL)saveSettings
{
    return [NSKeyedArchiver archiveRootObject:self toFile:[self settingsArchivePath]];
}

@end
