//
//  ImageDownloader.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoRecord.h"


@protocol ImageDownloaderDelegate;


@interface ImageDownloader : NSOperation
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;

// 3: Declare indexPathInTableView for convenience so that once the operation is finished, the caller has a reference to where this operation belongs to.
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) PhotoRecord *photoRecord;

// 4: Declare a designated initializer.
- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate andCoreDataUse:(BOOL)coreDataUse;

@end





@protocol ImageDownloaderDelegate <NSObject>

// 5: In your delegate method, pass the whole class as an object back to the caller so that the caller can access both indexPathInTableView and photoRecord. Because you need to cast the operation to NSObject and return it on the main thread, the delegate method canít have more than one argument.
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
@end
