//
//  VkontakteAccessToken.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/12/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VkontakteAccessToken : NSObject
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *email;

+ (VkontakteAccessToken*) initializeWithArrayTokenKeys:(NSArray*)keys;
@end
