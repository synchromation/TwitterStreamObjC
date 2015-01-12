//
//  NetworkManager.h
//  SYNTwitterStream
//
//  Created by Nick Banks on 04/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

@import Foundation;

extern NSString * const SYNNetworkConnectingNotification;
extern NSString * const SYNNetworkConnectedNotification;
extern NSString * const SYNTweetsUpdatedNotification;

@interface SYNNetworkManager : NSObject

+ (instancetype) sharedInstance;

- (void) startStream;

@end
