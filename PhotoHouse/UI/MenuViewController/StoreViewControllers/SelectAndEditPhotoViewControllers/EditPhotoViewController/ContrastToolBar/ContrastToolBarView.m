//
//  ContrastToolBarView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/4/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ContrastToolBarView.h"

#import "CLImageEditor.h"
#import "CLFilterTool.h"
#import "CLFilterBase.h"
#import "CLImageToolInfo.h"

#import "EditImageSetting.h"


typedef enum {
    TypeFilterFilter,
    TypeFilterRotate,
    TypeFilterSaturation,
    TypeFilterBrightness,
    TypeFilterContrast
} TypeFilter;



@interface ContrastToolBarView () <CLFilterToolDelegate>
@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *rotateButton;
@property (weak, nonatomic) IBOutlet UIButton *hueButton;
@property (weak, nonatomic) IBOutlet UIButton *brightessButton;
@property (weak, nonatomic) IBOutlet UIButton *constrastButton;

@property (assign, nonatomic) TypeFilter currentFilterType;

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) UIImageOrientation orientationImage;

@property (weak, nonatomic) UISlider *saturationSlider;
@property (weak, nonatomic) UISlider *brightnessSlider;
@property (weak, nonatomic) UISlider *contrastSlider;

@property (nonatomic, strong) CLImageToolBase *currentTool;
@property (nonatomic, strong) CLImageToolInfo *currentToolInfo;
@property (weak, nonatomic) UIScrollView *scrollFilterView;

@property (strong, nonatomic) EditImageSetting *setting;
@end



@implementation ContrastToolBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self configureView];
}


- (void) configureView {
    
    // Init Slizers
    self.saturationSlider = [self sliderWithValue:1.f minimumValue:0.f maximumValue:2.f action:@selector(actionChangeSlider:) tag:TypeFilterSaturation];
    self.brightnessSlider = [self sliderWithValue:0.f minimumValue:-1.f maximumValue:1.f action:@selector(actionChangeSlider:) tag:TypeFilterBrightness];
    self.contrastSlider = [self sliderWithValue:1.f minimumValue:0.5f maximumValue:1.5f action:@selector(actionChangeSlider:) tag:TypeFilterContrast];
    
    
    // Scroll Filter View
    UIScrollView *scrollFiltersView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 47.f, CGRectGetWidth(self.frame), 67.f)];
    [scrollFiltersView setBackgroundColor:[UIColor colorWithRed:2/255.f green:11/255.f blue:18/255.f alpha:0.0f]];
    [scrollFiltersView setBackgroundColor:[UIColor redColor]];
    [self addSubview:scrollFiltersView];
    self.scrollFilterView = scrollFiltersView;
    
    //
    // Filters
    CLImageToolInfo *info = [CLImageToolInfo toolInfoForToolClass:[CLFilterTool class]];
    [self setupToolWithToolInfo:info];
    
    
    // Start
    if (self.setting) {
        // Apply Edited Setting
        [self applyMemberEditedSetting:self.setting];
        
    } else {
        self.orientationImage = self.originalImage.imageOrientation;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectZero];
        [button setTag:TypeFilterFilter];
        [self actionFilterButton:button];
    }
}




- (UISlider*)sliderWithValue:(CGFloat)value minimumValue:(CGFloat)min maximumValue:(CGFloat)max action:(SEL)action tag:(NSUInteger)tag
{
//    CGRect rectSlider = CGRectMake(18, 80, 284, 31);
    UISlider *slider = [UISlider new];//[[UISlider alloc] initWithFrame:rectSlider];
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [slider setMinimumTrackTintColor:[UIColor colorWithRed:49/255.f green:162/255.f blue:208/255.f alpha:1.f]];
    [slider setTranslatesAutoresizingMaskIntoConstraints:NO];
    slider.continuous = YES;
    slider.maximumValue = max;
    slider.minimumValue = min;
    slider.value = value;
    slider.tag = tag;
    slider.hidden = YES;
    [self addSubview:slider];
    
    NSArray *constraitH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[slider]-10-|" options:0 metrics:@{} views:@{@"slider":slider}];
    NSArray *constraitV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[slider]-10-|" options:0 metrics:@{} views:@{@"slider":slider}];
    
    [self addConstraints:constraitH];
    [self addConstraints:constraitV];
    
    
    
    return slider;
}



#pragma mark - Actions
- (IBAction)actionFilterButton:(UIButton *)sender {
    // Deselect buttons
    [self.filterButton setSelected:NO];
    [self.hueButton setSelected:NO];
    [self.brightessButton setSelected:NO];
    [self.constrastButton setSelected:NO];
    
    // Select
    [sender setSelected:YES];
    
    // Hide Slides
    [self.saturationSlider setHidden:YES];
    [self.brightnessSlider setHidden:YES];
    [self.contrastSlider setHidden:YES];
    [self.scrollFilterView setHidden:YES];
    
    self.currentFilterType = (TypeFilter)sender.tag;
    
    
    //
    switch (self.currentFilterType) {
        case TypeFilterFilter:
            [self.scrollFilterView setHidden:NO];
            break;
            
        case TypeFilterRotate:
            [self actionRotate];
            [sender setSelected:NO];
            break;
            
        case TypeFilterSaturation:
            [self.saturationSlider setHidden:NO];
            [self actionNumberWithSlider:self.saturationSlider];
            break;
    
        case TypeFilterBrightness:
            [self.brightnessSlider setHidden:NO];
            [self actionNumberWithSlider:self.brightnessSlider];
            break;
            
        case TypeFilterContrast:
            [self.contrastSlider setHidden:NO];
            [self actionNumberWithSlider:self.contrastSlider];
            break;  
    }
}



- (void) actionNumberWithSlider:(UISlider *)sender
{
    //
    if (!sender) return;
    
    //
    NSInteger defaultMax = 100;
    NSInteger defaultMin = -100;
    NSInteger defaultLenght = defaultMax - defaultMin;
    
    //
    NSInteger maxSlider = sender.maximumValue * 100;
    NSInteger minSlider = sender.minimumValue * 100;
    NSInteger curretSlider = sender.value * 100;
    NSInteger intLenght = maxSlider - minSlider;
    
    //
    if (intLenght < defaultLenght) {
        NSInteger aspect_ratio = defaultLenght / intLenght;
        maxSlider *= aspect_ratio;
        minSlider *= aspect_ratio;
        curretSlider *= aspect_ratio;
    } else if (intLenght > defaultLenght) {
        NSInteger aspect_ratio = intLenght / defaultLenght;
        maxSlider /= aspect_ratio;
        minSlider /= aspect_ratio;
        curretSlider /= aspect_ratio;
    }
    
    NSInteger delta = maxSlider - defaultMax;
    curretSlider -= delta;
    
    
    // Set Text on Slider
    UIImageView *handleView = [sender.subviews lastObject];
    
    // Get the Slider value label
    UILabel *label = (UILabel*)[handleView viewWithTag:1000];
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(handleView.bounds),
                                                          CGRectGetMinY(handleView.bounds) - 30,
                                                          CGRectGetWidth(handleView.bounds) + 5,
                                                          CGRectGetHeight(handleView.bounds))];
        
        label.tag = 1000;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        [handleView addSubview:label];
    }
    // Update the slider value
    label.text = [NSString stringWithFormat:@"%li", (unsigned long)curretSlider];
}


- (IBAction)actionChangeSlider:(UISlider *)sender
{
    // Set text on Slider
    [self actionNumberWithSlider:sender];
    
    
    // Apply
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    inProgress = YES;
    
    /*NSLog(@"saturation: %1.2f; default: %1.2f", [self saturationSetting], DEFAULT_SATURATION);
    NSLog(@"brightness: %1.2f; default: %1.2f", [self brightnessSetting], DEFAULT_BRIGHTNESS);
    NSLog(@"contrast: %1.2f; default: %1.2f", [self contrastSetting], DEFAULT_CONSTRAST);*/
    
    //
    //[self.delegate contractTool:self didUpdateProgressShow:inProgress];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSLog(@"Slize: %@", NSStringFromCGSize(self.originalImage.size));
        
        UIImage *image = [self contrastImage:self.originalImage];
        //self.copyOriginalImage = [self.originalImage copy];
        //self.originalImage = [image copy];
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:self.orientationImage];
        //[(NSObject *)self.delegate performSelectorOnMainThread:@selector(contrastToolDidChangeImage:) withObject:image waitUntilDone:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate contrastToolDidChangeImage:image];
        });
        
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[self.delegate contractTool:self didUpdateProgressShow:NO];
        //});
        


        inProgress = NO;
    });

}


- (void) actionRotate {
    switch (self.orientationImage) {
        case UIImageOrientationUp:
            self.orientationImage = UIImageOrientationRight;
            break;
            
        case UIImageOrientationRight:
            self.orientationImage = UIImageOrientationDown;
            break;
            
        case UIImageOrientationDown:
            self.orientationImage = UIImageOrientationLeft;
            break;
            
        case UIImageOrientationLeft:
            self.orientationImage = UIImageOrientationUp;
            break;
            
        default:
            self.orientationImage = UIImageOrientationUp;
            break;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithCGImage:self.originalImage.CGImage scale:self.originalImage.scale orientation:self.orientationImage];
        self.originalImage = [image copy];
        

//        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(contrastToolDidChangeImage:) withObject:self.originalImage waitUntilDone:NO];
        
        // Orientation
        self.orientationImage = image.imageOrientation;
        
//        // Contract
//        if ([self.saturationSlider value] != DEFAULT_CONSTRAST ||
//            [self.brightnessSlider value] != DEFAULT_BRIGHTNESS ||
//            [self.contrastSlider value] != DEFAULT_CONSTRAST)
//        {
            [self actionChangeSlider:nil];
//        }
        NSLog(@"actionRotate.size: %@", NSStringFromCGSize(image.size));
        
        if ([self.delegate respondsToSelector:@selector(contrastTool:didChangeOrientation:andFinalImage:)]) {
            [self.delegate contrastTool:self didChangeOrientation:self.orientationImage andFinalImage:image];
        }
    });
}



#pragma mark - Methods
- (UIImage*)contrastImage:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:_saturationSlider.value] forKey:@"inputSaturation"];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat brightness = 2*_brightnessSlider.value;
    [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputEV"];
    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat contrast = _contrastSlider.value*_contrastSlider.value;
    [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputPower"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}


#pragma mark - Public
- (NSString *) filterName                   {     return self.currentToolInfo.toolName;     }
- (CGFloat) saturationSetting               {     return [self.saturationSlider value];     }
- (CGFloat) brightnessSetting               {     return [self.brightnessSlider value];     }
- (CGFloat) contrastSetting                 {     return [self.contrastSlider value];       }
- (UIImageOrientation) orientationSetting   {     return self.orientationImage;             }




- (void) setMemberEditedSetting:(EditImageSetting*)setting {
    _setting = setting;
}



- (void) applyMemberEditedSetting:(EditImageSetting*)setting {
    // ReInit
    self.orientationImage = setting.imageOrientation;
    
    // Sliders setValue
    [self.saturationSlider setValue:setting.saturationValue animated:NO];
    [self.brightnessSlider setValue:setting.brightnessValue animated:NO];
    [self.contrastSlider setValue:setting.contrastValue animated:NO];
    
    
    // Filter
    [(CLFilterTool*)self.currentTool applyFilterWithName:setting.filterName];
    
    
    // Saturation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionChangeSlider:nil];
    });
}




#pragma mark - CLImageEditorLibrary
- (void)setupToolWithToolInfo:(CLImageToolInfo*)info
{
    if(self.currentTool){ return; }
    
    Class toolClass = NSClassFromString(info.toolName);
    
    if(toolClass){
        id instance = [toolClass alloc];
        if(instance!=nil && [instance isKindOfClass:[CLImageToolBase class]]){
            instance = [instance initWithImageEditor:(id)self withToolInfo:info];
            self.currentTool = instance;
        }
    }
}

- (void)setCurrentTool:(CLImageToolBase *)currentTool
{
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        if ([currentTool respondsToSelector:@selector(setupImage:andScroll:)]) {
            [(CLFilterTool*)_currentTool setupImage:self.originalImage andScroll:self.scrollFilterView];
            [(CLFilterTool*)_currentTool setDelegate:self];
        } else {
            [_currentTool setup];
        }
    }
}


#pragma mark - CLFilterToolDelegate
- (void) clFilterToolStartApplyFilter:(UIImage*)image {
    /*MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setLabelText:@"Обработка"];
#warning ToDo: Start Progress*/
    // Progress Show
    [self.delegate contractTool:self didUpdateProgressShow:YES];
}



-(void) clFilterToolApplyFilterImage:(UIImage *)image {
    // Orientation
    image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:self.originalImage.imageOrientation];
    self.originalImage = image;
    [self.delegate contrastToolDidChangeImage:image];
    //
    //self.editedImage = image;
    //[self.contrastToolView setOriginalImage:image];
    //[self.photoImageView setImage:image];
    
    //NSLog(@"filter.apply.orientation: %i", image.imageOrientation);
    
    // Progress Hide
    [self.delegate contractTool:self didUpdateProgressShow:NO];
    
    // Check Default Contracst with Slider.values
    if ([self.saturationSlider value] != DEFAULT_CONSTRAST ||
        [self.brightnessSlider value] != DEFAULT_BRIGHTNESS ||
        [self.contrastSlider value] != DEFAULT_CONSTRAST)
    {
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self actionChangeSlider:nil];
        //});
    }
}


-(void)clFilterToolDidLastActionFilter:(CLImageToolInfo *)info {
    NSLog(@"info.filter: %@", info);
    self.currentToolInfo = info;
}


@end
