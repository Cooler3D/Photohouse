;//
//  ResponseGetItems.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/23/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetItems.h"
#import "StoreItem.h"

#import "CoreDataStore.h"

NSString *const ITEMS_KEY = @"items";

@interface ResponseGetItems ()
@property (strong, nonatomic) NSArray *templates;
@end

@implementation ResponseGetItems
#pragma mark - init
- (id) initWitParseData:(NSData *)data {
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}

-(id)initWitParseData:(NSData *)data andTemplates:(NSArray *)templates
{
    self = [super init];
    if (self) {
        self.templates = templates;
        [self parse:data];
    }
    return self;
}

#pragma mark - private
- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error != nil) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
    NSArray *array = [result objectForKey:@"items"];
    [self readItems:array];
}


- (void) readItems:(NSArray *)items {
    //
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *item in items) {
//        NSDictionary *item = [dictionary objectForKey:key];
        if ([item isKindOfClass:[NSDictionary class]]) {
            StoreItem *it = [[StoreItem alloc] initWithDictionary:item];
            [array addObject:it];
        }
    }
    
    _stories = [array copy];
    
    // Save To CoreData
    CoreDataStore *store = [[CoreDataStore alloc] init];
    [store saveStoreArray:_stories andTemplates:_templates];
}
@end
