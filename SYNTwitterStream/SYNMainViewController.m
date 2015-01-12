//
//  ViewController.m
//  SYNTwitterStream
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

#import "SYNConstants.h"
#import "SYNMainViewController.h"
#import "SYNNetworkManager.h"
#import "SYNTweet.h"
#import "SYNTweetBuffer.h"

@interface SYNMainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, atomic) IBOutlet UITableView *tableView;
@property (weak, atomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SYNMainViewController

#pragma mark - Object lifecycle

- (void) dealloc
{
    // Unregister for all notifications
    [self unregisterNotifications];
}


#pragma mark - View lifecycle

/**
 *  Reister for notifications and start the stream parser
 */

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Register for our UI update notifications
    [self registerNotifications];
    
    // Start up the network manager, which in turn will start parsing the stream
    [SYNNetworkManager.sharedInstance startStream];
}


#pragma mark - Notifications

/**
 *  Register notificaiton for tweet updates and connection spinner
 */

- (void) registerNotifications
{
    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(showActivityIndicator)
                                               name: SYNNetworkConnectingNotification
                                             object: nil];
    
    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(hideActivityIndicator)
                                               name: SYNNetworkConnectedNotification
                                             object: nil];
    
    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(updateTweets)
                                               name: SYNTweetsUpdatedNotification
                                             object: nil];
}


/**
 *  Remove all notification observers
 */

- (void) unregisterNotifications
{
    // Remove all our observers
    [NSNotificationCenter.defaultCenter removeObserver: self];
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return SYNTweetBuffer.sharedInstance.recentTweets.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static NSString *TweetCellIdentifier = @"TweetCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: TweetCellIdentifier];
    
    SYNTweet *tweet = SYNTweetBuffer.sharedInstance.recentTweets[indexPath.row];
    
    // Update the labels in our field
    UILabel *screenNameLabel = (UILabel *)[cell viewWithTag: 1];
    screenNameLabel.text = tweet.screenName;
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag: 2];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString: tweet.text];
    
    // Hightlight our search term
    NSRange highlightRange = [tweet.text rangeOfString: kSearchTerm
                                               options: NSDiacriticInsensitiveSearch | NSCaseInsensitiveSearch];
    
    if (highlightRange.location != NSNotFound)
    {
        [attributedText addAttribute: NSForegroundColorAttributeName
                               value: kColourTwitterBlue
                               range: highlightRange];
    }
    
    textLabel.attributedText = attributedText;
    
    return cell;
}


#pragma mark - UITableViewDelegate

// Nothing required here yet

#pragma mark - Notification callbacks

/**
 *  Reload our table view
 */

- (void) updateTweets
{
    [self.tableView reloadData];
}


/**
 *  Show activity indicator and start spinning
 */

- (void) showActivityIndicator
{
    [self.activityIndicator startAnimating];
}


/**
 *  Hide activity indicator
 */

- (void) hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
}

@end
