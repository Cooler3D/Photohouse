//
//  ResponseGetCommands.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/15/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetCommands.h"

@implementation ResponseGetCommands
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
    NSDictionary *commands = [result objectForKey:@"commands"];
    for (NSString *key in commands.allKeys) {
        NSLog(@"Commnad: %@ - Value: %@", key, [commands objectForKey:key]);
    }
}

@end
