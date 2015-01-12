//
//  SYNTweet.h
//  SYNTwitterStream
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNTweet : NSObject

@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) NSString *idStr;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *screenName;
@property (nonatomic, readonly) NSURL *profileImageURL;

// For parsing support
- (instancetype) initWithDictionary: (NSDictionary *) dictionary;

// For testing only
- (instancetype) initWithIdStr: (NSString *) idStr
                     createdAt: (NSString *) createdAt
                          text: (NSString *) text
                          name: (NSString *) name
                    screenName: (NSString *) screenName
               profileImageURL: (NSString *) profileImageURL;

@end
