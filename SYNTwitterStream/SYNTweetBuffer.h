//
//  SYNTweetBuffer.h
//  SYNTwitterStream
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

@import Foundation;

@class SYNTweet;

@interface SYNTweetBuffer : NSObject

+ (instancetype) sharedInstance;

- (void) addTweet: (SYNTweet *) tweet;
- (NSArray *) recentTweets;
- (void) clear;

@end
