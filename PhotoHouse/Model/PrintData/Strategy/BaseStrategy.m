//
//  BaseStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "BaseStrategy.h"

#import "StoreItem.h"
#import "PropType.h"

#import "PropSize.h"
#import "PropUturn.h"
#import "PropCover.h"
#import "PropStyle.h"
#import "PropColor.h"

@implementation BaseStrategy

- (id)initWithHistoryOrderItemsDictionary:(NSDictionary *)order_items
{
    self = [super init];
    if (self) {
        [self parseOrderItem:order_items];
    }
    return self;
}



- (id) initWithStoreItem:(StoreItem *)storeItem
{
    self = [super init];
    if (self) {
        _storeItem = storeItem;
        _count = 1;
    }
    return self;
}



#pragma mark - Methods(Private)
- (void) parseOrderItem:(NSDictionary *)order_items
{
    //
    self.storeItem = [[StoreItem alloc] initWithHistoryOrderItems:order_items];
    
    self.count = [[order_items objectForKey:@"item_num"] integerValue];
    
    //
    NSArray *order_images = [order_items objectForKey:@"images"];
    [self makeImagesWithDictionaryImages:order_images];
}



- (void) makeImagesWithDictionaryImages:(NSArray *)order_images
{
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *imageDictionary in order_images) {
        PrintImage *printImage = [[PrintImage alloc] initWithHistoryOrderDictionary:imageDictionary];
        [images addObject:printImage];
    }
    
    self.images = images;
}



#pragma mark - Public (Getter)
-(PhotoHousePrint)print_id
{
    return (PhotoHousePrint)[_storeItem.purchaseID integerValue];
}


-(UIImage *)showcaseImage
{
    return nil;
}



- (NSArray *) imagesURLs
{
    NSMutableArray *urls = [NSMutableArray array];
    for (PrintImage *printInmage in _images) {
        [urls addObject:printInmage.uploadURL];
    }
    return [urls copy];
}



-(NSUInteger)price
{
    NSUInteger cost = [_storeItem price];
    
    // Если фотопечать, то за каждую фотку после 20-й, берем 10 руб
    if (_print_id == PhotoHousePrintPhoto10_13 || _print_id == PhotoHousePrintPhoto10_15 || _print_id == PhotoHousePrintPhoto13_18 ||
        _print_id == PhotoHousePrintPhoto15_21 || _print_id == PhotoHousePrintPhoto20_30 || _print_id == PhotoHousePrintPhoto8_10)
    {
        cost += _images.count - 20 > 0 ? 10 * (_images.count - 10) : 0;
    }
    
    return cost * _count;
}



-(void)changeProp:(NSObject *)object {
    PropType *propType = [self.storeItem.types firstObject];
    
    if ([object isKindOfClass:[PropUturn class]]) {
        [propType setSelectPropUturn:(PropUturn*)object];
    }
    else if ([object isKindOfClass:[PropSize class]]) {
        [propType setSelectPropSize:(PropSize*)object];
    }
    else if ([object isKindOfClass:[PropCover class]]) {
        [propType setSelectPropCover:(PropCover*)object];
    }
    else if ([object isKindOfClass:[PropStyle class]]) {
        [propType setSelectPropStyle:(PropStyle*)object];
    }
    else if ([object isKindOfClass:[PropColor class]]) {
        [propType setSelectPropColor:(PropColor*)object];
    }
}


- (void) changeCount:(NSInteger)count
{
    _count = count;
}


-(NSDictionary *)props
{
    return [NSDictionary dictionary];
}


#pragma mark - Mege Images
-(void)setMergedImages:(NSArray *)mergedImages
{
    // Создаем массив с обычными фотографиями
    NSMutableArray *array = [NSMutableArray array];
    
    for (PrintImage *printImage in _images) {
        if (!printImage.isMergedImage) {
            [array addObject:printImage];
        }
    }
    
    //
    [array addObjectsFromArray:mergedImages];
    
    //
    _images = [array copy];
}



- (NSArray *)mergedImages
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (PrintImage *printImage in _images) {
        if (printImage.isMergedImage) {
            [array addObject:printImage];
        }
    }

    return [array copy];
}



#pragma mark - Preview
- (NSArray *)imagesPreview
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (PrintImage *printImage in _images) {
        if (!printImage.isMergedImage) {
            [array addObject:printImage];
        }
    }
    
    return [array copy];
}


-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
    return [NSArray array];
}


-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock
{
    if (completeBlock) {
        completeBlock([NSArray array]);
    }
    
    if (progressBlock) {
        progressBlock(0.f);
    }
}


@end
