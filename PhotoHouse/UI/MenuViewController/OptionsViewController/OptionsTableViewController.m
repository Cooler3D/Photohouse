//
//  OptionsTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "OptionsTableViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"

#import "MenuTableViewController.h"

#import "SkinModel.h"

#import "CoreDataCacheImage.h"

#import "AnaliticsModel.h"


@interface OptionsTableViewController ()
@property (assign, nonatomic) MDMenuSlideType menuSlideType;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UISwitch *cacheSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cacheLabel;
@property (weak, nonatomic) IBOutlet UILabel *cacheDescriptionLabel;

@end



@implementation OptionsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"Options Screen"];
    
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"options_title", nil)];
    
    [self.menuBarButton setTintColor:[UIColor whiteColor]];
    
    
    
    // Slize Menu
    self.tableView.layer.shadowOpacity = 0.75f;
    self.tableView.layer.shadowRadius = 10.f;
    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuTableViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:Menu_StoryboardID];
    }
    
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    /*SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.menuBarButton setTarget: revealViewController];
        [self.menuBarButton setAction: @selector( revealToggle: )];
        //[self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }*/
    
    
    
    // Swipe
    UISwipeGestureRecognizer *swipeOpen = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeOpen setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeOpen];
    
    UISwipeGestureRecognizer *swipeClose = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeClose setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeClose];
    
    
    
    
    
    // Catch Turn
    CoreDataCacheImage *coredatamodel = [[CoreDataCacheImage alloc] init];
    [self.cacheSwitch setOn:[coredatamodel isCacheOpened] animated:YES];
    
    
    // Localization
    [self.cacheLabel setText:NSLocalizedString(@"cache_photo_title", nil)];
    [self.cacheDescriptionLabel setText:NSLocalizedString(@"cache_photo_description", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





#pragma mark - Gesture
- (void)gestureSwipe:(UISwipeGestureRecognizer *)gesture {
    //[self.revealViewController revealToggle:self];
    [self actionMenuBarButton:nil];
}







#pragma mark - Action
- (IBAction)actionMenuBarButton:(UIBarButtonItem *)sender {
    if (self.menuSlideType == MDMenuSlideTypeClosed) {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
        self.menuSlideType = MDMenuSlideTypeOpened;
    } else {
        [self.slidingViewController resetTopViewAnimated:YES];
        self.menuSlideType = MDMenuSlideTypeClosed;
    }
}


- (IBAction)actionCacheSwitch:(UISwitch *)sender {
    dispatch_queue_t queue = dispatch_queue_create("com.apple.photohouse.options.clear.social", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        //
        CoreDataCacheImage *cache = [[CoreDataCacheImage alloc] init];
        [cache cacheSwitch:sender.isOn];
    });
}

@end
