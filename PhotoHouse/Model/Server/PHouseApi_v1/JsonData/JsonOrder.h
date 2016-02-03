//
//  JsonOrder.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/26/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "Json.h"

@class PrintData;

@interface JsonOrder : Json
- (id) initWithFirstName:(NSString*)firstName
             andLastName:(NSString*)lastName
                andPhone:(NSString*)phone
              andAddress:(NSString*)address
             withComment:(NSString*)text
    andPhotoRecordsArray:(NSArray*)cartArray
     andDeliveryPrintDta:(PrintData*)deliveryPrintData;
@end
