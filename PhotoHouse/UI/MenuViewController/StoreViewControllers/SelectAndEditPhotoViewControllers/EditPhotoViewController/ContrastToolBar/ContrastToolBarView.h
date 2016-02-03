//
//  ContrastToolBarView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/4/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>



@class EditImageSetting;
@protocol ContrastFiltersDelegate;


@interface ContrastToolBarView : UIView
// Get Parameters Hue, Brightness, Contrast
- (NSString *) filterName;
- (CGFloat) saturationSetting;
- (CGFloat) brightnessSetting;
- (CGFloat) contrastSetting;
- (UIImageOrientation) orientationSetting;



/*! Устаналиваем настройки если есть
 *@param setting сохраненные настройки
 */
- (void) setMemberEditedSetting:(EditImageSetting*)setting;


/*! Применяем настройки к фотографии
 *@param setting сохраненные настройки
 */
- (void) applyMemberEditedSetting:(EditImageSetting*)setting;



@property (weak, nonatomic) id<ContrastFiltersDelegate> delegate;
@property (strong, nonatomic) UIImage *originalImage;
@end




@protocol ContrastFiltersDelegate <NSObject>
@required
- (void) contrastToolDidChangeImage:(UIImage*)image;
- (void) contractTool:(ContrastToolBarView*)contrastTool didUpdateProgressShow:(BOOL)isShow;

@optional
- (void) contrastTool:(ContrastToolBarView *)contrastTool didChangeFilter:(NSString *)filterName;
- (void) contrastTool:(ContrastToolBarView *)contrastTool didChangeSaturation:(CGFloat)saturation;
- (void) contrastTool:(ContrastToolBarView *)contrastTool didChangeBrightness:(CGFloat)brightness;
- (void) contrastTool:(ContrastToolBarView *)contrastTool didChangeContrast:(CGFloat)contrast;
- (void) contrastTool:(ContrastToolBarView *)contrastTool didChangeOrientation:(UIImageOrientation)orientation andFinalImage:(UIImage *)image;
@end
