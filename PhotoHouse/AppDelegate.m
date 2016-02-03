//
//  AppDelegate.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/5/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


#import "AnaliticsModel.h"

#import "CoreDataProfile.h"
#import "CoreDataShopCart.h"
#import "CoreDataCacheImage.h"
#import "CoreDataStore.h"
#import "ResponseAuth.h"
#import "ResponseGetUpdateTime.h"

#import "PHInitViewController.h"

#import "PHouseApi.h"


#import "PHRequestCommand.h"
#import "MDPhotoLibrary.h"

static NSString *const COOKIE_IMAGE_SAVE_TURN_KEY = @"cookie_image_save_turn_key";
static NSString *const CART_ORDER_COUNT_KEY = @"cart_order_count_key";



@interface AppDelegate () <PHouseApiDelegate>

@end



@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // CrashReport
    [Crashlytics startWithAPIKey:@"de2def5b9911e95d0e5d99f95025212a9f407eb7"];

    // Crash User Information
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    if (coreProfile.profileID) {
        [self setUserData:[coreProfile profile]];
    } else {
        [Crashlytics setUserName:@"Гость"];
    }
    
    
    // Crash Cookie Image
    CoreDataCacheImage *coreCookie = [[CoreDataCacheImage alloc] init];
    [Crashlytics setObjectValue:coreCookie.isCacheStatus == CacheOpened ? @"opened" : @"closed" forKey:COOKIE_IMAGE_SAVE_TURN_KEY];
    
    
    // Badje Icon
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [Crashlytics setIntValue:(unsigned int)[coreShop getAllItemsWithNeedAddImages:NO].count forKey:CART_ORDER_COUNT_KEY];
//#warning ToDo: Remove Here
//    [coreShop removeAll];
//    CoreDataAlbumConstructor *coreConstructor = [[CoreDataAlbumConstructor alloc] init];
//    [coreConstructor clearAllUserTemplatesShopCart];
    
    //CLS_LOG(@"Execute.Responce: {, Execute.Responce: {, Execute.Responce: { Execute.Responce: { Execute.Responce: { Execute.Responce: { Execute.Responce: {");
    
    // Test Crash Close
    //[[Crashlytics sharedInstance] crash];
    
    
    
    
    // App Version
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * versionBuildString = [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
    [[AnaliticsModel sharedManager] sendEventCategory:@"APP" andAction:@"StartApp" andLabel:versionBuildString withValue:nil];
    
    // Request
    PHouseApi *api = [[PHouseApi alloc] init];
    [api getDeliveriesWithDelegate:self orBlock:nil];
    [api getUpdateTimeWithDelegate:self];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(17.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //[self pHouseApi:api didBannerReceiveData:nil];
//        [self pHouseApi:api didStoreItemsReceiveData:nil];
//        NSLog(@"TimeOut Start App");
//    });
    
    
    
    // Push
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
//    UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
    
    
    // Status Bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    // BackGroundUpload
    //[application setMinimumBackgroundFetchInterval: UIApplicationBackgroundFetchIntervalMinimum];
    
    [Fabric with:@[CrashlyticsKit]];
    
    return YES;
}


#pragma mark - Methods
- (void) gotoInitStoryBoard
{
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"PhInit"]; // PhInit //
    self.window.rootViewController = controller;
}



#pragma mark - PHouseApiDelegate
//-(void)pHouseApi:(PHouseApi *)phApi didBannerReceiveData:(NSArray *)banners
//{
//    if ([phApi.delegate isKindOfClass:[AppDelegate class]]) {
//        [self gotoInitStoryBoard];
//    }
//    
//    [phApi setDelegate:nil];
//    phApi = nil;
//}

-(void)pHouseApi:(PHouseApi *)phApi didStoreItemsReceiveData:(PHResponse *)response
{
    if ([phApi.delegate isKindOfClass:[AppDelegate class]]) {
        NSLog(@"Load StoreItems Ok");
        [self gotoInitStoryBoard];
    }
    
    [phApi setDelegate:nil];
    phApi = nil;
}


-(void)pHouseApi:(PHouseApi *)phApi didUpdateTime:(PHResponse *)response
{
    ResponseGetUpdateTime *responseUpdate = (ResponseGetUpdateTime*)response;
    if (responseUpdate.bannersNeedUpdate) {
        NSLog(@"\n\n!!! Banners from Server");
        [phApi getBannersWithDelegate:self];
    }

    if (responseUpdate.getItemsNeedUpdate || responseUpdate.getTemplatesNeedUpdate) {
        NSLog(@"\n\n!!! GetItems/Templates from Server");
        [phApi getAllItemsWithDelegate:self];
    }

    if (!responseUpdate.getItemsNeedUpdate && !responseUpdate.getTemplatesNeedUpdate) {
        [self gotoInitStoryBoard];
    }
}


-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    BOOL hasStoreData = [coreStore hasStoreData];
    if (hasStoreData) {
        NSLog(@"Error. Has DATA Store, Continue");
        [phApi setDelegate:nil];
        phApi = nil;
        [self gotoInitStoryBoard];
    } else {
        NSLog(@"Error. No DATA Store, Get Items");
        [phApi getAllItemsWithDelegate:self];
    }
}



#pragma mark - Crashlytics User Profile
- (void) setUserData:(ResponseAuth *)responseAuth
{
    if (responseAuth == nil) {
        CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
        responseAuth = [coreProfile profile];
    }
    
    // Set Data
    [Crashlytics setUserIdentifier:responseAuth.id_user];
    [Crashlytics setUserEmail:responseAuth.email];
    [Crashlytics setUserName:[NSString stringWithFormat:@"%@ %@", responseAuth.lastname, responseAuth.firstname]];

}

-(void)crashlyticsLog:(NSString *)logText {
    CLS_LOG(@"%@", logText);
}



#pragma mark - Push Notification
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //[[PhotoHouseAPIModel sharedManager] setTokenDevice:token];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:APPLICATION_TOKEN];
    [userDefaults synchronize];
    NSLog(@"token: %@", token);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"NULL" forKey:APPLICATION_TOKEN];
    [userDefaults synchronize];
}


#pragma mark - Application
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /*UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //[localNotification setTimeZone:[NSTimeZone defaultTimeZone]];//[NSTimeZone timeZoneForSecondsFromGMT:14400]];
    //[localNotification setFireDate:date];
    [localNotification setAlertBody:@"Фоновый режим"];
    [application scheduleLocalNotification:localNotification];*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Called when application upload in background
    NSLog(@"Back");
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    //[localNotification setTimeZone:[NSTimeZone defaultTimeZone]];//[NSTimeZone timeZoneForSecondsFromGMT:14400]];
//    //[localNotification setFireDate:date];
//    [localNotification setAlertBody:@"Загрузка продолжится в фоновом режиме"];
//    [localNotification setSoundName:UILocalNotificationDefaultSoundName];
//    [application scheduleLocalNotification:localNotification];
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    NSUInteger orientations = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
    
    if(self.window.rootViewController){
        UIViewController *rootViewController = (UINavigationController *)self.window.rootViewController;
        
        UIViewController *topController;
        if ([rootViewController isKindOfClass:[PHInitViewController class]]) {
            topController = [(PHInitViewController *)rootViewController topViewController];
        }
        
        NSArray *arr;
        if ([topController isKindOfClass:[UINavigationController class]]) {
            arr = [(UINavigationController *)topController viewControllers];
        }
        
        
        if (arr) {
            UIViewController *presentedViewController = [arr lastObject];
            orientations = [presentedViewController supportedInterfaceOrientations];
        }
    }
    
    return orientations;
}

@end
