//
//  PendingOperations.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations
@synthesize downloadsInProgress = _downloadsInProgress;
//@synthesize downloadQueue = _downloadQueue;


- (NSMutableDictionary *)downloadsInProgress {
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download Queue";
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

@end
