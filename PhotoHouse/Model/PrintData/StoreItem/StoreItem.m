//
//  StoreItem.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/23/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "StoreItem.h"

#import "PropType.h"
#import "PropStyle.h"

#import "Fields.h"

#import "ItemInfoOrder.h"


NSString *const DESCRIPTION_KEY     = @"description";
//NSString *const TYPE_KEY            = @"type";
NSString *const ID_KEY              = @"id";
NSString *const NAME_KEY            = @"name";
NSString *const AVAILABILITY_KEY    = @"availability";
NSString *const CATEGORY_ID_KEY     = @"category_id";
NSString *const CATEGORY_NAME_KEY   = @"category_name";
NSString *const TYPES_KEY           = @"types";

@interface StoreItem ()
@property (assign, nonatomic) PhotoHousePrint print;
@end


@implementation StoreItem
@synthesize available = _available;


#pragma mark - Init
- (id) initStoreWithPurchaseID:(NSString *)purchaseID
                  andTypeStore:(NSString *)typeStore
           andDescriptionStory:(NSString *)descriptionStore
               andNamePurchase:(NSString *)namePurchase
                 andCategoryID:(NSString *)categoryID
               andCategoryName:(NSString *)categoryName
                  andAvailable:(BOOL)available
                      andTypes:(NSArray *)types
{
    self = [super init];
    if (self)
    {
        _available      = available;
        _purchaseID     = purchaseID;
        _typeStore      = typeStore;
        _descriptionStore = descriptionStore;
        _namePurchase   = namePurchase;
        _categoryID     = [categoryID integerValue];
        _categoryName   = categoryName;
        
        _types = types;
    }
    return self;
}


- (id) initDelivetyCity:(DeliveryCity *)delivery
{
    self = [super init];
    if (self)
    {
        _available = YES;
        _purchaseID = [NSString stringWithFormat:@"%i", PhotoHousePrintDelivery];
        _delivery = delivery;
    }
    return self;
}


-(id)initWithDictionary:(NSDictionary *)item
{
    self = [super init];
    if (self) {
        //
        _available      = [[item objectForKey:AVAILABILITY_KEY] isEqualToString:@"available"] ? YES : NO;
        _purchaseID     = [item objectForKey:ID_KEY];
        _typeStore      = [item objectForKey:FIELD_TYPE];
        _descriptionStore = [item objectForKey:DESCRIPTION_KEY];
        _namePurchase   = [item objectForKey:NAME_KEY];
        _categoryID     = [[item objectForKey:CATEGORY_ID_KEY] integerValue];
        _categoryName   = [item objectForKey:CATEGORY_NAME_KEY];
        
        NSArray *types = [item objectForKey:TYPES_KEY];
        [self parseTypes:types];
    }
    return self;
}



-(id)initWithHistoryOrderItems:(NSDictionary *)order_items
{
    self = [super init];
    if (self) {
        [self parseHistoryOrderItems:order_items];
    }
    return self;
}



#pragma mark - Public Get
- (NSUInteger) price
{
    return [[_types firstObject] price];
}


- (PhotoHousePrint)print
{
    PhotoHousePrint print = (PhotoHousePrint)[_purchaseID integerValue];
    return print;
}



#pragma mark - Images
- (UIImage *)iconStoreImage
{
    NSString *path;
    if (self.print == PhotoHousePrintPhoto8_10 || self.print == PhotoHousePrintPhoto20_30 || self.print == PhotoHousePrintPhoto15_21 ||
        self.print == PhotoHousePrintPhoto13_18 || self.print == PhotoHousePrintPhoto10_15 || self.print == PhotoHousePrintPhoto10_13)
    {
        path = [NSString stringWithFormat:@"icon_%@", _namePurchase];
    }
    else
    {
        path = [NSString stringWithFormat:@"icon_%@_%@_308", _purchaseID, self.propType.name];
    }
    return [UIImage imageNamed:path];
}


-(UIImage *)iconShopCart
{
    UIImage *image;
    switch (self.print) {
        case PhotoHousePrintIPhone5:
            image = [UIImage imageNamed:@"iPhone5_128"];
            break;
            
        case PhotoHousePrintIPhone6:
            image = [UIImage imageNamed:@"iPhone6_128"];
            break;
            
        case PhotoHousePrintIPhone4:
            image = [UIImage imageNamed:@"iPhone4_128"];
            break;
            
            
        case PhotoHousePrintBrelok:
            image = [UIImage imageNamed:@"trinket_128"];
            break;
            
        case PhotoHousePrintClock:
            image = [UIImage imageNamed:@"clock_128"];
            break;
            
        case PhotoHousePrintHolst:
            image = [UIImage imageNamed:@"canvas_128"];
            break;
            
            
        case PhotoHousePrintMouseMag:
            image = [UIImage imageNamed:@"mat_128"];
            break;
            
        case PhotoHousePrintPhoto10_13:
        case PhotoHousePrintPhoto10_15:
        case PhotoHousePrintPhoto13_18:
        case PhotoHousePrintPhoto15_21:
        case PhotoHousePrintPhoto20_30:
        case PhotoHousePrintPhoto8_10:
            image = [UIImage imageNamed:@"photo2"];
            break;
            
        case PhotoHousePrintPlate:
            image = [UIImage imageNamed:@"plate_128"];
            break;
            
        case PhotoHousePrintPuzzle:
            image = [UIImage imageNamed:@"puzzle_128"];
            break;
            
        case PhotoHousePrintTShirt:
            image = [UIImage imageNamed:@"T-shirt_128"];
            break;
            
        case PhotoHousePrintDelivery:
            
            break;
            
        case PhotoHousePrintAlbum:
            image = [self imageWithAlbum];
            break;
            
        case PhotoHousePrintMagnit:
            image = [self imageWithMagnit];
            break;
            
        case PhotoHousePrintMug:
            image = [self imageWithMug];
            break;
            
    }
    return image;
}

- (UIImage *) imageWithMug {
    PropType *propType = [self.types firstObject];
    UIImage *image;
    if ([propType.name isEqualToString:@"heart"])
    {
        image = [UIImage imageNamed:@"Mug2_128"];
    }
    else if ([propType.name isEqualToString:@"latte"])
    {
        image = [UIImage imageNamed:@"Mug1_128"];
    }
    else if ([propType.name isEqualToString:@"glass"])
    {
        image = [UIImage imageNamed:@"Mug4_128"];
    }
    else if ([propType.name isEqualToString:@"chameleon"])
    {
        image = [UIImage imageNamed:@"Mug3_128"];
    }
    else if ([propType.name isEqualToString:@"colored"])
    {
        image = [UIImage imageNamed:@"Mug_128"];
    }
    
    return image;
}

- (UIImage *) imageWithMagnit
{
    PropType *propType = [self.types firstObject];
    UIImage *image;
    if ([propType.name isEqualToString:@"heart"])
    {
        image = [UIImage imageNamed:@"magnet_heart_128"];
    }
    else
    {
        image = [UIImage imageNamed:@"magnet_128"];
    }
    
    return image;
}

- (UIImage *) imageWithAlbum
{
    PropType *propType = [self.types firstObject];
    NSString *path = [NSString stringWithFormat:@"store_style_%@", propType.selectPropStyle.styleName];
    UIImage *image = [UIImage imageNamed:path];
    return image;
}


- (UIImage *)gridImage
{
    NSString *xcassetName = [NSString stringWithFormat:@"grid_%@_%@", _purchaseID, self.propType.name];
    return [UIImage imageNamed:xcassetName];
}






#pragma mark - Private
- (void) parseHistoryOrderItems:(NSDictionary *)order_items
{
    _purchaseID = [order_items objectForKey:@"item_id"];
    
    // Category
    NSDictionary *itemInfoDict = [order_items objectForKey:@"item_info"];
    
    
    ItemInfoOrder *itemInfo = [[ItemInfoOrder alloc] initWithItemInfoOrder:itemInfoDict];
    _categoryName = itemInfo.categoryName;
    _namePurchase = itemInfo.name;
    
    
    PropType *propType;
    id propTypeDict = [order_items objectForKey:@"props"];
    if (![propTypeDict isKindOfClass:[NSArray class]])
    {
        NSString *propTypeName = [propTypeDict objectForKey:@"type"];
        NSString *propUturnName = [propTypeDict objectForKey:@"uturn"];
        NSString *propSizeName = [propTypeDict objectForKey:@"size"];
        NSString *propCoverName = [propTypeDict objectForKey:@"cover"];
        NSString *propStyleName = [propTypeDict objectForKey:@"style"];
        NSString *propColorName = [propTypeDict objectForKey:@"color"];
        
        propType = [[PropType alloc] initTypeName:propTypeName
                                         andPrice:itemInfo.price
                                      andSizeName:propSizeName
                                     andUturnName:propUturnName
                                     andCoverName:propCoverName
                                     andColorName:propColorName
                                     andStyleName:propStyleName
                                  andUserTemplate:nil];
    }
    else
    {
        propType = [[PropType alloc] initTypeName:@"default"
                                         andPrice:itemInfo.price
                                      andSizeName:nil
                                     andUturnName:nil
                                     andCoverName:nil
                                     andColorName:nil
                                     andStyleName:nil
                                  andUserTemplate:nil];
    }
    
    //
    _types = [NSArray arrayWithObject:propType];
}



/** Для магазина "get_items" */
- (void) parseTypes:(NSArray *)types
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *typeDict in types) {
        PropType *propType = [[PropType alloc] initWithDictionary:typeDict];
        [array addObject:propType];
    }
    
    _types = [array copy];
}



-(PropType *)propType {
    return [_types firstObject];
}



-(BOOL)isAvailable {
    return _available;
}
@end
