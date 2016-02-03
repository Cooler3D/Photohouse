//
//  JsonAuth.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 28/06/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "Json.h"

@interface JsonAuth : Json
- (id) initAuthEMail:(NSString *)login andPasswordHash:(NSString *)passwordHash;
@end
