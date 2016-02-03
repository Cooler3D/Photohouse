//
//  InstagramAPIModel.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "InstagramAPIModel.h"
#import "InstagramAccessToken.h"
#import "AFNetworking.h"


NSString* INSTAGRAM_CLIENT_ID       =       @"c1d84b8a2a66451fa9c463db5f67cd07";//@"704f6652ad444e80aa9b2d7c794fe591";
NSString* INSTAGRAM_CLIENT_SECRET   =       @"1ef7e313523f40729043c5fd1897cf94";//@"fd02a519583f4602a81e349d20965be9";
NSString* INSTAGRAM_REDIRECT_URL    =       @"http://localhost:8888/MAMP/";

NSString* INSTAGRAM_AUTH_URL        =       @"https://instagram.com/oauth/authorize/";
NSString* INSTAGRAM_SEARCH_URL      =       @"https://api.instagram.com/v1/users/search?q=";



@interface InstagramAPIModel () <UIWebViewDelegate>
@property (strong, nonatomic) InstagramAccessToken *token;

@property (weak, nonatomic) UIWebView *webView;

@property (strong, nonatomic) NSMutableArray *photosURL;

@property (strong, nonatomic) NSString *nextPhotosURL;
@end



@implementation InstagramAPIModel

#pragma mark - Singleton
+(InstagramAPIModel*) sharedManager {
    static InstagramAPIModel *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[InstagramAPIModel alloc] init];
    });
    
    return instance;
}




#pragma mark - Private Methods
- (void) loadAuthWithCode:(NSString *)code
{
    // Формируем строку
    NSString *post = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@",INSTAGRAM_CLIENT_ID, INSTAGRAM_CLIENT_SECRET, INSTAGRAM_REDIRECT_URL, code];
    
    // Кодируем данные
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Длина запроса
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    // Запрос
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    // Загружаем из интеренета
    // При помощи библиотеки AFNetworking
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Загрузка завершена
        //NSLog(@"Page login= %@", [[NSString alloc] initWithData:[operation responseData] encoding:NSWindowsCP1251StringEncoding]);
        [self parseTokenJSON:[operation responseData]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Ошибка
        NSLog(@"error auth");
    }];
    
    [operation start];
}



- (void) parseTokenJSON:(NSData*)jsonData {
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    InstagramAccessToken *experiedToken = [InstagramAccessToken initWithDictionary:dictionary];
    if (experiedToken.accessToken) {
        self.token = experiedToken;
        [self.delegate instagramTokenHasExpired:experiedToken];
    }
}


// Парсим найденного пользователя
/*- (NSArray*) parseSearchJSON:(NSData*)jsonData {
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    //NSLog(@"dictionary: %@", dictionary);
    
    //NSArray *news = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    for (NSString *key in [dictionary allKeys]) {
        if ([key isEqualToString:@"data"]) {
            //NSDictionary *dataDictionary = [dictionary objectForKey:key];
            
            //NSLog(@"dataDictionary: %@", [dataDictionary objectForKey:@"username"]);
            
            NSArray *dataArray = [dictionary objectForKey:key];
            
            for (int i=0; i<[dataArray count]; i++) {
                //NSLog(@"keyData: %@", [dataArray objectAtIndex:0]);
                
                NSDictionary *dict = [dataArray objectAtIndex:i];
                NSLog(@"username: %@", [dict objectForKey:@"full_name"]);
            }
        }
    }
    
    return array;
}*/



- (void) parseImagesJSON:(NSData*)data andIsNeedAdded:(BOOL)isAddedImage {
    
    if (!isAddedImage) {
        _photosURL = [NSMutableArray array];
    }
    
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    //NSLog(@"dictionary: %@", dictionary);
    
    //
    for (NSString *key in [dictionary allKeys]) {

        // data
        if ([key isEqualToString:@"data"]) {
            NSArray *dataArray = [dictionary objectForKey:key];
            
            //NSLog(@"array: %@", dataArray);
            
            for (int i=0; i<[dataArray count]; i++) {
                NSDictionary *dict = [dataArray objectAtIndex:i];
                //NSLog(@"dict: %@", [dict objectForKey:@"images"]);
                NSDictionary *dictionaryStandart = [dict objectForKey:@"images"];
                //NSLog(@"std: %@", [dictionaryStandart objectForKey:@"standard_resolution"]);
                NSDictionary *dictionaryUrl = [dictionaryStandart objectForKey:@"standard_resolution"];
                
                [_photosURL addObject:[dictionaryUrl objectForKey:@"url"]];
            }
        }
        
        // pagination
        if ([key isEqualToString:@"pagination"]) {
            NSDictionary *pagination = [dictionary objectForKey:key];
            
            NSString *nextUrl = [pagination objectForKey:@"next_url"];
            NSLog(@"nextUrl: %@", nextUrl);
            _nextPhotosURL = nextUrl;
            
            //[self instagramLoadPhotoArrayWithUserID:@"" orStrongURL:nextUrl];
            
        }
    }
    
    [self.delegate instagramPhotoList:_photosURL];
}



- (NSString*) getAuthURL {
    NSString *url = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=code", INSTAGRAM_AUTH_URL, INSTAGRAM_CLIENT_ID, INSTAGRAM_REDIRECT_URL];
    
    return url;
}




- (void) authWithURL:(NSString*)urlString {
    NSRange codeParam = [urlString rangeOfString: @"code="];
    if (codeParam.location != NSNotFound) {
        NSString* code = [urlString substringFromIndex: NSMaxRange(codeParam)];
        
        // If there are more args, don't include them in the token:
        NSRange endRange = [code rangeOfString: @"&"];
        if (endRange.location != NSNotFound)
            code = [code substringToIndex: endRange.location];
        
        //NSLog(@"access token %@; string: %@", code, urlString);
        if ([code length] > 0 ) {
            [self loadAuthWithCode:code];
        }
    }
    else {
        // Handle the access rejected case here.
        NSLog(@"rejected case, user denied request: %@", urlString);
        
        
        if ([urlString rangeOfString:@"next=/oauth/authorize/"].location != NSNotFound) {
            NSLog(@"Open Auth Dialog");
            [self.delegate instagramShowWebViewWithAnimate];
        }
    }
}



// Ищем пользователя
/*- (void) searchInInstagramNameUser:(NSString*)name completeBlock:(void(^)(NSArray *arrayUsers))completeBlock {
    NSString *path = [NSString stringWithFormat:@"%@%@&access_token=%@", INSTAGRAM_SEARCH_URL, name, self.token.accessToken];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Complete
        NSLog(@"Request= %@", [[NSString alloc] initWithData:[operation responseData] encoding:NSWindowsCP1251StringEncoding]);
 
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Error
        NSLog(@"%@", error);
    }];
    [operation start];
}*/



#pragma mark - Public Methods
-(void) instagramNextPhotosLoad {
    [self instagramLoadPhotoArrayWithUserID:@"" orStrongURL:_nextPhotosURL];
}




- (void) instagramLoadPhotoArrayWithUserID:(NSString*)user_id orStrongURL:(NSString*)nextStrongUrl
{
    NSString *path;
    if ([nextStrongUrl isEqualToString:@""]) {
        path = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@", user_id, self.token.accessToken];
    } else {
        path = nextStrongUrl;
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Complete
        //NSLog(@"Request= %@", [[NSString alloc] initWithData:[operation responseData] encoding:NSWindowsCP1251StringEncoding]);
        
        [self parseImagesJSON:[operation responseData] andIsNeedAdded:[nextStrongUrl isEqualToString:@""] ? NO : YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Error
    }];
    [operation start];
}

-(void) autorizationInWebView:(UIWebView*)webView {
    NSString *fullURL = [self getAuthURL];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView setDelegate:self];
    [webView loadRequest:requestObj];
//    [webView setHidden:YES];
    
    self.webView = webView;
}



#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString* urlString = [[request URL] absoluteString];
    
    [self authWithURL:urlString];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
    [self.delegate instagramWebViewDidLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error.didFailLoadWithError: %@", [error localizedDescription]);
    if ([[error localizedDescription] isEqualToString:@"The Internet connection appears to be offline."] || [[error localizedDescription] isEqualToString:@"The request timed out."]) {
        [self.delegate instagramError:[error localizedDescription]];
    }
}

@end
