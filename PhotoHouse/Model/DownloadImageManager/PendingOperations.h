//
//  PendingOperations.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject
@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end
