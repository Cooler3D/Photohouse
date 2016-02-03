//
//  CoreDataStoreBanner.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "CoreDataStoreBanner.h"

#import "BannerEntity.h"
#import "Banner.h"

NSString *const BANNER_ENTITY = @"BannerEntity";



@implementation CoreDataStoreBanner

- (void) saveBanners:(NSArray *)banners andSwitchTimeInterval:(NSInteger)interval
{
    //
    [self clearBanners];
    
    // Add
    for (Banner *banner in banners) {
        BannerEntity *entity = [self bannerWithBanner:banner andInterval:interval];
        [entity.managedObjectContext save:nil];
    }
}


- (NSArray *) getBannersSetInterval:(NSInteger *)interval
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:BANNER_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    // Read
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Fetch.Error: %@", fetchError);
    }
    
    // Result
    NSMutableArray *banners = [NSMutableArray array];
    for (BannerEntity *bannerEntity in result) {
        Banner *banner = [[Banner alloc] initWithActionUrl:bannerEntity.actionUrl andImage:[UIImage imageWithData:bannerEntity.image]];
        if (interval) {
            *interval = [bannerEntity.interval integerValue];
        }
        [banners addObject:banner];
    }

    return [banners copy];
}




- (void) removeAllSavedBanners
{
    [self clearBanners];
}


-(BOOL)hasBanners
{
    NSArray *banners = [self getBannersSetInterval:0];
    return banners.count == 0 ? NO : YES;
}



#pragma mark - Private
- (BannerEntity *) bannerWithBanner:(Banner *)banner andInterval:(NSInteger)interval {
    BannerEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:BANNER_ENTITY inManagedObjectContext:self.managedObjectContext];
    [entity setImageUrl:banner.imageUrl];
    [entity setImage:UIImageJPEGRepresentation(banner.image, 0.5f)];
    [entity setActionUrl:banner.actionUrl];
    [entity setInterval:[NSNumber numberWithInteger:interval]];
    return entity;
}


- (void) clearBanners {
    NSArray *objects = [self allObjects];
    
    for (id object in objects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    [self.managedObjectContext save:nil];
}


- (NSArray*) allObjects {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *desription = [NSEntityDescription entityForName:BANNER_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:desription];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Fetch.Error: %@", fetchError);
    }
    
    return result;
}

@end
