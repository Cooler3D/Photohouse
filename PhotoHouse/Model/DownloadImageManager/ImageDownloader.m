//
//  ImageDownloader.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ImageDownloader.h"
#import "AFNetworking.h"

#import "CoreDataSocialImages.h"


@interface ImageDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@property (assign, nonatomic) BOOL coreDataUse;
@end



@implementation ImageDownloader
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize photoRecord = _photoRecord;

#pragma mark -
#pragma mark - Life Cycle

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate andCoreDataUse:(BOOL)coreDataUse {
    
    if (self = [super init]) {
        // 2: Set the properties.
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
        self.coreDataUse = coreDataUse;
    }
    return self;
}

#pragma mark -
#pragma mark - Downloading image

// 3: Regularly check for isCancelled, to make sure the operation terminates as soon as possible.
-(void)main {
    // 4: Apple recommends using @autoreleasepool block instead of alloc and init NSAutoreleasePool, because blocks are more efficient. You might use NSAuoreleasePool instead and that would be fine.
    @autoreleasepool {
        NSLog(@"ImageDownloader.start: %@", _photoRecord.name);
        if (self.isCancelled) {
            return;
        }
        
        // Read To CoreData
        CoreDataSocialImages *coreModel = [[CoreDataSocialImages alloc] init];
        
        // Если CoreData используется, т.е идет сохранение фоток в корзину, то не обращаемся
        NSData *socailImageData = nil;// = self.coreDataUse ? nil : [coreModel getImageDataWithURL:[self.photoRecord.URL absoluteString]];
        NSData *imageData = socailImageData == nil ? [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL] : socailImageData;
        
//        if (self.photoRecord.importFromLibrary == ImportLibraryPhone) {
//            ALAsset *asset = self.photoRecord.asset;
//            [self.photoRecord setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
//        }
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage;
        }
        else if(self.photoRecord.importFromLibrary != ImportLibraryPhone) {
            self.photoRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled) {
            return;
        }
        
        
        // Save To CoreData && CoreData не используется
        if(self.photoRecord.importFromLibrary != ImportLibraryPhone && !self.coreDataUse) {
//            [coreModel saveImage:self.photoRecord.image withURL:[self.photoRecord.URL absoluteString] andLibraryType:self.photoRecord.importFromLibrary];
            [coreModel savePhotoRecord:self.photoRecord];
        }
        
        // 5: Cast the operation to NSObject, and notify the caller on the main thread.
        //[(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            if ([self.delegate respondsToSelector:@selector(imageDownloaderDidFinish:)]) {
                 [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
//            }
        });
        //[self.delegate imageDownloaderDidFinish:self];
    }
}
@end
