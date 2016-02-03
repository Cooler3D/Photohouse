//
//  PHDataManager.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/18/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CacheOpened,
    CacheClosed
} CacheStatusType;

extern NSString *const APPLICATION_CACHE;

@interface PHDataManager : NSObject
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
/*@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;*/


- (CacheStatusType) isCacheStatus;
@end
