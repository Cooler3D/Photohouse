//
//  ResponseGetPhoneList.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseGetPhoneList.h"
#import "CoreDataProfile.h"


@implementation ResponseGetPhoneList
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

    // Save To CoreData
//    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
//    [coreProfile phoneCompareAndSave:[phoneStringArray lastObject]];

}


- (NSString *) getPhone
{
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    return [coreProfile getPhoneProfile];
}

@end
