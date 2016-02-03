//
//  AssetOperation.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 19/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoRecord;
@class ALAsset;
@protocol AssetOperationDelegate;

@interface AssetOperation : NSOperation
- (id)initWithAsset:(ALAsset *)asset andIndexPath:(NSIndexPath *)indexPath andCompareSavedUrls:(NSArray *)savedUrls andDelegate:(id<AssetOperationDelegate>)delegate;


@property (strong, nonatomic, readonly) NSIndexPath *indexPath;
@end



@protocol AssetOperationDelegate <NSObject>

- (void)assetOperation:(AssetOperation *)operation didAddImage:(PhotoRecord *)record;

@end