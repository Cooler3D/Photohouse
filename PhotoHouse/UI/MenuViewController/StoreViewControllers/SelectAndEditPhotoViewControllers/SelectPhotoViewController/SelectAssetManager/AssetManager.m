//
//  AssetManager.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "AssetManager.h"

@implementation AssetManager
+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusAuthorized:
            // User allowed access
            // fallthrough
            NSLog(@"ALAuthorizationStatusAuthorized");
        case ALAuthorizationStatusNotDetermined:
            // Ok cool, go ahead, use the assets library,
            // user will be prompted to allow access
            
            // show UI to use library
            
            NSLog(@"ALAuthorizationStatusNotDetermined");
            break;
        case ALAuthorizationStatusRestricted:
            // Access is restricted by administrator of device and cannot be changed
            // Do not display UI to browse or use Assets library
            NSLog(@"ALAuthorizationStatusRestricted");
            break;
        case ALAuthorizationStatusDenied:
            // User denied access, display UI to explain user how to enable access
            NSLog(@"ALAuthorizationStatusDenied");
            break;
    }
    return library;
}
@end
