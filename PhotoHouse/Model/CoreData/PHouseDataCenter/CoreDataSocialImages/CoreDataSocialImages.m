//
//  CoreDataInstagram.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "CoreDataSocialImages.h"

#import "SocialImageEntity.h"

#import "LoadImageManager.h"



NSString *const SOCIAL_IMAGE_ENTITY = @"SocialImageEntity";




@implementation CoreDataSocialImages


- (void) saveImage:(UIImage *)image
           withURL:(NSString *)url
    andLibraryType:(ImportLibrary)libraryType
{
    // Проверяем, нет ли уже в базе, если есть, то не добавляем
    UIImage *searchImage = [self getImageWithURL:url];
    if (searchImage || !url) {
        return;
    }
    
    // Возможно переключатель в настройках на КЭШ
#warning ToDo: Убрано, чтобы все картинки сохранялись в CoreData
    //if ([self isCacheStatus] == CacheClosed) return;
    
    // Add
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
    SocialImageEntity *socialEntity = [NSEntityDescription insertNewObjectForEntityForName:SOCIAL_IMAGE_ENTITY inManagedObjectContext:self.managedObjectContext];
    [socialEntity setUrl:url];
    [socialEntity setImage:imageData];
    [socialEntity setLibrary:[NSNumber numberWithInteger:libraryType]];
    
    
    // Save
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Save.Error: %@", saveError);
    }
}



- (void)savePhotoRecord:(PhotoRecord *)record
{
    [self saveImage:record.image withURL:record.name andLibraryType:record.importFromLibrary];
}



- (UIImage *) getImageWithURL:(NSString *)url
{
    NSData *imageData = [self getImageDataWithURL:url];
    return [UIImage imageWithData:imageData];
}


- (NSData *) getImageDataWithURL:(NSString *)url
{
    if (!url || [url isEqualToString:@""] || [url isEqualToString:@"(null)"]) {
        return nil;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:SOCIAL_IMAGE_ENTITY inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"url CONTAINS %@", url];
    [request setPredicate:predacate];
    
    [request setEntity:description];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    // Read
    for (SocialImageEntity *socialEntity in result) {
        //UIImage *image = [UIImage imageWithData:socialEntity.image];
        //NSLog(@"Complete: %@", [(VKDataEntity*)object normalUrl]);
        return socialEntity.image;
    }
    
    return nil;
}



/*- (void) loadImageWithURL:(NSString *)url
              usingBlock:(void(^)(BOOL isSuccess, UIImage *image))completeBlock
{
    if (!url || [url isEqualToString:@"(null)"]) {
        return;
    }
    
    // Search image
    __block UIImage *saveimage = [self getImageWithURL:url];


    if (saveimage == nil)
    {
        LoadImageManager *imageManager = [[LoadImageManager alloc] init];
        [imageManager loadImageWithURL:url usingBlock:^(BOOL isSuccess, UIImage *image) {
            saveimage = image;
            
            // Save to Cache
            [self saveImage:saveimage withURL:url andLibraryType:4];
            
            // Block
            if (completeBlock) {
                completeBlock(saveimage == nil ? NO : YES, saveimage);
            }
        }];
    }
    else
    {
        // Block
        if (completeBlock) {
            completeBlock(saveimage == nil ? NO : YES, saveimage);
        }
    }
}*/


-(NSArray *)getRecordWithNames:(NSArray *)urlNames
{
    
    NSEntityDescription *description = [NSEntityDescription entityForName:SOCIAL_IMAGE_ENTITY inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"library > 0 AND library < 4"];
    [request setPredicate:predacate];
    [request setEntity:description];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    
    
    /// Блок сравнения массива urlNames и имени от CoreData. Yes - совпадение найдено, NO - не найдено
    BOOL (^CompareEntityNameWithURlsBlock)(NSArray *, NSString*) = ^(NSArray *urls, NSString *fetchName){
        for (NSString *url in urls) {
            if ([url isEqualToString:fetchName]) {
                return YES;
            }
        }
        return NO;
    };
    
    
    

    NSMutableArray *records = [NSMutableArray array];
    for (SocialImageEntity *socialEntity in result) {
        if (CompareEntityNameWithURlsBlock(urlNames, socialEntity.url)) {
            PhotoRecord *record = [[PhotoRecord alloc] initWithSocialURl:socialEntity.url withImage:nil andImportLibrary:(ImportLibrary)[socialEntity.library integerValue]];
//            PhotoRecord *record = [[PhotoRecord alloc] initWithSocialURl:socialEntity.url andImaportLibrary:(ImportLibrary)[socialEntity.library integerValue]];
            [record setImage:[UIImage imageWithData:socialEntity.image]];
            [records addObject:record];
        }
    }
    
    return [records copy];
}




- (NSArray *) getAllImgesWithLibraryType:(ImportLibrary)libraryType
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"library == %i", libraryType];
    NSEntityDescription *description = [NSEntityDescription entityForName:SOCIAL_IMAGE_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setPredicate:predacate];
    [request setEntity:description];
    
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    
    NSMutableArray *photoRecords = [NSMutableArray array];
    
    for (SocialImageEntity *socialEntity in result) {
        UIImage *image = [UIImage imageWithData:socialEntity.image];
        PhotoRecord *record = [[PhotoRecord alloc] initWithSocialURl:socialEntity.url withImage:nil andImportLibrary:(ImportLibrary)[socialEntity.library integerValue]];
//        PhotoRecord *record = [[PhotoRecord alloc] initWithSocialURl:socialEntity.url andImaportLibrary:(ImportLibrary)[socialEntity.library integerValue]];
        [record setImage:image];
        [photoRecords addObject:record];
    }
    
    return photoRecords;
}



- (void) removeAllImages
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:SOCIAL_IMAGE_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"FetchError: %@", fetchError);
    }
    
    for (id object in result) {
        [self.managedObjectContext deleteObject:object];
    }
    
    [self.managedObjectContext save:nil];
}
@end
