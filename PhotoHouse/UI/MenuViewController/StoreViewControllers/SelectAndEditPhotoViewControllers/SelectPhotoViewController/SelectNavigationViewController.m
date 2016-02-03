//
//  SelectNavigationViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/22/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "SelectNavigationViewController.h"
#import "SelectImagesViewController.h"



@interface SelectNavigationViewController ()
@property (strong, nonatomic) StoreItem *storeItem;
@property (strong, nonatomic) NSArray *unsavedUrls;
@property (assign, nonatomic) BOOL coreDataUse;
@end



@implementation SelectNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *array = self.viewControllers;
    for (UIViewController *vc in array) {
        if ([vc isKindOfClass:[SelectImagesViewController class]]) {
            [(SelectImagesViewController*)vc setStoreItemInit:self.storeItem andImages:self.unsavedUrls andCoreDataUse:self.coreDataUse];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setRootStoreItem:(StoreItem *)storeItem andImages:(NSArray *)unsavedUrls andCoreDataUse:(BOOL)coreDataUse
{
    self.storeItem = storeItem;
    self.unsavedUrls = unsavedUrls;
    self.coreDataUse = coreDataUse;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}




@end
