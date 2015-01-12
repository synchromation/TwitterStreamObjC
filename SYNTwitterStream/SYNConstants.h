//
//  SYNConstants.h
//  SYNTwitterStream
//
//  Created by Nick Banks on 04/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

// Search term
#define kSearchTerm @"Hotel"

// How many tweets to buffer (and show)
#define kTweetBufferSize 10

// The streaming endpoint to use
#define kTwitterStreamAPIEndpoint @"https://stream.twitter.com/1.1/statuses/filter.json"

// Mimimum time between retries after connection error (based on Twitter recommendation)
#define kConnectionErrorRetryInterval 0.25f

// Mimimum time between retries after connection error (based on Twitter recommendation)
#define kServerErrorRetryInterval 5.0f

#define kColourTwitterBlue [UIColor colorWithRed: 0.349 green: 0.678 blue: 0.921 alpha: 1.0]
