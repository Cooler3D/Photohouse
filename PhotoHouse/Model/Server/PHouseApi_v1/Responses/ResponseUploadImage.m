//
//  ResponceUploadImage.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/25/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseUploadImage.h"

@implementation ResponseUploadImage
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
    if (self.error) {
        return;
    }
    
    // Read
    for (NSString *key in result.allKeys) {
        NSDictionary *itemDictionary = [result objectForKey:key];

        if ([itemDictionary isKindOfClass:[NSDictionary class]]) {
            NSString *url = [itemDictionary objectForKey:@"url"];
            _urlImage = url;
        }
    }
}

@end
