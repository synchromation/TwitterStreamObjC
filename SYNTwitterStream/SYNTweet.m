//
//  SYNTweet.m
//  SYNTwitterStream
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

#import "SYNTweet.h"
#import "NSDictionary+Defaults.h"

@interface SYNTweet ()

@property (nonatomic) NSDate *createdAt;
@property (nonatomic) NSString *idStr;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *screenName;
@property (nonatomic) NSURL *profileImageURL;

@end


@implementation SYNTweet

+ (NSDateFormatter *) dateFormatter
{
    // Set up Date formatter for tweet (ensuring that we do this only once)
    // Should be in the format ... "created_at": "Sun Nov 02 23:13:53 +0000 2014"
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US_POSIX"];
        dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    });
    
    return dateFormatter;
}


/**
 *  Return an instance that has been intialised with data contatined in the JSON dictionary
 *
 *  @param dictionary JSON dictionary representing a tweet
 *
 *  @return Initialised instance
 */

- (instancetype) initWithDictionary: (NSDictionary *) dictionary
{
    if ((self = [super init]))
    {
        // Eample tweet JSON capured from stream using the tools provided by twitter
        
        //    {
        //        "created_at": "Mon Nov 03 23:13:53 +0000 2014",
        //        "id_str": "529048781309100034",
        //        "text": "Job Opportunity! Head Compliance, Private Banking (Malaysia) (TRC/1012) in Singapore, Singapore http://t.co/nY5tsnB901 #job",
        //        "user": {
        //            "name": "matt beath",
        //            "screen_name": "beathchapman",
        //            "profile_image_url": "http://pbs.twimg.com/profile_images/378800000327376400/206f05515c45496c4327740f7ddb823d_normal.jpeg",
        //        }
        //    }
        
        // First parse the easy values
        self.idStr = [dictionary objectForKeyPath: @"id_str"
                                      withDefault: @"Unknown Id"];
        
        self.text = [dictionary objectForKeyPath: @"text"
                                      withDefault: @"No Content"];
        
        self.name = [dictionary objectForKeyPath: @"user.name"
                                      withDefault: @"Unknown Name"];
        
        self.screenName = [dictionary objectForKeyPath: @"user.screen_name"
                                      withDefault: @"Unknown Screen Name"];
        
        // Now the values that require post-processing
        NSString *profileImageURLString = [dictionary objectForKeyPath: @"user.profile_image_url"
                                                           withDefault: @"http://localhost"];
        
        self.profileImageURL = [NSURL URLWithString: profileImageURLString];
        
        NSString *createdAtString = [dictionary objectForKeyPath: @"created_at"
                                                     withDefault: @"Mon Nov 03 23:13:53 +0000 2014"];
        
        self.createdAt = [SYNTweet.dateFormatter dateFromString: createdAtString];
    }
    
    return self;
}


/**
 *  Used for tests only.  Creates a tweet from string values
 *
 *  @param idStr           Id String
 *  @param createdAt       createdAt date string
 *  @param text            text string
 *  @param name            name string
 *  @param screenName      screenName string
 *  @param profileImageURL profileImageURL string
 *
 *  @return <#return value description#>
 */

- (instancetype) initWithIdStr: (NSString *) idStr
                     createdAt: (NSString *) createdAt
                          text: (NSString *) text
                          name: (NSString *) name
                    screenName: (NSString *) screenName
               profileImageURL: (NSString *) profileImageURL
{
    // First parse the easy values
    self.idStr = idStr;
    self.text = @"Fake";
    self.name = @"Fake";
    self.screenName = @"Fake";
    self.profileImageURL = [NSURL URLWithString: profileImageURL];
    self.createdAt = [SYNTweet.dateFormatter dateFromString: createdAt];
    
    return self;
}

@end
