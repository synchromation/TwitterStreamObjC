//
//  SYNTweetBuffer.m
//  SYNTwitterStream
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

#import "SYNConstants.h"
#import "SYNTweet.h"
#import "SYNTweetBuffer.h"

@interface SYNTweetBuffer () 

@property (nonatomic) NSMutableArray *tweetArray;

@end



@implementation SYNTweetBuffer

/**
 *  Singleton instance
 *
 *  @return instance of SYNTweetBuffer
 */

+ (instancetype) sharedInstance
{
    static SYNTweetBuffer *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}


/**
 *  Initialise the tweet buffer by allocating the mutable array required for storage
 *
 *  @return Initialised buffer instance
 */

- (instancetype) init
{
    if ((self = [super init]))
    {
        // As we don't yet have the contents of the array to initialise it with, we need to either fill it with NSNull or use a mutable array (as used here)
        self.tweetArray = [[NSMutableArray alloc] initWithCapacity: kTweetBufferSize];
    }
    
    return self;
}


/**
 *  Required to reset the buffer between tests
 */

- (void) clear
{
    [self.tweetArray removeAllObjects];
}


/**
 *  Add a tweet into the buffer, in order, and truncate the number of entries in the buffer to ensure that there are no more than kTweetBufferSize entries. Messages from the Streaming API are not delivered in sorted order. Instead, they are usually delivered within a few seconds of a total ordering (perhaps another approach would be to have a larger buffer and only return the most recent 10, but this approach should be sufficient for the test			
 *
 *  @param tweet The tweet to be added
 */

- (void) addTweet: (SYNTweet *) tweet
{
    // Sort on the id_str field
    NSComparator comparator =  ^(SYNTweet *tweet1, SYNTweet *tweet2) {
        return [tweet2.idStr compare: tweet1.idStr];
    };
    
    // Find out where to insert the object (using fast binary search)
    NSUInteger insertionIndex = [self.tweetArray indexOfObject: tweet
                                                 inSortedRange: (NSRange) { 0, self.tweetArray.count}
                                                       options: NSBinarySearchingInsertionIndex
                                               usingComparator: comparator];

    // And insert it.  We should now have preserved the ordering of the array
    [self.tweetArray insertObject: tweet
                          atIndex: insertionIndex];
    
    if (self.tweetArray.count > kTweetBufferSize)
    {
        [self.tweetArray removeLastObject];
    }
}


/**
 *  An array of the kTweetBufferSize (or less) most recent tweets
 *
 *  @return An NSArray of SYNTweets
 */

- (NSArray *) recentTweets
{
    return [NSArray arrayWithArray: self.tweetArray];
}





@end
