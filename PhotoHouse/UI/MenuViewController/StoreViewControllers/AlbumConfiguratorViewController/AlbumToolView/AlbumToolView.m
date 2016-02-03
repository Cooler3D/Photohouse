//
//  AlbumToolView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/12/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "AlbumToolView.h"

#import "PropType.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropCover.h"
#import "PropStyle.h"


//@interface AlbumToolView()
//@property (strong, nonatomic, readonly) id propObject;
//@end



@implementation AlbumToolView
{
    BOOL _selected;
    UIImageView *_selectImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}



-(id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action propObject:(id)propObject andSelected:(BOOL)selected
{
    self = [self initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        _propObject = propObject;
        _selected = selected;
    }
    return self;
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGSize sizeText = [self sizeTextWithPropObject:_propObject];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(rect) - sizeText.width) / 2,
                                                               CGRectGetHeight(rect) - sizeText.height - 5.f,
                                                               sizeText.width + 5.f,
                                                               sizeText.height)];
    NSString *text = NSLocalizedString([self titleWithPropObject:_propObject], nil);
    [label setText:text];
    [label setFont:[self fontTitle]];
    [label setTextColor:[UIColor whiteColor]];
    [self addSubview:label];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rect),
                                                                           CGRectGetMinY(rect),
                                                                           CGRectGetWidth(rect),
                                                                           CGRectGetHeight(rect) - sizeText.height)];
    [imageView setImage:[self imageWithPropObject:_propObject]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:imageView];
    
    UIImage *image = [UIImage imageNamed:@"pageToolFull"];
    CGSize imageSize = image.size;
    UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(rect) - imageSize.width,
                                                                                 CGRectGetHeight(rect) - imageSize.height - 15,
                                                                                 imageSize.width - 10,
                                                                                 imageSize.height - 10)];
    [selectImageView setImage:image];
    [selectImageView setHidden:!_selected];
    [self addSubview:selectImageView];
    _selectImageView = selectImageView;
}



- (CGSize) sizeTextWithPropObject:(id)object
{
    NSString *title = [self titleWithPropObject:object];
    title = NSLocalizedString([self titleWithPropObject:object], nil);
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [self fontTitle]}];
    return size;
}


- (NSString *) titleWithPropObject:(id)object {
    NSString *title;
    
    if ([object isKindOfClass:[PropUturn class]]) {
        title = [(PropUturn*)object uturn];
        _typeConfigutator = TypeConfiguratorPage;
    }
    else if ([object isKindOfClass:[PropSize class]]) {
        title = [(PropSize*)object sizeName];
        _typeConfigutator = TypeConfiguratorSize;
    }
    else if ([object isKindOfClass:[PropCover class]]) {
        title = [(PropCover*)object cover];
        _typeConfigutator = TypeConfiguratorCover;
    }
    else if ([object isKindOfClass:[PropStyle class]]) {
        title = [(PropStyle*)object styleName];
        _typeConfigutator = TypeConfiguratorStyle;
    }

    return title;
}


- (UIFont *) fontTitle
{
    return [UIFont fontWithName:@"HelveticaNeue" size:10.f];
}


- (UIImage *) imageWithPropObject:(id)object
{
    NSString *title = [self titleWithPropObject:object];
    UIImage *image;
    switch (_typeConfigutator) {
        case TypeConfiguratorSize:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"size_%@", title]];
            break;
            
        case TypeConfiguratorCover:
            image = [UIImage imageNamed:[NSString stringWithFormat:@"cover_%@", title]];
            break;
            
        default:
            break;
    }
    
    return image;
}

#pragma mark - Public
- (void)comparePropObject:(id)propObject
{
    if ([[self titleWithPropObject:propObject] isEqualToString:[self titleWithPropObject:_propObject]]) {
        [self selectTool];
    } else {
        [self deselect];
    }
}

-(BOOL)isSelected
{
    return _selected;
}


-(void)deselect
{
    [_selectImageView setHidden:YES];
    _selected = NO;
}

-(void)selectTool
{
    [_selectImageView setHidden:NO];
    _selected = YES;
}

@end
