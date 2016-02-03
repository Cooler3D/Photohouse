//
//  ImageManager.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "LoadImageManager.h"

#import "AFNetworking.h"

#import "CoreDataSocialImages.h"


@implementation LoadImageManager
- (void) loadImageWithURL:(NSURL *)url
       usingCompleteBlock:(void(^)(UIImage *image))completeBlock
            progressBlock:(void(^)(CGFloat progress))progressBlock
               errorBlock:(void(^)(NSError *error))errorBlock
{
    CoreDataSocialImages *coreImages = [[CoreDataSocialImages alloc] init];
    UIImage *image = [coreImages getImageWithURL:[url absoluteString]];
    
    if (image != nil) {
        if (completeBlock) {
            completeBlock(image);
        }
    }
    else
    {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Block
            UIImage *img = responseObject;
            
            //CoreDataSocialImages *coreImages = [[CoreDataSocialImages alloc] init];
            [coreImages saveImage:img withURL:[url absoluteString] andLibraryType:4];
            
            if (completeBlock) {
                completeBlock(img);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (errorBlock) {
                errorBlock(error);
            }
        }];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            double percentDone = (double)totalBytesRead / (double)totalBytesExpectedToRead;
            if (progressBlock) {
                progressBlock(percentDone);
            }

        }];
        
        [operation start];
    }
}

@end
