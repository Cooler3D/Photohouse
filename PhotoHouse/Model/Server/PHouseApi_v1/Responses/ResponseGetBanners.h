//
//  GetBannersResponse.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@interface ResponseGetBanners : PHResponse
//- (NSArray *) bannersOnlyWithImages;     // Проверяем баннеры после загрузки картинок и возвращаем массив с готовыми

- (void) saveBanners;
@property (strong, nonatomic, readonly) NSArray *banners;
@property (assign, nonatomic, readonly) NSInteger interval;
@end
