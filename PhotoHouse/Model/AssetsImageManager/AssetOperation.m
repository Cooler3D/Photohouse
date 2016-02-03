//
//  AssetOperation.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 19/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoRecord.h"
#import "AssetOperation.h"
#import "MDPhotoLibrary.h"

@interface AssetOperation ()
@property (weak, nonatomic) id<AssetOperationDelegate> delegate;
//@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSArray *saverUrls;
@property (strong, nonatomic) ALAsset *asset;
@end

@implementation AssetOperation
-(id)initWithAsset:(ALAsset *)asset andIndexPath:(NSIndexPath *)indexPath andCompareSavedUrls:(NSArray *)savedUrls andDelegate:(id<AssetOperationDelegate>)delegate {
    self = [super init];
    if (self) {
        _asset = asset;
        _indexPath = indexPath;
        _saverUrls = savedUrls;
        _delegate = delegate;
    }
    return self;
}

-(void)main {
    @autoreleasepool {
        if (self.cancelled) {
            return;
        }
        
        ALAsset *asset = _asset;
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
        
        NSDictionary *metadata = asset.defaultRepresentation.metadata;
        MDPhotoLibrary *pLibrary = [[MDPhotoLibrary alloc] init];
        CGSize imageSize = [pLibrary imageSizeWithMetaData:metadata];
        ALAssetOrientation aOrientation = representation.orientation;
        CGSize imageOrientationSize = (aOrientation == ALAssetOrientationLeft || aOrientation == ALAssetOrientationRight) ? CGSizeMake(imageSize.height, imageSize.width) : imageSize;
        
        PhotoRecord *record = [[PhotoRecord alloc] initAssetThumbal:asset.thumbnail andNameUrlLibary:[representation.url absoluteString] andDate:date andImageSize:imageOrientationSize];//[[PhotoRecord alloc] initWithAsset:_asset];
        BOOL selected = [self compareAssetName:record.name andSaved:_saverUrls];
        [record setSelected:selected];

        if (self.cancelled) {
            return;
        }
        
        if ([_delegate respondsToSelector:@selector(assetOperation:didAddImage:)]) {
            [self.delegate assetOperation:self didAddImage:record];
        }
    }
}


- (BOOL)compareAssetName:(NSString *)nameAsset andSaved:(NSArray *)savedUrls {
    for (NSString *beforeName in savedUrls) {
        if ([beforeName isEqualToString:nameAsset]) {
            return YES;
        }
    }
    return NO;

}
@end
