//
//  VkontakteAPIModel.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/12/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VKontakteDelegate;


/*!
 \brief Взаимодействие с Api Вконтакте\n
 Использует классы: VKontakeImageData, VkontakteAccessToken
 \warning Требуется рефакторинг
 \author Дмитрий Мартынов
 */
@interface VkontakteAPIModel : NSObject
/// Singleton
+(VkontakteAPIModel*)sharedManager;

@property (weak, nonatomic) id<VKontakteDelegate> delegate;

/// Аторизуемся через WebView
-(void) autorizationInWebView:(UIWebView*)webView;

/// Получаем картинки
-(void) vKontaktePhotosGetAll;
@end


  
  
@protocol VKontakteDelegate <NSObject>
@required
- (void) authenticationComplete;

@optional
- (void) vKontaktePhotoList:(NSArray*)photos;
- (void) vKontakteWebViewDidLoaded;
- (void) vKontakteError:(NSString*)errorText;
@end