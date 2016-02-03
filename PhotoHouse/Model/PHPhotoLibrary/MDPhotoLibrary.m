//
//  MDPhotoLibrary.m
//  CollectionView
//
//  Created by Мартынов Дмитрий on 01/11/15.
//  Copyright © 2015 Дмитрий Мартынов. All rights reserved.
//

#import "MDPhotoLibrary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetManager.h"
#import "AppDelegate.h"

#import "NSTimer+TimerSupport.h"


NSString * const PHOTO_LIBRARY_ERROR_KEY = @"PHOTO_LIBRARY_ERROR_KEY";

NSString * const PHOTO_LIBRARY_GROUP_ALBUM_NAME = @"PhotoHouse";

typedef enum {
    Done,
    Progress,
    DontUse
} AssetAdded;

static NSUInteger const MAX_ASSET_COUNT = 100;//300;

@interface MDPhotoLibrary ()
@property (nonatomic, readonly) ALAssetsLibrary *assetLibrary;      ///< Библиотека
@property (assign, nonatomic) NSRange assetsRange;                  ///< Дапозон загрузки фоток в группе assetsGroupsNames
@property (strong, nonatomic) NSMutableDictionary *assetsGroups;
@property (assign, nonatomic) BOOL isContinue;
@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) NSError *errorNotAutorized;           ///< Ошибка авторизации в библиотеке
@property (strong, nonatomic) NSArray *allgroups;                   ///< Массив со всеми группами фоток
@end



@implementation MDPhotoLibrary
-(instancetype)init {
    self = [super init];
    if (self) {
        _assetLibrary = [AssetManager defaultAssetsLibrary];
//        _isContinue = NO;
        _assetsGroups = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (BOOL)isAuthorized
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    return (status == ALAuthorizationStatusAuthorized ||
            status == ALAuthorizationStatusNotDetermined);
}


-(void)loadPhotosAsynchronously:(void (^)(NSArray *, NSError *))callbackBlock {
    
    if (![MDPhotoLibrary isAuthorized]) {
        if (callbackBlock) {
            callbackBlock(@[], self.errorNotAutorized);
        }
        return;
    }
    
    if (self.assetsGroups.allKeys.count == 0) {
        [self updateAssetsGroups:self.assetsGroups];
    }
    
    
    BOOL isAllDone = [self isAllGroupsDone:self.assetsGroups];
    if (isAllDone) {
        if (callbackBlock) {
            callbackBlock(@[], nil);
        }
        return;
    }
    
//    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (systemVersion >= 8.f && systemVersion < 9.f) {
//        NSString *model = [[UIDevice currentDevice] model];
//        if([model hasSuffix:@"Simulator"]) {
//            NSLog(@"Simutator");
//            [self loadPhotosSimulator:callbackBlock];
//            return;
//        }
//        
//    } else if (systemVersion > 9.f) {
//        if (TARGET_OS_SIMULATOR) {
//            NSLog(@"Simutator");
//            [self loadPhotosSimulator:callbackBlock];
//            return;
//
//        }
//    }
    
    
    if (self.isContinue) {
        [self.app crashlyticsLog:@"***Continue***"];
    } else {
        [self.app crashlyticsLog:@"***StarLoad***"];
    }
    
    
    __block BOOL isExecute = NO;
    
    /// Массив обектов ALAsset
    NSMutableArray *datas = [NSMutableArray array];
    
    
    
    
    
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if(result != NULL && [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] && [result defaultRepresentation]) {
            [datas addObject:result];
        }
    };
    
    
    
    /// Стартовый блок загрузки фоток
    void (^StartLoadingPhotoBlock)(ALAssetsGroup *group, NSInteger groupAssetsCount, NSString *groupName) = ^(ALAssetsGroup *group, NSInteger groupAssetsCount, NSString *groupName) {
        // Первая загрузка фоток ***StratLoading***
        if (groupAssetsCount <= MAX_ASSET_COUNT) {
            // Добавляем всю группу, т.к
            [self.assetsGroups setValue:[NSNumber numberWithInteger:Done] forKey:groupName];
            [group enumerateAssetsUsingBlock:assetEnumerator];
            
            // В первой папке фоток > max
        } else if (groupAssetsCount > MAX_ASSET_COUNT) {
            [self.assetsGroups setValue:[NSNumber numberWithInteger:Progress] forKey:groupName];
            self.assetsRange = NSMakeRange(datas.count, MAX_ASSET_COUNT);
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:self.assetsRange];
            [group enumerateAssetsAtIndexes:set options:0 usingBlock:assetEnumerator];
            
        }
    };
    
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
//        if (!group) {
//            if (callbackBlock) {
//                callbackBlock(datas, nil);
//            }
//        }
        
        if(group != nil && !isExecute) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
//            NSLog(@"groupName: %@; Count: %li", [group valueForProperty:ALAssetsGroupPropertyName], (long)group.numberOfAssets);
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            NSUInteger groupAssetsCount = group.numberOfAssets;
            
//            if (!groupName) {
//                if (callbackBlock) {
//                    callbackBlock(datas, nil);
//                }
//                return;
//            }
            
            BOOL isDoneGroup = [self isGroupName:groupName isDone:self.assetsGroups];
            //
//            if (isExecute) {
//                if (callbackBlock) {
//                    callbackBlock(datas, nil);
//                }
//                return;
//            }
            
            
            // Проверяем была ли группа
            if (![self.assetsGroups objectForKey:groupName]) {
                // Группа не была, делаем "DontUse"
                [self.assetsGroups setValue:[NSNumber numberWithInteger:DontUse] forKey:groupName];
            }
            
            
            NSLog(@"Before: %@", self.assetsGroups);
            
            if (!isDoneGroup) {
            if (self.isContinue && !isExecute) {
                // Продолжение загрузки
                NSString *groupNameProgress = [self groupNameProgress:self.assetsGroups];
//                NSString *groupNameDontUse = [self groupNameDontUse:self.assetsGroups];
                
                // Если группа фоток уже используется
                if ([groupNameProgress isEqualToString:groupName]) {
                    self.assetsRange = [self compareGroupName:groupName andAssetsCount:groupAssetsCount andPreviousRange:self.assetsRange];
                    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:self.assetsRange];
                    //
//                    NSString *logText = [NSString stringWithFormat:@"Progress:Set.count: %i; Range: %@; GroupCount: %i", (int)set.count, NSStringFromRange(self.assetsRange), (int)group.numberOfAssets];
//                    [self.app crashlyticsLog:logText];
                    NSLog(@"Progress:Set.count: %i; Range: %@; GroupCount: %i", (int)set.count, NSStringFromRange(self.assetsRange), (int)group.numberOfAssets);
                    [group enumerateAssetsAtIndexes:set options:0 usingBlock:assetEnumerator];
                
                    // Если группа фоток еще не использовалась
                } else/* if ([groupNameDontUse isEqualToString:groupName]) */{
                    // Все тоже самое что и первой загрузке
                    StartLoadingPhotoBlock(group, groupAssetsCount, groupName);
                }

            } else {
                // Первая загрузка фоток
                StartLoadingPhotoBlock(group, groupAssetsCount, groupName);
            }
            
            NSLog(@"After: %@\n\n", self.assetsGroups);
            
            
            
            // Проверяем закончилась ли группа фоток
//            if (self.assetsRange.location == groupAssetsCount - self.assetsRange.length) {
//                // Значит группа фоток закончилась
//                [self.assetsGroups setValue:[NSNumber numberWithInteger:Done] forKey:groupName];
//            }
            
            /// Все ли группы закрыты
            BOOL isAllDone = [self isAllGroupsDone:self.assetsGroups];
            
            // Проверяем >= MAX_ASSET_COUNT || Возможно фоток очень мало во все папках
            if (datas.count >= MAX_ASSET_COUNT || isAllDone) {
                if (callbackBlock && !isExecute) {
                    isExecute = YES;
                    callbackBlock(datas, nil);
                }
            }
            }
        }
    };
    
    
    [_assetLibrary enumerateGroupsWithTypes: ALAssetsGroupSavedPhotos | ALAssetsGroupAll | ALAssetsGroupLibrary
                           usingBlock:assetGroupEnumerator
                         failureBlock: ^(NSError *error) {
                             if (callbackBlock) {
                                 callbackBlock(@[], error);
                             }
                         }];
    
    
}


//-(void)loadPhotosSimulator:(void (^)(NSArray *, NSError *))callbackBlock {
//    NSMutableArray *datas = [NSMutableArray array];
//    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
//        
//        if(result != NULL) {
//            [datas addObject:result];
//        }
//    };
//    
//    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
//        if(group != nil) {
//            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//            [group enumerateAssetsUsingBlock:assetEnumerator];
//        }
//    };
//    
//    
//    [_assetLibrary enumerateGroupsWithTypes:/*ALAssetsGroupSavedPhotos| ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupLibrary | ALAssetsGroupAll |*/ ALAssetsGroupSavedPhotos | ALAssetsGroupAll | ALAssetsGroupLibrary
//                                 usingBlock:assetGroupEnumerator
//                               failureBlock: ^(NSError *error) {
//                                   NSLog(@"Failure");
//                               }];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (callbackBlock) {
//            callbackBlock(datas, nil);
//        }
//    });
//}



- (BOOL) isAllAssetsAddedDictionary:(NSDictionary *)dictionary {
    BOOL result = YES;
    
    for (NSString *key in dictionary.allKeys) {
        AssetAdded groupType = (AssetAdded)[[dictionary objectForKey:key] integerValue];
        if (groupType != Done) {
            result = NO;
        }
    }
    
    return result;
}


- (NSString *) groupNameProgress:(NSMutableDictionary *)dictionary {
    NSString *group = @"";
    for (NSString *key in dictionary.allKeys) {
        AssetAdded groupType = (AssetAdded)[[dictionary objectForKey:key] integerValue];
        if (groupType == Progress) {
            group = key;
        }
    }
    
    return group;
}
- (NSString *) groupNameDontUse:(NSMutableDictionary *)dictionary {
    NSString *group = @"";
    
    for (NSString *key in dictionary.allKeys) {
        AssetAdded groupType = (AssetAdded)[[dictionary objectForKey:key] integerValue];
        if (groupType == DontUse) {
            group = key;
        }
    }
    
    return group;
}

- (BOOL) isGroupName:(NSString *)groupName isDone:(NSMutableDictionary *)dictionary {
    for (NSString *key in dictionary.allKeys) {
        AssetAdded groupType = (AssetAdded)[[dictionary objectForKey:key] integerValue];
        if (groupType == Done && [key isEqualToString:groupName]) {
            return YES;
        }
    }
    return NO;
}


- (BOOL) isAllGroupsDone:(NSDictionary *)dictionary {
    if (dictionary.allKeys.count == 0) {
        return NO;
    }
    
    BOOL result = YES;
    
    for (NSString *key in dictionary.allKeys) {
        AssetAdded groupType = (AssetAdded)[[dictionary objectForKey:key] integerValue];
        if (groupType != Done) {
            result = NO;
        }
    }
    
    return result;
}







- (NSRange) compareGroupName:(NSString *)groupName andAssetsCount:(NSUInteger)assetsGroupCount andPreviousRange:(NSRange)previousRange {
    NSRange range;
    
    if (previousRange.location + (MAX_ASSET_COUNT*2) <= assetsGroupCount) {
        range = NSMakeRange(previousRange.location + MAX_ASSET_COUNT, MAX_ASSET_COUNT);
        [self.assetsGroups setValue:[NSNumber numberWithInteger:Progress] forKey:groupName];

    } else {
        range = NSMakeRange(previousRange.location + MAX_ASSET_COUNT, assetsGroupCount - previousRange.location - MAX_ASSET_COUNT);
        [self.assetsGroups setValue:[NSNumber numberWithInteger:Done] forKey:groupName];
    }
    
    return range;
}

- (void) libraryTimeoutBlock:(void (^)(NSArray *, NSError *))successBlock {
    if (successBlock) {
        successBlock(nil, [NSError errorWithDomain:@"Error" code:1 userInfo:@{@"ErrorKey":@"Library TImeout"}]);
    }
}



#pragma mark - Property
- (void) updateAssetsGroups:(NSMutableDictionary *)assetsGroups {
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
//        if(group != nil) {
//            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//            [group enumerateAssetsUsingBlock:assetEnumerator];
//        }
        
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if (groupName) {
            if (![assetsGroups objectForKey:groupName]) {
                // Группа не была, делаем "DontUse"
                [assetsGroups setValue:[NSNumber numberWithInteger:DontUse] forKey:groupName];
            }
        }
    };
    
    
    
    [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:assetGroupEnumerator
                               failureBlock:nil];
}


-(BOOL)isContinue {
    BOOL isEmpty = self.assetsGroups.allKeys.count == 0;
    if (isEmpty) {
        return NO;
    }
    
    BOOL isAllDone = [self isAllGroupsDone:self.assetsGroups];
    if (isAllDone) {
        return NO;
    }
    
    BOOL isContinueResult = self.assetsGroups.allKeys.count > 0 ? YES : NO;
    return isContinueResult;
}

-(AppDelegate *)app {
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    return app;
}

-(NSError *)errorNotAutorized {
    NSError *error = [NSError errorWithDomain:@"Local" code:1 userInfo:@{PHOTO_LIBRARY_ERROR_KEY:NSLocalizedString(@"need_access_to_photolibrary", nil)}];
    return error;
}

- (NSData *)imageDataWithALAssetRepresentation:(ALAssetRepresentation*)representation {
    Byte *buffer = (Byte*)malloc(representation.size);
    NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
    NSData *imageAssetData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return imageAssetData;
}

#pragma mark - UnitTest
- (void)loadPhotoWithSize:(CGSize)size andOrientation:(UIImageOrientation)assetOrientation withSuccessBlock:(void (^)(NSData *imageData, NSError *))successBlock {
    // Проверяем доступ
    if (![MDPhotoLibrary isAuthorized]) {
        if (successBlock) {
            successBlock(nil, self.errorNotAutorized);
        }
        return;
    }
    
    // Нашли ли значение
    static BOOL isFinded = NO;
    
    
    // **************
    // Получаем фотки удовлетворяющие значениям
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != NULL && ![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] && [result defaultRepresentation] && !isFinded) {
            NSDictionary *metadata = result.defaultRepresentation.metadata;
            NSInteger imageWidth = [[metadata objectForKey:@"PixelWidth"] integerValue];
            NSInteger imageHeight = [[metadata objectForKey:@"PixelHeight"] integerValue];
            ALAssetOrientation orientation = (ALAssetOrientation)[[metadata objectForKey:@"Orientation"] integerValue];
            
            if (orientation == (ALAssetOrientation)assetOrientation && imageWidth >= size.width && imageHeight >= size.height) {
                isFinded = YES;
                if (successBlock) {
                    ALAssetRepresentation *rep = result.defaultRepresentation;
                    NSData *imageAssetData = [self imageDataWithALAssetRepresentation:rep];
                    successBlock(imageAssetData, nil);
                }
            } else {
                NSLog(@"Fail: Orientation: %i; width: %i x %i", (int)orientation, (int)imageWidth, (int)imageHeight);
            }
        }
    };
    
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil && !isFinded) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    
    
    [_assetLibrary enumerateGroupsWithTypes:/*ALAssetsGroupSavedPhotos| ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupLibrary | ALAssetsGroupAll |*/ ALAssetsGroupSavedPhotos | ALAssetsGroupAll | ALAssetsGroupLibrary
                                 usingBlock:assetGroupEnumerator
                               failureBlock: ^(NSError *error) {
                                   if (successBlock) {
                                       successBlock(nil, error);
                                   }
                               }];
    // *****************
}

-(void)loadPhotoDatasCount:(NSUInteger)photosCount withSize:(CGSize)size andOrientation:(NSInteger)assetOrientation withSuccessBlock:(void (^)(NSArray *, NSError *))successBlock {

    [self loadPhotoALAssetsCount:photosCount withSize:size andOrientation:assetOrientation withSuccessBlock:^(NSArray *assets, NSError *error) {
        /// Массив сбора данных
        NSMutableArray *resultImageDatas = [NSMutableArray array];
        
        
        for (ALAsset *result in assets) {
            ALAssetRepresentation *rep = result.defaultRepresentation;
            NSData *imageAssetData = [self imageDataWithALAssetRepresentation:rep];
            [resultImageDatas addObject:imageAssetData];
        }
    
        if (successBlock) {
            successBlock([resultImageDatas copy], nil);
        }
    }];
}

-(void)loadPhotoALAssetsCount:(NSUInteger)photosCount withSize:(CGSize)size andOrientation:(NSInteger)assetOrientation withSuccessBlock:(void (^)(NSArray *, NSError *))successBlock {
    // Проверяем доступ
    if (![MDPhotoLibrary isAuthorized]) {
        if (successBlock) {
            successBlock(nil, self.errorNotAutorized);
            successBlock = nil;
        }
        return;
    }
    
    /// Массив сбора данных
    NSMutableArray *resultAssets = [NSMutableArray array];
    
    /// Нашли ли значение
    __block BOOL isFinished = NO;
    
    // Timeout
    /*NSTimer *libraryTimeout = */[NSTimer md_scheduledTimerWithTimeInterval:20 block:^{
        if (!isFinished) {
            [self libraryTimeoutBlock:successBlock];
        }
    } repeats:NO];
    
    
    // **************
    // Получаем фотки удовлетворяющие значениям
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != NULL && ![[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] && [result defaultRepresentation] && !isFinished) {
            NSDictionary *metadata = result.defaultRepresentation.metadata;
            NSInteger imageWidth = [[metadata objectForKey:@"PixelWidth"] integerValue];
            NSInteger imageHeight = [[metadata objectForKey:@"PixelHeight"] integerValue];
            ALAssetOrientation orientation = (ALAssetOrientation)[[metadata objectForKey:@"Orientation"] integerValue];
            
            if ((orientation == (ALAssetOrientation)assetOrientation || assetOrientation == -1) && imageWidth >= size.width && imageHeight >= size.height) {
                NSLog(@"ADD");
//                ALAssetRepresentation *rep = result.defaultRepresentation;
//                NSData *imageAssetData = [self imageDataWithALAssetRepresentation:rep];
                [resultAssets addObject:result];
                
            } else {
                NSLog(@"Fail: Orientation: %i; width: %i x %i", (int)orientation, (int)imageWidth, (int)imageHeight);
            }
        }
        
        if (resultAssets.count == photosCount && !isFinished) {
            isFinished = YES;
            if (successBlock) {
//                static dispatch_once_t onceToken;
//                dispatch_once(&onceToken, ^{
                    successBlock([resultAssets copy], nil);
//                });
            }
        }
    };
    
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil && !isFinished) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetEnumerator];
        }
    };
    
    
    [self.assetLibrary enumerateGroupsWithTypes:/*ALAssetsGroupSavedPhotos| ALAssetsGroupSavedPhotos | ALAssetsGroupAlbum | ALAssetsGroupLibrary | ALAssetsGroupAll |*/ ALAssetsGroupSavedPhotos | ALAssetsGroupAll | ALAssetsGroupLibrary
                                 usingBlock:assetGroupEnumerator
                               failureBlock: ^(NSError *error) {
                                   if (successBlock) {
                                       successBlock(nil, error);
                                   }
                               }];
    // *****************
}



- (void) loadAllAssets:(void (^)(NSInteger))completeBlock andErrorBlock:(void (^)(NSError *))errorBlock {
    __block NSInteger assetCount = 0;
    
//    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
//        if(result != NULL && [[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] && [result defaultRepresentation]) {
//            assetCount++;
//        }
//    };

    
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
//            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//            [group enumerateAssetsUsingBlock:assetEnumerator];
            
            //            NSLog(@"groupName: %@; Count: %li", [group valueForProperty:ALAssetsGroupPropertyName], (long)group.numberOfAssets);
            NSUInteger groupAssetsCount = group.numberOfAssets;
            
            assetCount += groupAssetsCount;
        }
        
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if (!groupName) {
            if (completeBlock) {
                completeBlock(assetCount);
            }
        }
    };
    
    
    
    [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupAll | ALAssetsGroupPhotoStream
                                 usingBlock:assetGroupEnumerator
                               failureBlock: ^(NSError *error) {
                                   if (errorBlock) {
                                       errorBlock(error);
                                   }
                               }];
}




#pragma mark - Methods
-(void)getAssetWithURL:(NSString *)url withResultBlock:(void (^)(NSData *, UIImageOrientation))completeBlock failBlock:(void (^)(NSError *))failBlock {
    // Проверяем доступ
    if (![MDPhotoLibrary isAuthorized]) {
        if (failBlock) {
            failBlock(self.errorNotAutorized);
        }
        return;
    }
    
    
    NSURL *urlLib = [NSURL URLWithString:url];
    [_assetLibrary assetForURL:urlLib resultBlock:^(ALAsset *asset) {
        if (completeBlock) {
            ALAssetRepresentation *rep = asset.defaultRepresentation;
            NSData *imageAssetData = [self imageDataWithALAssetRepresentation:rep];
            completeBlock(imageAssetData, (UIImageOrientation)rep.orientation);
        }
    } failureBlock:^(NSError *error) {
        if (failBlock) {
            failBlock(error);
        }
    }];
}

-(void)saveImageToPhotoLibrary:(UIImage *)image andImageOrientation:(UIImageOrientation)orientation withSuccessBlock:(void (^)(NSString *))successBlock failBlock:(void (^)(NSError *))failBlock {
    __weak MDPhotoLibrary *wSelf = self;
    
    /// Блок Добавления сохраненной картинки в нужную группу и возвращаем результат по всему методу
    void (^AddSaveAssetToGroup)(ALAssetsGroup *group, NSURL *savedUrl) = ^(ALAssetsGroup *group, NSURL *savedUrl) {
        [wSelf.assetLibrary assetForURL:savedUrl resultBlock:^(ALAsset *asset) {
            [group addAsset:asset];
            if (successBlock) {
                successBlock([asset.defaultRepresentation.url absoluteString]);
            }
        } failureBlock:nil];
    };
    
    
    /// Блок сохранения картинки в группе
    void (^SaveImageToGroup)(UIImage *image, ALAssetsGroup *group) = ^(UIImage *image, ALAssetsGroup *group) {
        [wSelf.assetLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)orientation completionBlock:^(NSURL *assetURL, NSError *error) {
            // Проверяем
            if (error) {
                if (failBlock) {
                    failBlock(error);
                }
            } else {
                // Забираем эту картинку и добавляем к папке
                AddSaveAssetToGroup(group, assetURL);
            }
        }];
        
        
//        NSMutableDictionary *mData = [NSMutableDictionary dictionary];
//        [wSelf.assetLibrary writeImageDataToSavedPhotosAlbum:image.CGImage metadata:mData completionBlock:^(NSURL *assetURL, NSError *error) {
//            // Проверяем
//            if (error) {
//                if (failBlock) {
//                    failBlock(error);
//                }
//            } else {
//                // Забираем эту картинку и добавляем к папке
//                AddSaveAssetToGroup(group, assetURL);
//            }
//        }];
    };
    
    
    
    // Начало отсюда, создаем папку
    [self.assetLibrary addAssetsGroupAlbumWithName:PHOTO_LIBRARY_GROUP_ALBUM_NAME resultBlock:^(ALAssetsGroup *group) {
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if (groupName) {
            // Группу фоток только создали
            // После успешного создания папки, сохраняем картинку
            SaveImageToGroup(image, group);
            
        } else {
            // Группа фоток уже существует
            [wSelf getGroupName:PHOTO_LIBRARY_GROUP_ALBUM_NAME andCompleteBlock:^(ALAssetsGroup *group, NSError *error) {
                if (!error) {
                    SaveImageToGroup(image, group);
                } else {
                    if (failBlock) {
                        failBlock(error);
                    }
                }
            }];
        }
        
    } failureBlock:^(NSError *error) {
        if (failBlock) {
            failBlock(error);
        }
    }];
}


- (void) getGroupName:(NSString *)groupName andCompleteBlock:(void(^)(ALAssetsGroup *group, NSError *error))complateBlock {
    
    __block BOOL isFinished = NO;
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
        NSString *currentGroup = [group valueForProperty:ALAssetsGroupPropertyName];
        NSLog(@"CompareGroups: %@ == %@", groupName, currentGroup);
        if ([currentGroup isEqualToString:groupName]/* && !isFinished*/) {
            isFinished = YES;
            if (complateBlock) {
                complateBlock(group, nil);
            }
        }
    };
    
    
    [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:assetGroupEnumerator
                               failureBlock: ^(NSError *error) {
                                   if (complateBlock) {
                                       complateBlock(nil, error);
                                   }
                               }];
}

-(CGSize)imageSizeWithMetaData:(NSDictionary *)metaData {
    NSInteger imageWidth = [[metaData objectForKey:@"PixelWidth"] integerValue];
    NSInteger imageHeight = [[metaData objectForKey:@"PixelHeight"] integerValue];
//    ALAssetOrientation orientation = (ALAssetOrientation)[[metaData objectForKey:@"Orientation"] integerValue];
    
    return CGSizeMake(imageWidth, imageHeight);
}

@end
