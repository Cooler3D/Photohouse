//
//  ResponseGetAddressList.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetAddressList.h"
#import "CoreDataProfile.h"

@implementation ResponseGetAddressList
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
    NSLog(@"%@", result);
    
    // Save To CoreData
//    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
//    [coreProfile addressCompareAndSave:[adsressesStringArray lastObject]];

}


-(NSString *)getAddress
{
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    return [coreProfile getAddressProfile];
}


@end
