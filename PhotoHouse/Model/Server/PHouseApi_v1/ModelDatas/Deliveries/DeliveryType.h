//
//  DeliveryType.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeliveryType : NSObject
- (id) initDeliveryTypeDictionary:(NSDictionary *)dictionary andDictionaryPayments:(NSDictionary *)payments;
- (id) initWithType:(NSString *)type andDescription:(NSString *)description andCode:(NSString *)code andCost:(NSInteger)cost andPayments:(NSArray *)payments;

@property (strong, nonatomic, readonly) NSString *type;
@property (strong, nonatomic, readonly) NSString *deldescription;
@property (strong, nonatomic, readonly) NSString *code;
@property (assign, nonatomic, readonly) NSInteger cost;
@property (strong, nonatomic, readonly) NSArray *payments;
@end
