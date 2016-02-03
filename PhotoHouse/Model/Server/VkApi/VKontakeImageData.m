//
//  VKontakeImageData.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/6/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "VKontakeImageData.h"

@interface VKontakeImageData ()
@property (strong, nonatomic, readonly) NSString *bestQualityURL;      // Лучшее качество
@end

@implementation VKontakeImageData



- (id) initWithDataDictionary:(NSDictionary*)dictionary {
    
    self = [super init];
    
    if (self) {
        _normalQualityURL = [dictionary objectForKey:@"src_xbig"];
        _bestQualityURL = [dictionary objectForKey:@"src_xxbig"];
        
        if (_bestQualityURL) {
            _normalQualityURL = _bestQualityURL;
        }
    }
    
    return self;
    
}



@end
