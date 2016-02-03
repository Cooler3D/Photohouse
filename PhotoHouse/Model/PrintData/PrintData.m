//
//  PrintData.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/14/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PrintData.h"

#import "BaseStrategy.h"
#import "IPhone6Strategy.h"
#import "IPhone5Strategy.h"
#import "MugStrategy.h"
#import "PhotoPrintStrategy.h"
#import "TShirtStrategy.h"
#import "PuzzleStrategy.h"
#import "PlateStrategy.h"
#import "MouseMagStrategy.h"
#import "MagnitStrategy.h"
#import "HolstStrategy.h"
#import "ClockStrategy.h"
#import "AlbumStrategy.h"
#import "BrelokStrategy.h"
#import "IPhone4Strategy.h"
#import "DeliveryStrategy.h"

#import "Template.h"

#import "UniqueNum.h"

#import "CoreDataShopCart.h"

@interface PrintData ()
@property (strong, nonatomic) BaseStrategy *strategy;
@end



@implementation PrintData
{
    NSInteger _unique_print;
}


#pragma mark - Init
- (id) initWithHistoryOrderItemsDictionary:(NSDictionary *)order_items
{
    self = [super init];
    if (self) {
        [self parseOrderItem:order_items];
    }
    return self;
}




- (id) initWithStoreItem:(StoreItem *)storeItem andUniqueNum:(NSInteger)unique
{
    self = [super init];
    if (self) {
        _unique_print = unique;
        [self initStratategy:storeItem];
    }
    return self;
}





#pragma mark - Methods(Getter)
-(PhotoHousePrint)purchaseID {
    return [_strategy print_id];
}



- (NSString *) namePurchase {
    return [_strategy.storeItem namePurchase];
}


-(NSDictionary *)props  {
    return [_strategy props];
}


-(NSUInteger)price      {
    return [_strategy price];
}


-(NSUInteger)count      {
    return [_strategy count];
}


-(NSArray *)images      {
    return [_strategy images];
}



- (NSArray *) uploadURLs
{
    return [_strategy imagesURLs];
}


- (UIImage *) iconShopCart
{
    return [self.storeItem iconShopCart];
}


- (UIImage *) gridImage
{
    return self.storeItem.gridImage;
}


- (UIImage *) showCaseImage
{
    return [_strategy showcaseImage];
}


-(NSInteger)unique_print
{
    _unique_print = _unique_print == 0 ? [UniqueNum getUniqueID] : _unique_print;
    return _unique_print;
}

- (void) changeProp:(NSObject *)object
{
    [_strategy changeProp:object];
}

- (void) changeCount:(NSInteger)count
{
    [_strategy changeCount:count];
}

- (StoreItem *)storeItem
{
    return [_strategy storeItem];
}

- (NSString *) nameType
{
    return _strategy.storeItem.propType.name;
}


- (NSString *) nameCategory
{
    return _strategy.storeItem.categoryName;
}


- (NSArray *)imagesPreview
{
    return [_strategy imagesPreview];
}


-(NSArray *)imagesNames
{
    NSMutableArray *images = [NSMutableArray array];
    for (PrintImage *image in self.imagesPreview) {
        [images addObject:image.urlLibrary];
    }
    return images;
}


-(NSArray *)mergedImages {
    return [_strategy mergedImages];
}


- (void) addPrintImagesFromPhotoLibrary:(NSArray *)array
{
    //[_strategy.images arrayByAddingObjectsFromArray:array];
    if (array.count == 0) {
        return;
    }
    
    //_strategy.images = array;
    if (_strategy.images.count == 0) {
        _strategy.images = array;
    } else {
        NSMutableArray *mutable = [_strategy.imagesPreview mutableCopy];
        [mutable addObjectsFromArray:array];
        _strategy.images = mutable;
    }
}


-(void)removeAllImages
{
    _strategy.images = [NSArray array];
}


- (void) removeImagesWithUrls:(NSArray *)urls
{
    /// Блок поиска удаляемой картинки в массиве сохраненных в объекте, возвращаем индекс. Если -1, то не найдено. Если >= 0, то значение в массиве
    int (^GetIndexWithSavedImages)(NSString *, NSMutableArray *) = ^(NSString *removeUrl, NSMutableArray *savedImages) {
        NSPredicate *prediate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", removeUrl];
        PrintImage *printImage = [[savedImages filteredArrayUsingPredicate:prediate] firstObject];
        if (!printImage) {
            return -1;
        } else {
            NSInteger index = [savedImages indexOfObject:printImage];
            return (int)index;
        }
    };
    
    // Filtred
    NSMutableArray *mutableImages = [_strategy.imagesPreview mutableCopy];
    NSMutableIndexSet *mutableSet = [NSMutableIndexSet indexSet];
    for (NSString *removeUrl in urls) {
        NSInteger index = GetIndexWithSavedImages(removeUrl, mutableImages);
        if (index >= 0) {
            [mutableSet addIndex:index];
        }
    }
    
    // Remove
    [mutableImages removeObjectsAtIndexes:mutableSet];
    _strategy.images = [mutableImages copy];
}


-(void)updateUserTemplate:(Template *)userTemplate
{
    [_strategy.storeItem.propType updateUserTemplate:userTemplate];
}


- (void) addMergedImages:(NSArray *)merged
{
    [_strategy setMergedImages:merged];
}



- (void) replacePreviewPrintImage:(PrintImage *)printImage
{
    // Если это скленная картинка, то не добавляем
    if (printImage.isMergedImage) {
        return;
    }
    
    NSMutableArray *mutableAray = [_strategy.images mutableCopy];
    BOOL imageFinded = NO;
    
    for (int imageIndex = 0; imageIndex < mutableAray.count; imageIndex++) {
        PrintImage *image = [mutableAray objectAtIndex:imageIndex];
        if ([image.urlLibrary isEqualToString:printImage.urlLibrary]) {
            imageFinded = YES;
            [mutableAray replaceObjectAtIndex:imageIndex withObject:printImage];
        }
    }
    
    if (!imageFinded) {
        NSLog(@"Image Do not finded");
        return;
    }
    
    
    _strategy.images = [mutableAray copy];
    
}


- (void) createAndAddMergedImageWithPrintImage:(UIImage *)image
{
    if (self.purchaseID == PhotoHousePrintMug) {
        [_strategy createMergedImageWithPreview:image andCompleteBlock:^(NSArray *images) {
            CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
            [coreShop saveMergedPreviewPrintData:self withPrintImages:images];
        } andProgressBlock:nil];
    }
    else {
        NSArray *mergedPrintImages = [_strategy createAndAddMergedImage:image];
        [self addMergedImages:mergedPrintImages];
    
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop saveMergedPreviewPrintData:self withPrintImages:mergedPrintImages];
    }
}



-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock
{
    [_strategy createMergedImageWithPreview:previewImage andCompleteBlock:^(NSArray *images) {
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop saveMergedPreviewPrintData:self withPrintImages:images];
        
        [self addMergedImages:images];
        
        if (completeBlock) {
            completeBlock(images);
        }
    } andProgressBlock:progressBlock];
}


#pragma mark - Methods(Private)
- (void) initStratategy:(StoreItem *)storeItem {
    
    PhotoHousePrint purchaseID = (PhotoHousePrint)[storeItem.purchaseID integerValue];
    
    switch (purchaseID) {
        case PhotoHousePrintIPhone6:
            _strategy = [[IPhone6Strategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintIPhone5:
            _strategy = [[IPhone5Strategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintIPhone4:
            _strategy = [[IPhone4Strategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintMug:
            _strategy = [[MugStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintBrelok:
            _strategy = [[BrelokStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintAlbum:
            _strategy = [[AlbumStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintClock:
            _strategy = [[ClockStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintHolst:
            _strategy = [[HolstStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintMagnit:
            _strategy = [[MagnitStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintMouseMag:
            _strategy = [[MouseMagStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintPhoto10_13:
        case PhotoHousePrintPhoto10_15:
        case PhotoHousePrintPhoto13_18:
        case PhotoHousePrintPhoto15_21:
        case PhotoHousePrintPhoto20_30:
        case PhotoHousePrintPhoto8_10:
            _strategy = [[PhotoPrintStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintPlate:
            _strategy = [[PlateStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintPuzzle:
            _strategy = [[PuzzleStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintTShirt:
            _strategy = [[TShirtStrategy alloc] initWithStoreItem:storeItem];
            break;
            
        case PhotoHousePrintDelivery:
            _strategy = [[DeliveryStrategy alloc] initWithStoreItem:storeItem];
            break;
    }
}



- (void) parseOrderItem:(NSDictionary *)order_items
{
    PhotoHousePrint purchaseID = (PhotoHousePrint)[[order_items objectForKey:@"item_id"] integerValue];
    
    switch (purchaseID) {
        case PhotoHousePrintIPhone6:
            _strategy = [[IPhone6Strategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintIPhone5:
            _strategy = [[IPhone5Strategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
        
        case PhotoHousePrintIPhone4:
            _strategy = [[IPhone4Strategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintMug:
            _strategy = [[MugStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintBrelok:
            _strategy = [[BrelokStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintAlbum:
            _strategy = [[AlbumStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintClock:
            _strategy = [[ClockStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintHolst:
            _strategy = [[HolstStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintMagnit:
            _strategy = [[MagnitStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintMouseMag:
            _strategy = [[MouseMagStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintPhoto10_13:
        case PhotoHousePrintPhoto10_15:
        case PhotoHousePrintPhoto13_18:
        case PhotoHousePrintPhoto15_21:
        case PhotoHousePrintPhoto20_30:
        case PhotoHousePrintPhoto8_10:
            _strategy = [[PhotoPrintStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintPlate:
            _strategy = [[PlateStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintPuzzle:
            _strategy = [[PuzzleStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintTShirt:
            _strategy = [[TShirtStrategy alloc] initWithHistoryOrderItemsDictionary:order_items];
            break;
            
        case PhotoHousePrintDelivery:
            break;
    }
}

@end