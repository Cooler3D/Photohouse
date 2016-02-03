//
//  InitViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/5/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHInitViewController.h"
#import "MenuTableViewController.h"

@interface PHInitViewController ()

@end

@implementation PHInitViewController

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
    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:Store_StoryboardID];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
