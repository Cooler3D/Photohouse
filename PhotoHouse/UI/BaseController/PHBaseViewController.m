//
//  PHBaseViewController.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 11/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "PHBaseViewController.h"

@interface PHBaseViewController ()

@end

@implementation PHBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
