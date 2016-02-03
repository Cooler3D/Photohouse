//
//  ResponseAlbum.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "ResponseAlbum.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"




NSString *const Template_Key = @"templates";
NSString *const Layouts_Key = @"layouts";



typedef enum {
    StatusDownLoadImages,
    StatusDownLoadImage
} StatusDownLoad;


typedef void (^TemplatesLoadBlock)(NSArray *);


@interface ResponseAlbum () <ImageDelegate>
@property (assign, nonatomic) NSInteger imageCount;
@property (strong, nonatomic) NSArray *images;

@property (strong, nonatomic) Template *currenttemplate;
@property (assign, nonatomic) NSInteger templateCount;
@property (copy, nonatomic) TemplatesLoadBlock templateBlock;
@end



@implementation ResponseAlbum

#pragma mark - Init
-(id)initWitParseData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}

- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error || !result) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
    NSArray *templatesDictionary = [result objectForKey:Template_Key];
    
    NSMutableArray *templates = [NSMutableArray array];
    for (NSDictionary *templateDictionary in templatesDictionary) {
        Template *template = [[Template alloc] initTemplateDictionary:templateDictionary];
        [templates addObject:template];
    }
    
    self.templates = [templates copy];
    if (self.templateBlock) {
        self.templateBlock(self.templates);
    }
}

-(id)initWitParseData:(NSData *)data andBlock:(void (^)(NSArray *))completeBlock
{
    self = [super init];
    if (self) {
        self.templateBlock = completeBlock;
        [self parse:data];
    }
    return self;
}


#pragma mark - Private
//- (void) parse:(NSData *)data
//{
//    NSError *localError = nil;
//    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
//    if (localError) {
//        NSLog(@"Error");
//    }
//
//    NSArray *templatesDictionary = [parsedObject objectForKey:Template_Key];
//    //NSDictionary *layoutsDictionary = [parsedObject objectForKey:Layouts_Key];
//    
//    NSMutableArray *templates = [NSMutableArray array];
//    for (NSDictionary *templateDictionary in templatesDictionary) {
//        Template *template = [[Template alloc] initTemplateDictionary:templateDictionary];
//        [templates addObject:template];
//        //self.templateAlbum = template;
//    }
//    
//    self.templates = [templates copy];
//    if (self.templateBlock) {
//        self.templateBlock(self.templates);
//    }
//    return;
//    
//#warning ToDo: Photo don't load
//    _templateCount = templates.count;
//    self.currenttemplate = [self.templates objectAtIndex:self.templateCount-1];
//    // Start Download Image
//    [self downloadImage:self.currenttemplate];
//}



#pragma mark - Download
- (void) downloadImage:(Template *)template
{
    _imageCount = 0;
    NSMutableArray *array = [NSMutableArray array];
    
    for (Layout *layout in template.layouts) {
        /*for (Image *image in layout.backLayer.images) {
            [array addObject:image];
        }
        for (Image *image in layout.frontLayer.images) {
            [array addObject:image];
        }*/
        
        [array addObject:layout.backLayer.image];
        [array addObject:layout.frontLayer.image];
        [array addObject:layout.clearLayer.image];
    }
    
    //
    self.images = [array copy];
    if (array.count > 0) {
        [self startDownload:[self.images objectAtIndex:_imageCount]];
    }
}



- (void) startDownload:(Image *)image
{
    _imageCount++;
    [image startDownloadImage:self];
}



#pragma mark - ImageDelegate
-(void)image:(Image *)imageObj didDownLoadComplate:(UIImage *)image
{
    imageObj.delegate = nil;
    NSLog(@"Template.DownLoad.Complete");
    
    if (_imageCount >= _images.count - 1) {
        if (![self isCompleteLoadingTemplate:self.currenttemplate]) {
            return;
        }
        
        if (_templateCount <= 0) {
            // Finish All Tempates
            // Save
//            CoreDataAlbumConstructor *coreConstructor = [[CoreDataAlbumConstructor alloc] init];
//            [coreConstructor saveTemplates:self.templates];
//            
//            // Notificate
//            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.currenttemplate forKey:TemaplateKey];
//            NSNotification *notification = [NSNotification notificationWithName:TemaplateNotification object:nil userInfo:userInfo];
//            [[NSNotificationCenter defaultCenter] postNotification:notification];
            if (self.templateBlock) {
                self.templateBlock(self.templates);
            }
        } else {
            // Load Previous
            self.templateCount--;
            self.currenttemplate = [self.templates objectAtIndex:self.templateCount];
            [self downloadImage:self.currenttemplate];
        }
        
        //
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.templateAlbum forKey:TemaplateKey];
//        NSNotification *notification = [NSNotification notificationWithName:TemaplateNotification object:nil userInfo:userInfo];
//        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else
    {
        [self startDownload:[_images objectAtIndex:_imageCount]];
    }
}

-(void)image:(Image *)imageObj didFailWithError:(NSError *)error
{
    
}


#pragma mark - Check
/*! Все картинки загрузились,
 *@return возвращаем YES все хорошо, No какие то не загрузились
 */
- (BOOL) isCompleteLoadingTemplate:(Template *)template
{
    NSMutableArray *failImages = [NSMutableArray array];
    
    for (Image *image in self.images) {
        if (![image hasImage]) {
            [failImages addObject:image];
            NSLog(@"Fail Load image Constructor: %@", image.url_image);
        }
    }
    
    self.imageCount = 0;
    self.images = [failImages copy];
    [self startDownload:[self.images firstObject]];
    
    return failImages.count > 0 ? NO : YES;
}
@end
