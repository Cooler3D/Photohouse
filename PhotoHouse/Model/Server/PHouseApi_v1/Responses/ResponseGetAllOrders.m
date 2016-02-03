//
//  ResponseGetAllOrders.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetAllOrders.h"


#import "HistoryOrder.h"
#import "PersonOrderInfo.h"

@implementation ResponseGetAllOrders
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

    
    
    // Parse
//    NSMutableArray *all = [NSMutableArray array];
//    NSArray *arrayOrders = [parseObject objectForKey:@"orders"];
//    for (NSDictionary *order in arrayOrders) {
//        NSArray *order_items = [order objectForKey:@"order_items"];
//        NSDictionary *order_info = [order objectForKey:@"order_info"];
//        
//        HistoryOrder *historyOrder = [[HistoryOrder alloc] initWithOrderInfo:order_info andOrderItems:order_items];
//        [all addObject:historyOrder];
//    }
//
//    _all_orders = [all copy];
}
@end
