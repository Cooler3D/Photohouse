//
//  ResponsePayOrder.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/01/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "ResponsePayOrder.h"

@implementation ResponsePayOrder
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
