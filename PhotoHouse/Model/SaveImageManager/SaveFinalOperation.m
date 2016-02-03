//
//  SaveFinalOperation.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/3/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "SaveFinalOperation.h"


#import "PrintData.h"
#import "PrintImage.h"

#import "CoreDataShopCart.h"

@interface SaveFinalOperation ()
@property (strong, nonatomic) PrintData *printData;
@end


@implementation SaveFinalOperation
-(id)initSaveWithPrintData:(PrintData *)printData andCurrentPrintImage:(PrintImage *)printImage andDelegate:(id<SaveFinalOperationDelegate>)delegate
{
    self = [super init];
    if (self) {
        _printData = printData;
        _printImage = printImage;
        _delegate = delegate;
    }
    return self;
}

-(void)startSave
{
//    @autoreleasepool {
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop savePrepareFinalPrintData:_printData andPrintImage:_printImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"finish %@", self.printImage.urlLibrary);
            [self.delegate saveFinalOperation:self didSavedImage:_printImage];
        });
//    }
}

@end
