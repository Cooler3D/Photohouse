//
//  VkontakteAPIModel.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/12/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "VkontakteAPIModel.h"
#import "VkontakteAccessToken.h"
#import "VKontakeImageData.h"


#import "AFNetworking.h"


NSString *const APP_ID          = @"4502030";
NSString *const PERMISSIONS     = @"friends,video,offline,photos";
NSString *const REDIRECT_URI    = @"https://oauth.vk.com/blank.html";
NSString *const DISPLAY_API     = @"mobile";
NSString *const VERSION_API     = @"5.0";


NSInteger const IMAGES_COUNT    = 20;   // Загружаем по ... картинок


@interface VkontakteAPIModel () <UIWebViewDelegate>
@property (strong, nonatomic) VkontakteAccessToken *token;
@property (weak, nonatomic) UIWebView *webView;

@property (assign, nonatomic) NSInteger images_offset;  // Смещение для картинок
@end



@implementation VkontakteAPIModel

+(VkontakteAPIModel*)sharedManager {
    static VkontakteAPIModel *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VkontakteAPIModel alloc] init];
    });
    
    return instance;
}

#pragma mark - Public Methods
-(void) autorizationInWebView:(UIWebView*)webView {
    NSString *fullURL = [self getAuthURL];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView setDelegate:self];
    [webView loadRequest:requestObj];
    //[webView setHidden:YES];
    
    self.webView = webView;
}

- (void)vKontaktePhotosGetAll
{
    // Offset
    self.images_offset += IMAGES_COUNT;
    
    // https://api.vk.com/method/'''METHOD_NAME'''?'''PARAMETERS'''&access_token='''ACCESS_TOKEN'''
    NSString *path = [NSString stringWithFormat:@"https://api.vk.com/method/photos.getAll?owner_id=%@&extended=0&count=%li&photo_sizes=0&no_service_albums=1&access_token=%@", self.token.user_id, (long)self.images_offset, self.token.accessToken];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        //NSLog(@"Page= %@", [[NSString alloc] initWithData:[operation responseData] encoding:NSWindowsCP1251StringEncoding]);
        [self parsePhotos:[operation responseData]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
    [operation start];
}


#pragma mark - Private Methods
- (NSString*) getAuthURL {
    /*https://oauth.vk.com/authorize?
    client_id=APP_ID&
    scope=PERMISSIONS&
    redirect_uri=REDIRECT_URI&
    display=DISPLAY&
    v=API_VERSION&
    response_type=token*/
    NSString *url = [NSString stringWithFormat:@"https://oauth.vk.com/authorize?client_id=%@&scope=%@&redirect_uri=%@&display=%@&v=%@&response_type=token", APP_ID, PERMISSIONS, REDIRECT_URI, DISPLAY_API, VERSION_API];
    
    return url;
}

- (void) parsePhotos:(NSData*)photosData {
    NSMutableArray *photos = [NSMutableArray array];
    
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:photosData options:kNilOptions error:nil];
    
    
    //NSLog(@"all: %@", [dictionary allKeys]);
    
    NSArray *array = [dictionary objectForKey:@"response"];
    
    //NSDictionary *dict = [array objectAtIndex:0];
    
    for (NSDictionary *photo in array) {
        if ([photo isKindOfClass:[NSDictionary class]]) {
            //NSLog(@"%@", [photo objectForKey:@"src_xbig"]);
            VKontakeImageData *data = [[VKontakeImageData alloc] initWithDataDictionary:photo];
//            [photos addObject:data];
            [photos addObject:data.normalQualityURL];
            /*NSString *bestQualityUrl = [photo objectForKey:@"src_xxbig"];
            if (bestQualityUrl) {
                [photos addObject:bestQualityUrl];
            } else {
                [photos addObject:[photo objectForKey:@"src_xbig"]];
            }*/
        }
    }
    
    //NSLog(@"dictionary: %@", dictionary);
    
    [self.delegate vKontaktePhotoList:photos];
}




#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString* urlString = [[request URL] absoluteString];
    
    //[self authWithURL:urlString];
    NSLog(@"url: %@", urlString);
    
    // Нашли access_token
    if ([urlString rangeOfString:@"access_token="].location != NSNotFound) {
        urlString = [urlString substringFromIndex:[urlString rangeOfString:@"access_token="].location];
        NSArray *keys = [urlString componentsSeparatedByString:@"&"];
        
        NSLog(@"%@", keys);
        VkontakteAccessToken *access = [VkontakteAccessToken initializeWithArrayTokenKeys:keys];
        self.token = access;
        self.webView.delegate = nil;
        [self.delegate authenticationComplete];
        [self vKontaktePhotosGetAll];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.delegate vKontakteWebViewDidLoaded];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView.didFailLoadWithError: %@", [error localizedDescription]);
    if ([[error localizedDescription] isEqualToString:@"The Internet connection appears to be offline."] || [[error localizedDescription] isEqualToString:@"The request timed out."]) {
        [self.delegate vKontakteError:[error localizedDescription]];
    }
}

@end
