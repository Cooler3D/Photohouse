//
//  ResponseRegistration.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseRegistration.h"
#import "CoreDataProfile.h"
#import "ResponseAuth.h"

@implementation ResponseRegistration

#pragma mark - Override
-(id)initWitParseData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}


#pragma mark - Private
- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error != nil) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
    NSDictionary *user = [result objectForKey:@"registration"];
    [self readUser:user];
}


- (void) readUser:(NSDictionary *)dictionary {
    NSString *name = [[dictionary objectForKey:@"firstname"] stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    NSString *last = [[dictionary objectForKey:@"lastname"] stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    
    _id_user    = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"id"]];
    _firstname  = name;//[dictionary objectForKey:@"firstname"];
    _lastname   = last;//[dictionary objectForKey:@"lastname"];
    _email      = [dictionary objectForKey:@"email"];
    _password   = [dictionary objectForKey:@"password"];
    _regdate    = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"reg_time"]];
    _group_id   = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"group_id"]];
    _group_name = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"group_name"]];
    _access     = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"access"]];
    
    ResponseAuth *respAuth = [[ResponseAuth alloc] initWithIdUser:_id_user
                                                   andPasswordHash:_password
                                                     andFirstName:_firstname
                                                      andLastName:_lastname
                                                         andEmail:_email
                                                       andRegDate:_regdate
                                                       andGroupID:_group_id
                                                     andGroupName:_group_name
                                                        andAccess:_access];
    
    // Save CoreData
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    [coreProfile saveProfile:respAuth];
}



- (void) makeError:(NSDictionary *)parsedObject
{
    NSDictionary *err = [parsedObject objectForKey:@"err"];
    
    //
    NSString *errorCode = [err objectForKey:@"code"];
    NSString *errorMessage = [err objectForKey:@"message"];
    NSString *errorEX = [err objectForKey:@"ex"];
    
    NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"Ошибка: %@, %@", errorMessage, errorEX] code:[errorCode integerValue] userInfo:nil];
    NSLog(@"error: %@", [error localizedDescription]);
//    [self setError:error];
}

@end
