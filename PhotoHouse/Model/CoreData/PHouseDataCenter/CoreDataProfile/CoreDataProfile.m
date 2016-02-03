//
//  CoreDataProfile.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "CoreDataProfile.h"

#import "ProfileUserEntity.h"
#import "PhoneEntity.h"
#import "AddressEntity.h"
#import "DeliveryMemberEntity.h"

#import "ResponseAuth.h"



NSString *const PROFILE_ENTITY  = @"ProfileUserEntity";
NSString *const PHONE_ENTITY    = @"PhoneEntity";
NSString *const ADDRESS_ENTITY  = @"AddressEntity";
NSString *const DELIVERY_MEMBER_ENTITY = @"DeliveryMemberEntity";




@implementation CoreDataProfile

#pragma mark - Public (Save)
- (void) saveProfile:(ResponseAuth *)profile
{
    //
    NSArray *result = [self getAllObjectsWithEntityName:PROFILE_ENTITY];
    
    // Clear
    if (![[self profileID] isEqualToString:profile.id_user] || result.count > 1) {
        [self removeEntityName:PROFILE_ENTITY];
    }
    
    
    result = [self getAllObjectsWithEntityName:PROFILE_ENTITY];
    ProfileUserEntity *profileEntity;
    if (result.count == 1)
    {
        profileEntity = (ProfileUserEntity*)[result firstObject];
    }
    else
    {
        profileEntity = [NSEntityDescription insertNewObjectForEntityForName:PROFILE_ENTITY inManagedObjectContext:self.managedObjectContext];
    }
  
    [profileEntity setIdUser:profile.id_user];
    [profileEntity setPasswordMD5:profile.passwordHash];
    [profileEntity setFirstname:profile.firstname];
    [profileEntity setLastname:profile.lastname];
    [profileEntity setRegDate:profile.regdate];
    [profileEntity setEmail:profile.email];
    [profileEntity setGroupId:profile.group_id];
    [profileEntity setGroupname:profile.group_name];
    [profileEntity setAccess:profile.access];
    
    
    [self.managedObjectContext save:nil];
}



- (void) savePhone:(NSString *)phone
{
    //
    [self removeEntityName:PHONE_ENTITY];
    
    //
    NSArray *result = [self getAllObjectsWithEntityName:PROFILE_ENTITY];
    
    
    for (ProfileUserEntity *profileEntity in result)
    {
        PhoneEntity *phoneEntity = [NSEntityDescription insertNewObjectForEntityForName:PHONE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [phoneEntity setPhone:phone];
        [profileEntity setPhone:phoneEntity];

    }
    
    
    // Save
    [self.managedObjectContext save:nil];
}



- (void) saveDeliveryUiCityName:(NSString *)uiname
                andDeliveryCode:(NSString *)code
               andUiPaymentName:(NSString *)uiPayment
{
    
    [self removeEntityName:DELIVERY_MEMBER_ENTITY];
    
    
    NSArray *result = [self getAllObjectsWithEntityName:PROFILE_ENTITY];
    for (ProfileUserEntity *profileEntity in result)
    {
        DeliveryMemberEntity *deliveryEntity = [NSEntityDescription insertNewObjectForEntityForName:DELIVERY_MEMBER_ENTITY inManagedObjectContext:self.managedObjectContext];
        [deliveryEntity setUiCityName:uiname];
        [deliveryEntity setCodeDelivery:code];
        [deliveryEntity setUiPaymentName:uiPayment];
        [profileEntity setDeliveryMember:deliveryEntity];
    }
    
    [self.managedObjectContext save:nil];
}



- (void) saveAddress:(NSString *)address
{
    // Remove
    [self removeEntityName:ADDRESS_ENTITY];
    
    
    //
    NSArray *result = [self getAllObjectsWithEntityName:PROFILE_ENTITY];
    
    for (ProfileUserEntity *profileEntity in result)
    {
        AddressEntity *addressEntity = [NSEntityDescription insertNewObjectForEntityForName:ADDRESS_ENTITY inManagedObjectContext:self.managedObjectContext];
        [addressEntity setAddress:address];
        [profileEntity setAddress:addressEntity];
    }
    
    
    // Save
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    if (saveError) {
        NSLog(@"saveError");
    }
}



-(void)logount
{
    [self removeEntityName:PROFILE_ENTITY];
}




#pragma mark - Public (Compare)
- (void) addressCompareAndSave:(NSString *)address
{
    // Если адреса не совпадают сохраненный и новый       || или адрес вообще пустой, первый заказ
    if([[self getAddressProfile] isEqualToString:address] || [[self getAddressProfile] length] == 0)
    {
        [self saveAddress:address];
    }
}



- (void) phoneCompareAndSave:(NSString *)phone
{
    // Если адреса не совпадают сохраненный и новый   || или адресс вообще пустой, первый заказ
    if([[self getPhoneProfile] isEqualToString:phone] || [[self getPhoneProfile] length] == 0)
    {
        [self savePhone:phone];
    }
}




#pragma mark - Public (Getter)
- (NSString *) profileID
{
    NSArray *result = [self getAllObjectsWithEntityName:PROFILE_ENTITY];
    
    NSString *profileId;
    for (ProfileUserEntity *profileEntity in result) {
        profileId = profileEntity.idUser;
    }
    
    return profileId;
}



- (NSString *) passowrdMD5
{
    ResponseAuth *response = [self profile];
    return response.passwordHash;
}



- (ResponseAuth *) profile
{
    NSArray *result = [self getAllObjectsWithEntityName:PROFILE_ENTITY];
    
    ResponseAuth *response;
    for (ProfileUserEntity *profileEntity in result)
    {
        response = [[ResponseAuth alloc] initWithIdUser:profileEntity.idUser
                                         andPasswordHash:profileEntity.passwordMD5
                                           andFirstName:profileEntity.firstname
                                            andLastName:profileEntity.lastname
                                               andEmail:profileEntity.email
                                             andRegDate:profileEntity.regDate
                                             andGroupID:profileEntity.groupId
                                           andGroupName:profileEntity.groupname
                                              andAccess:profileEntity.access];
    }
    
    return response;
}



-(NSString *)getPhoneProfile
{
    NSArray *result = [self getAllObjectsWithEntityName:PHONE_ENTITY];
    
    NSString *phone;
    for (PhoneEntity *phoneEntity in result) {
        phone = phoneEntity.phone;
    }
    
    return phone;
}



-(NSString *)getAddressProfile
{
    NSArray *result = [self getAllObjectsWithEntityName:ADDRESS_ENTITY];
    
    NSString *address;
    for (AddressEntity *addressEntity in result) {
        address = addressEntity.address;
    }
    
    return address;
}



- (void) getDeliveryMemberWithBlock:(void(^)(NSString *uiCityName, NSString *deliveryCode, NSString *uiPaymentName))deliveryBlock;
{
    NSArray *result = [self getAllObjectsWithEntityName:DELIVERY_MEMBER_ENTITY];
    
    NSString *uiCityName = @"";
    NSString *code = @"";
    NSString *uiPayment = @"";
    for (DeliveryMemberEntity *deliveryEntity in result) {
        uiCityName = deliveryEntity.uiCityName;
        code = deliveryEntity.codeDelivery;
        uiPayment = deliveryEntity.uiPaymentName;
    }
    
    if (deliveryBlock) {
        deliveryBlock(uiCityName, code, uiPayment);
    }
}



#pragma mark - Private
- (void) removeEntityName:(NSString *)entityName
{
    NSArray *array = [self getAllObjectsWithEntityName:entityName];
    
    for (id object in array) {
        [self.managedObjectContext deleteObject:object];
    }
    
    [self.managedObjectContext save:nil];
}



- (NSArray*) getAllObjectsWithEntityName:(NSString*)entityName {
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
