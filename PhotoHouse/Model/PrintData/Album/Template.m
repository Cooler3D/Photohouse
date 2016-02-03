//
//  Template.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"

// Notification
NSString *const DownloadAllImagesCompleteNotification   = @"DownloadAllImagesCompleteNotification";
NSString *const DownloadImagesProgessNotification       = @"DownloadImagesProgessNotification";

// Key
NSString *const DownloadImagesProgressKey               = @"DownloadImagesProgressKey";


// Extern
NSString *const TemplateDownloadComplateNotification    = @"TemplateDownloadComplateNotification";
NSString *const TemplateDownloadProgressNotification    = @"TemplateDownloadProgressNotification";
NSString *const TemplateDownloadErrorNotification       = @"TemplateDownloadErrorNotification";
NSString *const TemplateKey                             = @"TemplateKey";
NSString *const TemplateProgressKey                     = @"TemplateProgressKey";
NSString *const TemplateErrorKey                        = @"TemplateErrorKey";


#pragma mark TemplateDownload
/*!
 /brief Класс для загрузки картинок Images
 
 Данный класс последовательно загружает картинки разворотов, по окончании вызывает Notification
 
 /author Дмитрий Мартынов
 */
@interface TemplateDownload : NSObject <ImageDelegate>

/** Инициализируемся по шаблону
 *@param template шаблон для загрузки фотографии
 */
- (id) initTemplate:(Template *)template;



/** Начинаем загрузку */
- (void) start;
@end


@implementation TemplateDownload
{
    Template *_template;
    NSInteger _imageCount;
    NSArray *_images;
    NSMutableArray *_failArray;
}

#pragma mark Init
-(id)initTemplate:(Template *)template
{
    self = [super init];
    if (self) {
        _template = template;
        _imageCount = 0;
    }
    return self;
}

#pragma mark - Public
-(void)start
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (Layout *layout in _template.layouts) {
        NSLog(@"layout: %@; Template.size: %@; Template.style: %@", layout.id_layout, _template.size, _template.name);
        if (layout.backLayer.image.image == nil)  [array addObject:layout.backLayer.image];
        if (layout.frontLayer.image.image == nil) [array addObject:layout.frontLayer.image];
//        if (layout.clearLayer.image.image == nil) [array addObject:layout.clearLayer.image];
    }
    
    //
    _images = [array copy];
    if (array.count > 0) {
        [self startDownload:[_images objectAtIndex:_imageCount]];
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
    
//    if (_imageCount >= _images.count - 1) {
//        if (![self isCompleteLoadingTemplate:_template]) {
//            return;
//        }
//        
//        NSLog(@"Complete");
//        NSNotification *notification = [NSNotification notificationWithName:DownloadAllImagesCompleteNotification object:nil];
//        [[NSNotificationCenter defaultCenter] postNotification:notification];
//    }
//    else
//    {
//        [self startDownload:[_images objectAtIndex:_imageCount]];
//    }
//    
//    CGFloat progress = (float)_imageCount / (float)_images.count;
//    NSDictionary *userInfo = @{DownloadImagesProgressKey: [NSNumber numberWithFloat:progress]};
//    NSNotification *notification = [NSNotification notificationWithName:DownloadImagesProgessNotification object:nil userInfo:userInfo];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self calculateDowloading];
}

-(void)image:(Image *)imageObj didFailWithError:(NSError *)error
{
    if (!_failArray) {
        _failArray = [NSMutableArray array];
    }
    
    [_failArray addObject:imageObj.url_image];
    
//    if (_failArray.count >= _images.count || _imageCount >= _failArray.count) {
//        NSLog(@"Don't load all images");
//    } else {
        [self calculateDowloading];
//    }
}


- (void) calculateDowloading
{
    if (_imageCount >= _images.count - 1) {
        if (![self isCompleteLoadingTemplate:_template]) {
            return;
        }
        
        NSLog(@"CalculateDowloading.Complete");
        NSNotification *notification = [NSNotification notificationWithName:DownloadAllImagesCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else
    {
        [self startDownload:[_images objectAtIndex:_imageCount]];
    }
    
    CGFloat progress = (float)_imageCount / (float)_images.count;
    NSDictionary *userInfo = @{DownloadImagesProgressKey: [NSNumber numberWithFloat:progress]};
    NSNotification *notification = [NSNotification notificationWithName:DownloadImagesProgessNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


#pragma mark - Check
/*! Все картинки загрузились,
 *@return возвращаем YES все хорошо, No какие то не загрузились
 */
- (BOOL) isCompleteLoadingTemplate:(Template *)template
{
    NSMutableArray *failImages = [NSMutableArray array];
    
    for (Image *image in _images) {
        if (![image hasImage]) {
            [failImages addObject:image];
            NSLog(@"Fail Load image Constructor: %@", image.url_image);
        }
    }
    
    NSLog(@"Start Again");
    //[self startDownload:[_images firstObject]];
    
    NSInteger index = _images.count - _failArray.count - 1;
    if (index >= _images.count-1) {
        return YES;
    } else {
        NSString *text = [NSString stringWithFormat:@"%@ %li %@ %li %@", NSLocalizedString(@"Loaded", nil), (long)index, NSLocalizedString(@"of", nil), (long)_imageCount, NSLocalizedString(@"covers", nil)];
        NSDictionary *userInfo = @{TemplateErrorKey: text,
                                   TemplateKey: _template};
        NSNotification *notification = [NSNotification notificationWithName:TemplateDownloadErrorNotification object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    
//    _imageCount = 0;
//    _images = [failImages copy];
    
        return NO;
    }
    
//    return failImages.count > 0 ? NO : YES;
}
@end
#pragma mark  End Template Download -



#pragma mark Template
@implementation Template
#pragma mark Init
- (id) initTemplateDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _fontName   = [dictionary objectForKey:@"font"];
        _name       = [dictionary objectForKey:@"name"];
        _size       = [dictionary objectForKey:@"size"];
        _id_template = [dictionary objectForKey:@"id"];
        
        NSArray *layouts = [dictionary objectForKey:@"layouts"];
        [self parseLayouts:layouts];
    }
    return self;
}





- (id) initTemplateName:(NSString *)name andFontName:(NSString *)fontName andIdTemplate:(NSString *)id_template andSize:(NSString *)size andLayouts:(NSArray *)layouts
{
    self = [super init];
    if (self) {
        _fontName       = fontName;
        _name           = name;
        _id_template    = id_template;
        _size           = size;
        _layouts        = layouts;
    }
    return self;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public
-(BOOL)hasImageDesign
{
    BOOL result = YES;
    
    for (Layout *layout in self.layouts) {
        if (![layout.backLayer.image hasImage]) result = NO;
        if (![layout.frontLayer.image hasImage]) result = NO;
//        if (![layout.clearLayer.image hasImage]) result = NO;
    }
    
    return result;
}


-(NSArray *)getUserLayoutsDictionaries
{
    NSMutableArray *layoutsDict = [NSMutableArray array];
    for (Layout *layout in self.layouts) {
        [layoutsDict addObject:[layout layoutDictionary]];
    }
    return [layoutsDict copy];
}


-(NSDictionary *)getUserTemplateDictionary
{
    NSArray *layoutsDict = [self getUserLayoutsDictionaries];
    NSDictionary *uTemplateDictionary = @{@"font"   : self.fontName,
                                          @"name"   : self.name,
                                          @"id"     : self.id_template,
                                          @"size"   : self.size,
                                          @"layouts": [layoutsDict copy]};
    return uTemplateDictionary;
}


-(void)downloadImages
{
    // Add Notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationDownLoadImagesComplete:) name:DownloadAllImagesCompleteNotification object:nil];
    [nc addObserver:self selector:@selector(notificationDownLoadImagesProgress:) name:DownloadImagesProgessNotification object:nil];
    
    
    // Start DownLoad
    TemplateDownload *tDownload = [[TemplateDownload alloc] initTemplate:self];
    [tDownload start];
}


#pragma mark - Private
- (void) parseLayouts:(NSArray *)layouts
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *layout in layouts) {
        Layout *layoutObj = [[Layout alloc] initLayoutDictionary:layout];
        [array addObject:layoutObj];
    }
    
    _layouts = [array copy];
}


-(Layout *)layoutCover
{
    Layout *cover;
    for (Layout *layout in _layouts) {
        if ([layout.layoutType isEqualToString:LayoutCover]) {
            cover = layout;
            break;
        }
    }
    
    if (!cover) {
        cover = [_layouts firstObject];
    }
    
    return cover;
}


-(NSArray *)layoutPages
{
    NSMutableArray *mutable = [NSMutableArray array];
    for (Layout *layout in _layouts) {
        if ([layout.layoutType isEqualToString:LayoutPage]) {
            [mutable addObject:layout];
        }
    }
    
    // Выстраиваем последовательность
    [mutable sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Layout *first = (Layout *)obj1;
        Layout *second = (Layout *)obj2;
        
        if ([first.id_layout integerValue] > [second.id_layout integerValue]) {
            return NSOrderedDescending;
        } else if ([first.id_layout integerValue] < [second.id_layout integerValue]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    
    return [mutable copy];
}


#pragma mark - Notifications
- (void) notificationDownLoadImagesProgress:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat progress = [[userInfo objectForKey:DownloadImagesProgressKey] floatValue];
    
    NSDictionary *uInfo = @{TemplateProgressKey: [NSNumber numberWithFloat:progress > 1.f ? 1.f : progress]};
    NSNotification *noti = [NSNotification notificationWithName:TemplateDownloadProgressNotification object:nil userInfo:uInfo];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
}

- (void) notificationDownLoadImagesComplete:(NSNotification *)notification
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self forKey:TemplateKey];
    NSNotification *noti = [NSNotification notificationWithName:TemplateDownloadComplateNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:noti];
}

@end
#pragma mark End Template
