//
//  SYNTwitterStreamTests.m
//  SYNTwitterStreamTests
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

@import UIKit;
@import XCTest;
#import "SYNTweetBuffer.h"
#import "SYNTweet.h"
#import "SYNConstants.h"

@interface SYNTweetBufferTests : XCTestCase

@end


@implementation SYNTweetBufferTests

- (void) setUp
{
    [super setUp];
}

/**
 *  Test for empty buffer.  Check it returns an empty NSArray
 */

- (void) testEmptyBuffer
{
    // Reset tweet buffer
    [SYNTweetBuffer.sharedInstance clear];
    
    // Check to see that it can be created
    XCTAssertNotNil(SYNTweetBuffer.sharedInstance, @"SYNCircularTweetBuffer instance not created");
    
    // Make sure that most recent tweets returns something
    XCTAssertNotNil(SYNTweetBuffer.sharedInstance.recentTweets, @"SYNCircularTweetBuffer mostRecentTweets returns nil when empty");
    
    // Check to see that it returns an NSArray
    XCTAssertTrue([SYNTweetBuffer.sharedInstance.recentTweets isKindOfClass: NSArray.class], @"SYNCircularTweetBuffer mostRecentTweets does not return NSArray when empty");
    
    // Check to see that the array is empty
    XCTAssertEqual(SYNTweetBuffer.sharedInstance.recentTweets.count, 0, @"SYNCircularTweetBuffer mostRecentTweets returns unexpected tweets");
}


/**
 *  When a buffer has a single entry, check that it is the only value returned.
 */

- (void) testPartialBuffer
{
    // Reset tweet buffer
    [SYNTweetBuffer.sharedInstance clear];
    
    // Add a single tweet (boundary condition)
    SYNTweet *tweet = [self createTweetWithIndex: 1];
    [SYNTweetBuffer.sharedInstance addTweet: tweet];
    
    // Check to see that the array has one tweet
    XCTAssertEqual(SYNTweetBuffer.sharedInstance.recentTweets.count, 1, @"SYNCircularTweetBuffer mostRecentTweets returns unexpected number of tweets");
    
    // Check to see that the tweet has the expected id
    NSString *idStr = ((SYNTweet *)SYNTweetBuffer.sharedInstance.recentTweets[0]).idStr;
    XCTAssertEqualObjects(idStr, @"01", @"SYNCircularTweetBuffer mostRecentTweets returns wrong tweet index");
}


/**
 *  Test for the case when the number of tweets added is exactly kTweetBufferSize, and the tweets are added in order of ascending id
 */

- (void) testFullBufferAscendingCount
{
    // Reset tweet buffer
    [SYNTweetBuffer.sharedInstance clear];
    
    // Add kTweetBufferSize tweets
    for (NSUInteger i = 0; i < kTweetBufferSize; i++)
    {
        SYNTweet *tweet = [self createTweetWithIndex: i];
        [SYNTweetBuffer.sharedInstance addTweet: tweet];
    }
    
    // Check to see that the array has kTweetBufferSize tweets
    XCTAssertEqual(SYNTweetBuffer.sharedInstance.recentTweets.count, kTweetBufferSize, @"SYNCircularTweetBuffer mostRecentTweets returns unexpected number of tweets");
    
    // Now test to see that they are in the right order (highest number first)
    for (NSUInteger i = 0; i < kTweetBufferSize; i++)
    {
        NSString *idStr = ((SYNTweet *)SYNTweetBuffer.sharedInstance.recentTweets[i]).idStr;
        NSString *idStr2 = [NSString stringWithFormat: @"%02ld", kTweetBufferSize - i - 1];
        XCTAssertEqualObjects(idStr, idStr2, @"SYNCircularTweetBuffer mostRecentTweets returns wrong tweet index");
    }
}


/**
 *  Test for the case when the number of tweets added is exactly kTweetBufferSize, and the tweets are added in order of descending id
 */

- (void) testFullBufferDescendingCount
{
    // Reset tweet buffer
    [SYNTweetBuffer.sharedInstance clear];
    
    // Add kTweetBufferSize tweets
    for (NSUInteger i = 0; i < kTweetBufferSize; i++)
    {
        SYNTweet *tweet = [self createTweetWithIndex: kTweetBufferSize - i - 1];
        [SYNTweetBuffer.sharedInstance addTweet: tweet];
    }
    
    // Check to see that the array has kTweetBufferSize tweets
    XCTAssertEqual(SYNTweetBuffer.sharedInstance.recentTweets.count, kTweetBufferSize, @"SYNCircularTweetBuffer mostRecentTweets returns unexpected number of tweets");
    
    // Now test to see that they are in the right order
    for (NSUInteger i = 0; i < kTweetBufferSize; i++)
    {
        NSString *idStr = ((SYNTweet *)SYNTweetBuffer.sharedInstance.recentTweets[i]).idStr;
        NSString *idStr2 = [NSString stringWithFormat: @"%02ld", kTweetBufferSize - i - 1];
        XCTAssertEqualObjects(idStr, idStr2, @"SYNCircularTweetBuffer mostRecentTweets returns wrong tweet index");
    }
}


/**
 *  Test for the case when the number of tweets exceeds kTweetBufferSize, and the tweets are added in order of ascending id
 */

- (void) testOverflowBufferAscendingCount
{
    // Reset tweet buffer
    [SYNTweetBuffer.sharedInstance clear];
    
    // Add kTweetBufferSize tweets
    for (NSUInteger i = 0; i < (kTweetBufferSize * 2); i++)
    {
        SYNTweet *tweet = [self createTweetWithIndex: i];
        [SYNTweetBuffer.sharedInstance addTweet: tweet];
    }
    
    // Check to see that the array has kTweetBufferSize tweets
    XCTAssertEqual(SYNTweetBuffer.sharedInstance.recentTweets.count, kTweetBufferSize, @"SYNCircularTweetBuffer mostRecentTweets returns unexpected number of tweets");
    
    // Now test to see that they are in the right order (highest number first)
    for (NSUInteger i = 0; i < kTweetBufferSize; i++)
    {
        NSString *idStr = ((SYNTweet *)SYNTweetBuffer.sharedInstance.recentTweets[i]).idStr;
        NSString *idStr2 = [NSString stringWithFormat: @"%02ld", (kTweetBufferSize * 2) - i - 1];
        XCTAssertEqualObjects(idStr, idStr2, @"SYNCircularTweetBuffer mostRecentTweets returns wrong tweet index");
    }
}


/**
 *  Test for the case when the number of tweets exceeds kTweetBufferSize, and the tweets are added in order of descending id
 */

- (void) testOverflowBufferDescendingCount
{
    // Reset tweet buffer
    [SYNTweetBuffer.sharedInstance clear];
    
    // Add kTweetBufferSize tweets
    for (NSUInteger i = 0; i < (kTweetBufferSize * 2); i++)
    {
        SYNTweet *tweet = [self createTweetWithIndex: (kTweetBufferSize * 2) - i - 1];
        [SYNTweetBuffer.sharedInstance addTweet: tweet];
    }
    
    // Check to see that the array has kTweetBufferSize tweets
    XCTAssertEqual(SYNTweetBuffer.sharedInstance.recentTweets.count, kTweetBufferSize, @"SYNCircularTweetBuffer mostRecentTweets returns unexpected number of tweets");
    
    // Now test to see that they are in the right order
    for (NSUInteger i = 0; i < kTweetBufferSize; i++)
    {
        NSString *idStr = ((SYNTweet *)SYNTweetBuffer.sharedInstance.recentTweets[i]).idStr;
        NSString *idStr2 = [NSString stringWithFormat: @"%02ld", (kTweetBufferSize * 2) - i - 1];
        XCTAssertEqualObjects(idStr, idStr2, @"SYNCircularTweetBuffer mostRecentTweets returns wrong tweet index");
    }
}

/**
 *  Helper function to create a tweet with a numberic id
 *
 *  @param index Numeric Id
 *
 *  @return Initialised tweet
 */

- (SYNTweet *) createTweetWithIndex: (NSUInteger) index
{
    SYNTweet *tweet = [[SYNTweet alloc] initWithIdStr: [NSString stringWithFormat: @"%02ld", index]
                                            createdAt: @"Mon Nov 03 23:13:53 +0000 2014"
                                                 text: @"Random text"
                                                 name: @"Random name"
                                           screenName: @"Random screen name"
                                      profileImageURL: @"http://localhost"];
    
    return tweet;
}

@end
