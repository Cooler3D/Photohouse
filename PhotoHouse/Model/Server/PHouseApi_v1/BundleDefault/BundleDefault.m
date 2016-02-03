//
//  BundleDefault.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "BundleDefault.h"


NSString *const RESPONSE_SERVER_IMAGES_KEY      = @"rangeImages";
NSString *const RESPONSE_SERVER_DELIVERY_KEY    = @"delivery";
NSString *const RESPONSE_SERVER_PRICE_KEY       = @"price";
NSString *const RESPONSE_SERVER_ITEMS_KEY       = @"storeItems";
NSString *const RESPONSE_SERVER_ALBUM_KEY       = @"albumconstructor";
NSString *const RESPONSE_SERVER_ALBUM_TEST_KEY  = @"albumconstructorTests";
NSString *const RESPONSE_SERVER_BANNERS_KEY     = @"banners";

NSString *const RESPONSE_SERVER_UPLOAD_IMAGE_TEST_KEY   = @"upload_image_test";
NSString *const RESPONSE_SERVER_AUTH_TEST_KEY           = @"auth_test";
NSString *const RESPONSE_SERVER_REGISTRATION_TEST       = @"registration_test";

NSString *const RESPONSE_SERVER_ALBUM_VER2_TEST         = @"albumconstructor_v2Test";

NSString *const RESPONSE_SERVER_UPDATE_TIME_TEST        = @"update_time_test";

@implementation BundleDefault

- (NSData *) defaultDataWithBundleName:(BundleDefaultType)bundleType
{
    NSData *data = [self dataWithBundleType:bundleType];
    if (data == nil) {
        NSLog(@"\n!!!\n!!!\nDefault Bundle NULL\n!!!\n!!!\n");
    }
    return data;
}



#pragma mark - Methods
- (NSData *) dataWithBundleType:(BundleDefaultType)bundleType
{
    //
    NSString *key;
    
    //
    switch (bundleType) {
        case BundleDefaultTypeDelivery:
            key = RESPONSE_SERVER_DELIVERY_KEY;
            break;
            
        case BundleDefaultTypeRangeImages:
            key = RESPONSE_SERVER_IMAGES_KEY;
            break;
            
        case BundleDefaultTypePrice:
            key = RESPONSE_SERVER_PRICE_KEY;
            break;
            
        case BundleDefaultTypeAllItems:
            key = RESPONSE_SERVER_ITEMS_KEY;
            break;
            
//        case BundleDefaultTypeAlbum:
//            key = RESPONSE_SERVER_ALBUM_KEY;
//            break;
//            
//        case BundleDefaultTypeAlbumTests:
//            key = RESPONSE_SERVER_ALBUM_TEST_KEY;
//            break;
            
        case BundleDefaultTypeBanners:
            key = RESPONSE_SERVER_BANNERS_KEY;
            break;
            
        case BundleDefaultTypeResponceUploadImageTest:
            key = RESPONSE_SERVER_UPLOAD_IMAGE_TEST_KEY;
            break;
            
        case BundleDefaultTypeResponceAuthTest:
            key = RESPONSE_SERVER_AUTH_TEST_KEY;
            break;
            
        case BundleDefaultTypeRegistrationTest:
            key = RESPONSE_SERVER_REGISTRATION_TEST;
            break;
            
        case BundleDefaultTypeAlbumTestVer2:
            key = RESPONSE_SERVER_ALBUM_VER2_TEST;
            break;
            
        case BundleDefaultTypeUpdateTimeTest:
            key = RESPONSE_SERVER_UPDATE_TIME_TEST;
            break;
    }
    
    
    // Read
    NSString *bundleFile = [[NSBundle mainBundle] pathForResource:@"responses" ofType:@"plist"];
    NSDictionary *dictPlist = [NSDictionary dictionaryWithContentsOfFile:bundleFile];
    
    NSString *fileResponse = [dictPlist objectForKey:key];
    bundleFile = [[NSBundle mainBundle] pathForResource:fileResponse ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:bundleFile];
    return data;
}
@end
