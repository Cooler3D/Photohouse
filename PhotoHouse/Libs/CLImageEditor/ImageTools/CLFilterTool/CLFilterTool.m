//
//  CLFilterTool.m
//
//  Created by sho yakushiji on 2013/10/19.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLFilterTool.h"

#import "CLFilterBase.h"

@interface CLFilterTool ()
@property (strong, nonatomic) CLImageToolInfo *infoLastTool;
@end

@implementation CLFilterTool
{
    UIImage *_originalImage;
    
    UIScrollView *_menuScroll;
}

+ (NSArray*)subtools
{
    return [CLImageToolInfo toolsWithToolClass:[CLFilterBase class]];
}

+ (NSString*)defaultTitle
{
    return NSLocalizedStringWithDefaultValue(@"CLFilterTool_DefaultTitle", nil, [CLImageEditorTheme bundle], @"Filter", @"");
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

- (void)setup
{
    //_originalImage = [UIImage imageNamed:@"IMG_0055.JPG"];//self.editor.imageView.image;
    
    //_menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    _menuScroll.backgroundColor = [UIColor clearColor];//self.editor.menuView.backgroundColor;
    _menuScroll.showsHorizontalScrollIndicator = NO;
    [(UIView*)self.editor addSubview:_menuScroll];
    
    [self setFilterMenu];
    
    /*_menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         _menuScroll.transform = CGAffineTransformIdentity;
                     }];*/
}

- (void) setupImage:(UIImage*)image andScroll:(UIScrollView*)scrollView {
    //NSLog(@"_menu: %@", NSStringFromCGSize(_menuScroll.contentSize));
    CGSize scrollContentSize = _menuScroll.contentSize;
    if (_menuScroll) {
        [_menuScroll removeFromSuperview];
        _menuScroll = nil;
    }
    
    _menuScroll = scrollView;
    _originalImage = image;
    [_menuScroll setContentSize:scrollContentSize];
    [self setup];
    //NSLog(@"_menu: %@", NSStringFromCGSize(_menuScroll.contentSize));
    
    
}

- (void) updateImage:(UIImage*)image {
    _originalImage = image;
}

- (void)cleanup
{
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         _menuScroll.transform = CGAffineTransformMakeTranslation(0, self.editor.view.height-_menuScroll.top);
                     }
                     completion:^(BOOL finished) {
                         [_menuScroll removeFromSuperview];
                     }];
}

- (void)executeWithCompletionBlock:(void (^)(UIImage *, NSError *, NSDictionary *))completionBlock
{
    completionBlock(self.editor.imageView.image, nil, nil);
}

#pragma mark- 

- (void)setFilterMenu
{
    CGFloat W = 70;
    CGFloat x = 0;
    
    UIImage *iconThumnail = [_originalImage aspectFill:CGSizeMake(50, 50)];
    
    for(CLImageToolInfo *info in self.toolInfo.sortedSubtools){
        if(!info.available){
            continue;
        }
        
        CLToolbarMenuItem *view = [CLImageEditorTheme menuItemWithFrame:CGRectMake(x, 0, W, _menuScroll.height) target:self action:@selector(tappedFilterPanel:) toolInfo:info];
        [_menuScroll addSubview:view];
        x += W;
        
        if(view.iconImage==nil){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *iconImage = [self filteredImage:iconThumnail withToolInfo:info];
                [view performSelectorOnMainThread:@selector(setIconImage:) withObject:iconImage waitUntilDone:NO];
            });
        }
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedFilterPanel:(UITapGestureRecognizer*)sender
{
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    inProgress = YES;
    
    UIView *view = sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:kCLImageToolAnimationDuration
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    //CGFloat startTime = CACurrentMediaTime();
    
    [self.delegate clFilterToolStartApplyFilter:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self filteredImage:_originalImage withToolInfo:view.toolInfo];
        self.infoLastTool = view.toolInfo;
        
        
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(clFilterToolApplyFilterImage:) withObject:image waitUntilDone:NO];
        [(NSObject*)self.delegate performSelectorOnMainThread:@selector(clFilterToolDidLastActionFilter:) withObject:view.toolInfo waitUntilDone:NO];
        
        inProgress = NO;
    });
    
    //
    if ([view isKindOfClass:[CLToolbarMenuItem class]]) {
        [self selectView:(CLToolbarMenuItem*)view];
    }
    
}

- (UIImage*)filteredImage:(UIImage*)image withToolInfo:(CLImageToolInfo*)info
{
    @autoreleasepool {
        Class filterClass = NSClassFromString(info.toolName);
        if([(Class)filterClass conformsToProtocol:@protocol(CLFilterBaseProtocol)]){
            return [filterClass applyFilter:image];
        }
        return nil;
    }
}

-(void)applyFilterWithName:(NSString *)name {
    
    for (CLToolbarMenuItem *view in _menuScroll.subviews) {
        
        if ([name isEqualToString:view.toolInfo.toolName]) {
            // Apply Filter
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [self filteredImage:_originalImage withToolInfo:view.toolInfo];
                [(NSObject*)self.delegate performSelectorOnMainThread:@selector(clFilterToolApplyFilterImage:) withObject:image waitUntilDone:NO];
                [(NSObject*)self.delegate performSelectorOnMainThread:@selector(clFilterToolDidLastActionFilter:) withObject:view.toolInfo waitUntilDone:NO];
            });
            // Select
            if ([view isKindOfClass:[CLToolbarMenuItem class]]) {
                [self selectView:view];
            }
        }
    }
}

- (void) selectView:(CLToolbarMenuItem*)view {
    for (id item in _menuScroll.subviews) {
        if ([item isKindOfClass:[CLToolbarMenuItem class]]) {
            [item setSelected:NO];
        }
        
    }
    
    [view setSelected:YES];
}

@end
