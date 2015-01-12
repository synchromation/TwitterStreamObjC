//
//  NSDictionary+Defaults.m
//  SYNTwitterStream
//
//  Created by Nick Banks on 03/11/2014.
//  Copyright (c) 2014 Synchromation. All rights reserved.
//

#import "NSDictionary+Defaults.h"

@implementation NSDictionary (Defaults)

/**
 *  Traverses a set of nested dictionaries using a keypath.  If a match is not found, then the default value is used.  Note, this also checks to see that the value is the same type of object as the default (as an extra check)
 *
 *  @param keyPath      KeyPath String
 *  @param defaultValue Default value
 *
 *  @return Either the value found, or the default (if not found)
 */

- (id) objectForKeyPath: (id) keyPath
            withDefault: (id) defaultValue
{
    id value = [self valueForKeyPath: keyPath];
    
    // Use the default if we don't have an entry for the key, the entry is NSNull or the object class differs from the
    // class of the default object
    if (value == nil || [value isEqual: NSNull.null] || ![defaultValue isKindOfClass: [value class]])
    {
        value = defaultValue;
    }
    
    return value;
}

@end
