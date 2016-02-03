//
//  SliderUturn.m
//  SliderTest
//
//  Created by Дмитрий Мартынов on 5/24/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "SliderUturn.h"

#import "PropUturn.h"


@interface SliderUturn ()
@property (strong, nonatomic) NSArray *uturns;
@property (weak, nonatomic) id<SliderUturnDelegate> delegate;
@end



@implementation SliderUturn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (id) initWithFrame:(CGRect)frame andUturns:(NSArray *)uturns andDelegate:(id<SliderUturnDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.uturns = uturns;
        NSMutableArray *mutable = [uturns mutableCopy];
        self.uturns = [mutable sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PropUturn *first = (PropUturn *)obj1;
            PropUturn *second = (PropUturn *)obj2;
            if ([first.uturn integerValue] < [second.uturn integerValue])
                return NSOrderedAscending;
            else if ([first.uturn integerValue] > [second.uturn integerValue])
                return NSOrderedDescending;
            else 
                return NSOrderedSame;
        }];
        self.delegate = delegate;
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self setMaximumValue:self.uturns.count-1];
    [self setMinimumValue:0.f];
    [self setValue:self.minimumValue];
    [self addTarget:self action:@selector(actonChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(actionChangeFinished:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Отнимаем единицу
    NSUInteger countUturns = self.uturns.count - 1;
    
    // На каких расстояниях будут стоят названия
    CGFloat offsetLabelX = CGRectGetWidth(rect) / countUturns;
    
    
    // Создаем label
    for (int i=0; i<self.uturns.count; i++) {
        PropUturn *propUturn = [self.uturns objectAtIndex:i];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.f];
        CGSize sizeText = [propUturn.uturn sizeWithAttributes:@{NSFontAttributeName: font}];
        
        CGFloat posX;
        if (i == 0) {
            posX = 10.f;
        } else if (i > 0 && i < self.uturns.count - 1) {
            posX = offsetLabelX * i - 7.f;
        } else {
            posX = (offsetLabelX * i) - (sizeText.width * 2);
        }
        
        CGRect rectLabel = CGRectMake(posX, CGRectGetHeight(rect), sizeText.width, sizeText.height);
        
        UILabel *label = [[UILabel alloc] initWithFrame:rectLabel];
        [label setText:propUturn.uturn];
        [label setFont:font];
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:label];
    }
}


#pragma mark - Action
- (IBAction)actonChangeValue:(UISlider *)sender
{
    //NSLog(@"value: %f", roundf(sender.value));
}

- (IBAction)actionChangeFinished:(UISlider *)sender
{
    CGFloat valueChange = roundf(sender.value);
    [self setValue:valueChange animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(sliderUrurn:didChangeUturn:)]) {
        PropUturn *select = [self.uturns objectAtIndex:valueChange];
       [self.delegate sliderUrurn:self didChangeUturn:select];
    }
}


#pragma mark - Methods


@end
