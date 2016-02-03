//
//  PHDataManager.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/18/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"
#import "CoreDataModel.h"



NSString *const APPLICATION_CACHE = @"APPLICATION_CACHE";



@implementation PHDataManager
/*@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;*/


- (NSManagedObjectContext*) managedObjectContext
{
    /*if (!_managedObjectContext) {
        _managedObjectContext = [[CoreDataModel sharedManager] managedObjectContext];
    }
    [CoreDataModel sharedManager] managedObjectContext*/
    
    return [[CoreDataModel sharedManager] managedObjectContext];
}


#pragma mark - Cache
- (CacheStatusType) isCacheStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isOn = [userDefaults objectForKey:APPLICATION_CACHE];
    if (!isOn) {
        [userDefaults setObject:@"1" forKey:APPLICATION_CACHE];
        [userDefaults synchronize];
        return CacheOpened;
    }
    
    return [isOn isEqualToString:@"1"] ? CacheOpened : CacheClosed;
}
@end
