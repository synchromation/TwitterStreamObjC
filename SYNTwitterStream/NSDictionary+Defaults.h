//
//  NSDictionary+Defaults.h
//  SYNTwitterStream
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Defaults)

- (id) objectForKeyPath: (id) keyPath
            withDefault: (id) defaultValue;

@end
