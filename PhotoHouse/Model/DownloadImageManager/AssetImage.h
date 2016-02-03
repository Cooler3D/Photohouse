//
//  AssetImage.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 28/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface AssetImage : NSObject
@property (strong, nonatomic, readonly) UIImage *thumbnail;
@property (strong, nonatomic, readonly) NSString *urlPathLibrary;
@property (strong, nonatomic, readonly) NSDate *date;

- (id) initWithThumbal:(CGImageRef)image;
@end
