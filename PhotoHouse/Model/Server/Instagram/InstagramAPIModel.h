//
//  InstagramAPIModel.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>


@class InstagramAccessToken;

@protocol InstagramSDKDelegate;


/*!
 \brief Взаимодействие с Api Instagram
 \warning Требуется рефакторинг
 \author Дмитрий Мартынов
 */
@interface InstagramAPIModel : NSObject
@property (weak, nonatomic) id<InstagramSDKDelegate> delegate;

/// Singleton
+(InstagramAPIModel*) sharedManager;


/// Вызываем авторизацию через WebView
/*! Через WebView нужно отправить запрос
 *@param webView уже должен быть добавлен на контроллере
 
 */
-(void) autorizationInWebView:(UIWebView*)webView;


/// Запрашиваем картинки
/*! Запрашиваем картинки или по жеткой ссылке
 *@param user_id идетификатор пользователя
 *@param nextStrongUrl адрес для следующей партии загрузки фотографий
 */
-(void) instagramLoadPhotoArrayWithUserID:(NSString*)user_id orStrongURL:(NSString*)nextStrongUrl;

/// Загружаем следующую партию фотографий
-(void) instagramNextPhotosLoad;
@end



@protocol InstagramSDKDelegate <NSObject>
@required
- (void) instagramTokenHasExpired:(InstagramAccessToken *)expiredToken;

@optional
- (void) instagramPhotoList:(NSArray*)photos;

- (void) instagramShowWebViewWithAnimate;
- (void) instagramHideWebViewWithAnimate;
- (void) instagramWebViewDidLoad;

- (void) instagramError:(NSString*)errorText;
@end
