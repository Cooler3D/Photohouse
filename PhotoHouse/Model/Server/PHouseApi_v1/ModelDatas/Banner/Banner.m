//
//  Banner.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "Banner.h"



NSString *const IMAGE_URL_KEY = @"image_url";
NSString *const ACTION_URL_KEY = @"action_url";


@implementation Banner
- (id) initWitDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _imageUrl = [NSString stringWithFormat:@"http://s01.photohouse.info/serv/%@", [dictionary objectForKey:IMAGE_URL_KEY]];
        _actionUrl = [dictionary objectForKey:ACTION_URL_KEY];
    }
    return  self;
}



- (id) initWithActionUrl:(NSString *)actionUrl andImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _actionUrl = actionUrl;
        _image = image;
    }
    return self;
}



- (void) loadImage
{
    @autoreleasepool {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:_imageUrl]];
        
        if (imageData) {
            _image = [UIImage imageWithData:imageData];
            [self getInternalID];
        }
    }
}


- (BOOL)hasImage
{
    if (_image == nil) {
        return NO;
    }
    
    return YES;
}



- (StoreType) getInternalID
{
    NSInteger loc = [_actionUrl rangeOfString:@"http://"].location;
    if (loc == NSNotFound) {
        // Internal
        //NSInteger purchaseID = [self parseInternal:_actionUrl];
        //StoreType stType = [self getStoreWithPurchseID:(PrintServerObjects)purchaseID];
        return 1;
    } else {
        // Http
        return StoreTypeSovenir;
    }
    return StoreTypeSovenir;
}


- (NSInteger) parseInternal:(NSString *)url {
    NSInteger loc = [url rangeOfString:@"://"].location;
    NSString *purchaseId = [url copy];
    
    if (loc != NSNotFound) {
        purchaseId = [purchaseId substringFromIndex:loc+3];
        
        loc = [purchaseId rangeOfString:@"/"].location;
        if (loc != NSNotFound) {
            purchaseId = [purchaseId substringToIndex:loc];
            return [purchaseId integerValue];
        }
    }
    
    return [purchaseId integerValue];
}

/*
- (StoreType) getStoreWithPurchseID:(PrintServerObjects)serverObj {
    switch (serverObj) {
        case PrintObjectPhoto8_10:
        case PrintObjectPhoto10_13:
        case PrintObjectPhoto10_15:
        case PrintObjectPhoto13_18:
        case PrintObjectPhoto15_21:
        case PrintObjectPhoto20_30:
            return StoreTypePhotoPrint;
            break;
        case PrintObjectMouseMag:
        case PrintObjectClock:
        case PrintObjectPlate:
        case PrintObjectHolst:
        case PrintObjectPuzzle:
        case PrintObjectTShirt:
        case PrintObjectMug:
        case PrintObjectBrelok:
        case PrintObjectDelivery:
            return StoreTypeSovenir;
            break;
            
            
            
        case PrintObjectAlbum:
            return StoreTypePhotoAlbum;
            break;
        
        case PrintObjectIPhone4:
        case PrintObjectIPhone5:
        case PrintObjectIPhone6:
        case PrintObjectMagnit:
            return StoreTypeCoverCase;
            break;
            
    
    }
    
    return StoreTypeSovenir;

}*/
@end
