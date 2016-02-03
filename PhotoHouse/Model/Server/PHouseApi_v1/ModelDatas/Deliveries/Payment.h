//
//  Payment.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/16/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject
- (id) initPaymentType:(NSString *)paymentType andDictionaryPayment:(NSDictionary *)payment;
- (id) initPaymentType:(NSString *)paymentType andPaymentName:(NSString *)name andPaymentUIname:(NSString *)uiname andAction:(NSString *)action;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *uiname;
@property (nonatomic, strong, readonly) NSString *action;
@property (nonatomic, strong, readonly) NSString *paymentType;
@property (nonatomic, assign, readonly) BOOL isPrePayment;
@end
