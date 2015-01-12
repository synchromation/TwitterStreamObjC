//
//  NetworkManager.m
//  SYNTwitterStream
//
//  Created by Nick Banks on 04/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

@import Social;
@import Accounts;
#import "SYNNetworkManager.h"
#import "SYNConstants.h"
#import "SYNTweet.h"
#import "SYNTweetBuffer.h"

NSString * const SYNNetworkConnectingNotification = @"com.synchromation.connecting";
NSString * const SYNNetworkConnectedNotification =  @"com.synchromation.connected";
NSString * const SYNTweetsUpdatedNotification =  @"com.synchromation.tweetsupdated";

@interface SYNNetworkManager () <NSURLConnectionDataDelegate>

@property (nonatomic) NSMutableString *unprocessedDataString;
@property (nonatomic) NSTimeInterval connectionErrorRetryInterval;
@property (nonatomic) NSTimeInterval serverErrorRetryInterval;

@end


@implementation SYNNetworkManager

/**
 *  Singleton instance
 *
 *  @return instance of NetworkManager
 */

+ (instancetype) sharedInstance
{
    static SYNNetworkManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}


/**
 *  Setup the received data string and retry intervals
 *
 *  @return <#return value description#>
 */

- (instancetype) init
{
    if ((self = [super init]))
    {
        self.unprocessedDataString = [NSMutableString new];
        
        [self resetRetryIntervals];
    }
    
    return self;
}

/**
 *  Get the Twitter authentication details and set up and start the stream decoder
 */

- (void) startStream
{
    // Get twitter account type
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
    
    // Request access to twitter account
    [account requestAccessToAccountsWithType: accountType
                                     options: nil
                                  completion: ^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSArray *accountArray = [account accountsWithAccountType: accountType];
             
             if (accountArray.count > 0)
             {
                 // If we get here, then we have been granted access to the user's twitter accounts, so arbitrarily select the first one
                 ACAccount *twitterAccount = accountArray.firstObject;
                 
                 // URL and paramters
                 NSURL *url = [NSURL URLWithString: kTwitterStreamAPIEndpoint];
                 NSDictionary *params = @{@"track" : kSearchTerm};
                 
                 // Set up our request with the account (and as a POST)
                 SLRequest *request = [SLRequest requestForServiceType: SLServiceTypeTwitter
                                                         requestMethod: SLRequestMethodPOST
                                                                   URL: url
                                                            parameters: params];
                 
                 request.account = twitterAccount;
                 
                 // We are likely to be in a background thread at this point, so ensure that our connection is on the main thread
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     // We are attempting to make a connection
                     [NSNotificationCenter.defaultCenter postNotificationName: SYNNetworkConnectingNotification
                                                                       object: nil];
                     
                     // Create and start the connection.  This seems more compilcated than normal, but it tweaks the connection to be able to run even whilst the user is scrolling
                     NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request.preparedURLRequest
                                                                                   delegate: self
                                                                           startImmediately: NO];

                     [connection scheduleInRunLoop: [NSRunLoop currentRunLoop]
                                           forMode: NSRunLoopCommonModes];

                     [connection start];
                 });
             }
             else
             {
                 // There are no registered twitter accounts for this user
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Authentication", nil)
                                                 message: NSLocalizedString(@"No Twitter accounts found. Please add one in settings", nil)
                                                delegate: nil
                                       cancelButtonTitle: NSLocalizedString(@"I Understand", nil)
                                       otherButtonTitles: nil] show];
                 });
             }
         }
         else
         {
             // The user declined to give the app access to the twitter account
             // There are no registered twitter accounts for this user
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Authentication", nil)
                                             message: NSLocalizedString(@"User denied access to Twitter account", nil)
                                            delegate: nil
                                   cancelButtonTitle: NSLocalizedString(@"I Understand", nil)
                                   otherButtonTitles: nil] show];
             });
         }
     }];
}

#pragma mark - Helper Methods

/**
 *  Called after a successful connection to reset the retry intervals
 */

- (void) resetRetryIntervals
{
    self.connectionErrorRetryInterval = kConnectionErrorRetryInterval;
    self.serverErrorRetryInterval = kServerErrorRetryInterval;
}


#pragma mark - NSURLConnectionDataDelegate

/**
 *  We received a response.  Reset the retry intervals and turn off the spinner
 *
 *  @param connection connection
 *  @param response   response
 */

- (void) connection: (NSURLConnection *) connection
         didReceiveResponse: (NSHTTPURLResponse *) response
{
    // As we have a connection, reset both retry strategy counters
    [self resetRetryIntervals];
    
    // We have a connection
    [NSNotificationCenter.defaultCenter postNotificationName: SYNNetworkConnectedNotification
                                                      object: nil];

}


/**
 *  The connection received data
 *
 *  @param connection The connection
 *  @param data       The data returned
 */

- (void) connection: (NSURLConnection *) connection
     didReceiveData: (NSData *) data
{
    BOOL tweetsUpdated;
    
    NSAssert([NSThread isMainThread], @"Error - should be running on main thread");

    // We can't assume that there will be a whole or integral number of tweets in the received data, so we need to convert to a string first
    NSString *partialDataString = [[NSString alloc] initWithData: data
                                                        encoding: NSUTF8StringEncoding];
    
    // Add add it to any previously unprocessed JSON string data
    [self.unprocessedDataString appendString: partialDataString];
    
    NSRange firstSeparator = [self.unprocessedDataString rangeOfString: @"\r\n"];
    
    while (firstSeparator.location != NSNotFound)
    {
        // Extract the first potential fragment we find
        NSString *fragmentString = [self.unprocessedDataString substringToIndex: firstSeparator.location];
        
        // Only attempt to process if not a black line (sometimes sent to keep the connection alive on some devices)
        if (fragmentString.length > 0)
        {
            // Parse it for a tweet (or'ing in the success value)
            tweetsUpdated |= [self parseFragment: fragmentString];
        }
        
        // Now we need to remove the processed portion of the string (including the separator)
        
        [self.unprocessedDataString deleteCharactersInRange: NSMakeRange(0, firstSeparator.location + firstSeparator.length)];
        
        // Look for the next separator (if any)
        firstSeparator = [self.unprocessedDataString rangeOfString: @"\r\n"];
    }
    
    if (tweetsUpdated)
    {
        [NSNotificationCenter.defaultCenter postNotificationName: SYNTweetsUpdatedNotification
                                                          object: nil];
    }
}


/**
 *  The network connection failed (i.e. the WiFi/Cellular dropped out).  We need to re-start the stream
 *
 *  @param connection <#connection description#>
 *  @param error      <#error description#>
 */

- (void) connection: (NSURLConnection *) connection
   didFailWithError: (NSError *) error
{
    // This will be called when the connection fails (i.e. the mobile connection is lost)
    // Twitter suggests: "Back off linearly for TCP/IP level network errors. These problems are generally temporary and tend to clear quickly.
    // Increase the delay in reconnects by 250ms each attempt, up to 16 seconds."
    
    [self performSelector: @selector(startStream)
               withObject: nil
               afterDelay: self.connectionErrorRetryInterval];
    
    // Lengthen the delay (in case we have to retry again)
    self.connectionErrorRetryInterval += kConnectionErrorRetryInterval;
}


/**
 *  The connection was disconnected by the server. We need to re-start the stream
 *
 *  @param connection <#connection description#>
 */

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    // This will be called when the server returns an error
    // Twitter suggests: "Back off exponentially for HTTP errors for which reconnecting would be appropriate.
    // Start with a 5 second wait, doubling each attempt, up to 320 seconds."
    
    [self performSelector: @selector(startStream)
               withObject: nil
               afterDelay: self.connectionErrorRetryInterval];
    
    self.serverErrorRetryInterval *= 2;
    
    if (self.serverErrorRetryInterval > 320.0f)
    {
        self.serverErrorRetryInterval = 320;
    }
}


/**
 *  Iterate through the array, adding any valid tweets
 */

- (BOOL) parseFragment: (NSString *) fragmentString
{
    BOOL success; // Default to FALSE
    
    NSError *error;
    
    NSData *JSONData = [fragmentString dataUsingEncoding: NSUTF8StringEncoding];
    
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData: JSONData
                                                                   options: 0
                                                                     error: &error];
    if (!error && JSONDictionary)
    {
        SYNTweet *tweet = [[SYNTweet alloc] initWithDictionary: JSONDictionary];

        if (tweet)
        {
            [SYNTweetBuffer.sharedInstance addTweet: tweet];
            success = TRUE;
        }
    }
    else
    {
        NSLog (@"Unable to parse tweet");
    }
    
    return success;
}

@end
