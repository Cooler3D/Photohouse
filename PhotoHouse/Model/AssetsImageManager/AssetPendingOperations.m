//
//  AssetPendingOperations.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 19/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "AssetPendingOperations.h"

@implementation AssetPendingOperations
-(NSOperationQueue *)assetQueue {
    if (!_assetQueue) {
        _assetQueue = [[NSOperationQueue alloc] init];
        [_assetQueue setName:@"Asset Queue"];
        [_assetQueue setMaxConcurrentOperationCount:1];
    }
    return _assetQueue;
}

-(NSMutableDictionary *)asssetInProgress {
    if (!_asssetInProgress) {
        _asssetInProgress = [[NSMutableDictionary alloc] init];
    }
    
    return _asssetInProgress;
}
@end
