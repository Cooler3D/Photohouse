//
//  AssetPendingOperations.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 19/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetPendingOperations : NSObject
@property (strong, nonatomic) NSMutableDictionary *asssetInProgress;
@property (strong, nonatomic) NSOperationQueue *assetQueue;
@end
