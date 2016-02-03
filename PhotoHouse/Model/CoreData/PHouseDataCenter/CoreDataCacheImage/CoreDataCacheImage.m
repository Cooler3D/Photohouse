//
//  CoreDataCacheImage.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "CoreDataCacheImage.h"

#import "CoreDataSocialImages.h"


@implementation CoreDataCacheImage
- (void) cacheSwitch:(BOOL)isOn
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:(isOn ? @"1" : @"0") forKey:APPLICATION_CACHE];
    [userDefaults synchronize];

    if (!isOn)
    {
        [self clearAllImages];
    }
}


- (BOOL) isCacheOpened
{
    return self.isCacheStatus == CacheOpened ? YES : NO;
}



 
- (void) clearAllImages
{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queueInstagram = dispatch_queue_create("com.photohouse.instagram.image.remove", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, queueInstagram, ^{
        CoreDataSocialImages *coreSocial = [[CoreDataSocialImages alloc] init];
        [coreSocial removeAllImages];
    });
    /*
    dispatch_queue_t queueVK = dispatch_queue_create("com.photohouse.vk.image.remove", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, queueVK, ^{
        CoreDataVK *coreVk = [[CoreDataVK alloc] init];
        [coreVk removeAllVKImages];
    });
    
    dispatch_queue_t queueHistory = dispatch_queue_create("com.photohouse.history.image.remove", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, queueHistory, ^{
        //CoreDataInstagram *instagram = [[CoreDataInstagram alloc] init];
        //[instagram removeAllInstagramImages];
    });*/



    // All Compelete
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        
//    });
}
@end
