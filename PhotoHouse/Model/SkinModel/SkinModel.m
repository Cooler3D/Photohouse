//
//  PhotoModel.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/6/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "SkinModel.h"



@interface SkinModel ()
@property (strong, nonatomic) NSArray *mainOrder;
@end


@implementation SkinModel

#pragma mark - Singleton
+ (SkinModel*) sharedManager {
    static SkinModel *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SkinModel alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    
    return self;
}

#pragma mark - Header View Controllers

- (UILabel*) headerForViewControllerWithTitle:(NSString*)title {
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.text = title;
    titleView.textColor = [UIColor whiteColor]; // Your color here
    [titleView sizeToFit];
    
    return titleView;
}

- (UIColor*) headerColorWithViewController {
    UIColor *color = [UIColor colorWithRed:6.f/255.f green:28.f/255.f blue:45.f/255.f alpha:1];
    
    return color;
}

- (void) headerForDetailViewWithNavigationBar:(UINavigationBar*)navigationBar {
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [navigationBar setTitleTextAttributes:attributes];
    [navigationBar setTintColor:[UIColor whiteColor]];
}

@end
