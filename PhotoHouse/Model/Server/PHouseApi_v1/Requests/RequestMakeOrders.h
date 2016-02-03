//
//  RequestMakeOrder.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@class PrintData;

@interface RequestMakeOrders : PHRequest
- (id) initWithFirstName:(NSString*)firstName
            andLastName:(NSString*)lastName
               andPhone:(NSString*)phone
             andAddress:(NSString*)address
            withComment:(NSString*)text
    andPhotoRecordsArray:(NSArray*)cartArray
     andDeliveryPrintDta:(PrintData*)deliveryPrintData __attribute__((deprecated("Use 'JSon'")));
@end
