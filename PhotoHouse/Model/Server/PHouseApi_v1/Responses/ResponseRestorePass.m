//
//  ResponseRestorePass.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseRestorePass.h"

@implementation ResponseRestorePass
-(id)initWitParseData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}

- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error != nil) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
}

@end
