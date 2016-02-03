//
//  CoreDataDelivery.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "CoreDataDelivery.h"
#import "DeliveryCityEntity.h"
#import "DeliveryTypeEntity.h"
#import "PaymentEntity.h"

#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"


NSString *const DELIVERY_CITY_ENTITY    = @"DeliveryCityEntity";
NSString *const DELIVERY_TYPE_ENTITY    = @"DeliveryTypeEntity";
NSString *const PAYMENT_ENTITY          = @"PaymentEntity";



@implementation CoreDataDelivery

#pragma mark - Public
- (void) saveAllDelivery:(NSArray *)deliveries
{
    //
    [self clearAllDelivery];
    
    // Delivery City
    for (DeliveryCity *city in deliveries) {
        DeliveryCityEntity *cityEntity = [NSEntityDescription insertNewObjectForEntityForName:DELIVERY_CITY_ENTITY inManagedObjectContext:self.managedObjectContext];
        [cityEntity setName:city.name];
        [cityEntity setUiname:city.uiname];
        
        // Delivery Type
        for (DeliveryType *type in city.types) {
            DeliveryTypeEntity *typeEntity = [NSEntityDescription insertNewObjectForEntityForName:DELIVERY_TYPE_ENTITY inManagedObjectContext:self.managedObjectContext];
            [typeEntity setType:type.type];
            [typeEntity setCode:type.code];
            [typeEntity setDescritions:type.deldescription];
            [typeEntity setCost:[NSNumber numberWithInteger:type.cost]];
            [cityEntity addDeliveriesObject:typeEntity];
            
            // Payment
            for (Payment *payment in type.payments) {
                PaymentEntity *paymentEntity = [NSEntityDescription insertNewObjectForEntityForName:PAYMENT_ENTITY inManagedObjectContext:self.managedObjectContext];
                [paymentEntity setName:payment.name];
                [paymentEntity setUiname:payment.uiname];
                [paymentEntity setPaymentType:payment.paymentType];
                [paymentEntity setAction:payment.action];
                [typeEntity addPaymentsObject:paymentEntity];
            }
        }
    }
    
    
    // Save
    [self.managedObjectContext save:nil];
}




- (BOOL) isSavedDelivery
{
    NSArray *array = [self allObjectsWithEntityName:DELIVERY_CITY_ENTITY];
    return [array count] > 0 ? YES : NO;
}






- (NSArray *) getAllCityUINames
{
    NSArray *allObjects = [self allObjectsWithEntityName:DELIVERY_CITY_ENTITY];
    NSMutableArray *allNames = [NSMutableArray array];
    for (DeliveryCityEntity *cityEntity in allObjects) {
        [allNames addObject:cityEntity.uiname];
    }
    
    return [allNames copy];
}




-(DeliveryCity *)getDeliveryCityWithUIName:(NSString *)uiname
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:DELIVERY_CITY_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uiname CONTAINS %@", uiname];
    [request setPredicate:predicate];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }
    
    
    // Read
    DeliveryCity *deliveryCityResult;
    
    for (DeliveryCityEntity *cityEntity in result)
    {
        NSArray *types = [self getDeliveryTypeArrayWithDeliveryCityEntity:cityEntity
                                                                 withCode:@""
                                                         andPaymentUIName:@""];
        deliveryCityResult = [[DeliveryCity alloc] initWitName:cityEntity.name andUIname:cityEntity.uiname andSetTypes:[types copy]];
    }
    
    return deliveryCityResult;
}



- (DeliveryCity *) getDeliveryCityWithUIName:(NSString *)uiname
                             andDeliveryCode:(NSString *)code
{
    /*NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:DELIVERY_CITY_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uiname == %@ AND SUBQUERY(deliveries, $delivery, ANY $delivery.code == %@).@count > 0",uiname, code];
    [request setPredicate:predicate];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }*/
    NSError *fetchError = nil;
    NSArray *result = [self createFetchReguestWithUIName:uiname andCodeDelivery:code withExecuteFetchError:fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }
    
    
    // Read
    DeliveryCity *deliveryCityResult;
    for (DeliveryCityEntity *cityEntity in result)
    {
        NSArray *types = [self getDeliveryTypeArrayWithDeliveryCityEntity:cityEntity
                                                                 withCode:code
                                                         andPaymentUIName:@""];
        deliveryCityResult = [[DeliveryCity alloc] initWitName:cityEntity.name andUIname:cityEntity.uiname andSetTypes:types];
    }
    
    //if (!deliveryCityResult) {
        //NSLog(@"city: %@, code: %@", uiname, code);
    //}
    
    return deliveryCityResult;
}




-(DeliveryCity *)getDeliveryCityWithUICityName:(NSString *)uiname
                               andCodeDelivery:(NSString *)code
                              andPaymentUIName:(NSString *)paymentUIname
{
    /*NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:DELIVERY_CITY_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uiname == %@ AND SUBQUERY(deliveries, $delivery, ANY $delivery.code == %@).@count > 0",uiname, code];
    [request setPredicate:predicate];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }*/
    
    NSError *fetchError = nil;
    NSArray *result = [self createFetchReguestWithUIName:uiname andCodeDelivery:code withExecuteFetchError:fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }

    // Read
    DeliveryCity *deliveryCityResult;
    for (DeliveryCityEntity *cityEntity in result)
    {
        NSArray *types = [self getDeliveryTypeArrayWithDeliveryCityEntity:cityEntity withCode:code andPaymentUIName:paymentUIname];
        deliveryCityResult = [[DeliveryCity alloc] initWitName:cityEntity.name andUIname:cityEntity.uiname andSetTypes:types];
    }
    
    if (!deliveryCityResult) {
        NSLog(@"city: %@, code: %@; payment: %@", uiname, code, paymentUIname);
    }
    
    return deliveryCityResult;
}




-(NSArray *)getAllPaymentForUICityName:(NSString *)uiname
                       andCodeDelivery:(NSString *)code
{
    NSError *fetchError = nil;
    NSArray *result = [self createFetchReguestWithUIName:uiname andCodeDelivery:code withExecuteFetchError:fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }

    // Read
    NSMutableArray *paymentsList = [NSMutableArray array];
    for (DeliveryCityEntity *cityEntity in result)
    {
        NSArray *types = [self getDeliveryTypeArrayWithDeliveryCityEntity:cityEntity withCode:code andPaymentUIName:@""];
        DeliveryCity *deliveryCity = [[DeliveryCity alloc] initWitName:cityEntity.name andUIname:cityEntity.uiname andSetTypes:types];
        
        for (Payment *payment in [[deliveryCity.types firstObject] payments]) {
            [paymentsList addObject:payment.uiname];
        }
    }

    return [paymentsList copy];
}



#pragma mark - Private
- (NSArray *) createFetchReguestWithUIName:(NSString *)uiname
                           andCodeDelivery:(NSString *)code
                     withExecuteFetchError:(NSError *)fetchError
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:DELIVERY_CITY_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uiname == %@ AND SUBQUERY(deliveries, $delivery, ANY $delivery.code == %@).@count > 0", uiname, code];
    [request setPredicate:predicate];
    
    
    //NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }

    return result;
}



- (NSArray *) getDeliveryTypeArrayWithDeliveryCityEntity:(DeliveryCityEntity *)deliveryCityEntity
                                                withCode:(NSString *)code
                                        andPaymentUIName:(NSString *)paymentUIname
{
    NSMutableArray *types = [NSMutableArray array];
    for (DeliveryTypeEntity *typeEntity in deliveryCityEntity.deliveries)
    {
        NSArray *payments = [self getPaymentArrayWithDeliveryTypeEntity:typeEntity
                                                         andPaymentUIName:paymentUIname];
        DeliveryType *delType = [[DeliveryType alloc] initWithType:typeEntity.type
                                                    andDescription:typeEntity.descritions
                                                           andCode:typeEntity.code
                                                           andCost:[typeEntity.cost integerValue]
                                                       andPayments:payments];
        if ([code isEqualToString:typeEntity.code] || [code isEqualToString:@""]) {
            [types addObject:delType];
        }
        
    }
    
    
    
    return [types copy];
}




- (NSArray *) getPaymentArrayWithDeliveryTypeEntity:(DeliveryTypeEntity *)deliveryTypeEntity
                                   andPaymentUIName:(NSString *)paymentUIname
{
    NSMutableArray *payments = [NSMutableArray array];
    
    
    for (PaymentEntity *paymentEntity in deliveryTypeEntity.payments)
    {
        Payment *payment = [[Payment alloc] initPaymentType:paymentEntity.paymentType
                                             andPaymentName:paymentEntity.name
                                           andPaymentUIname:paymentEntity.uiname
                                                  andAction:paymentEntity.action];
        if ([paymentUIname isEqualToString:paymentEntity.uiname] || [paymentUIname isEqualToString:@""]) {
            [payments addObject:payment];
        }
    }
    
    return [payments copy];
}





- (void) clearAllDelivery
{
    NSArray *array = [self allObjectsWithEntityName:DELIVERY_CITY_ENTITY];
    
    for (id object in array) {
        [self.managedObjectContext deleteObject:object];
    }
    
    [self.managedObjectContext save:nil];
}

- (NSArray*) allObjectsWithEntityName:(NSString*)entityName {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }
    
    
    return result;
}


@end
