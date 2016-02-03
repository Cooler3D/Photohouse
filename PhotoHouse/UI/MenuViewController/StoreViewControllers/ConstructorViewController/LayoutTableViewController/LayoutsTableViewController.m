//
//  LayoutsTableViewController.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/28/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "LayoutsTableViewController.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"

#import "SkinModel.h"


NSString *const LayoutChooseNotification = @"LayoutChooseNotification";

NSString *const LayoutChooseKey = @"LayoutChooseKey";



@interface LayoutsTableViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) NSArray *layouts;
@property (strong, nonatomic) NSArray *selectIndexPath;
@end



@implementation LayoutsTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"Выберите разворот", nil)];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.selectIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:self.selectIndexPath withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.layouts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *backgroundView;
    UILabel *photosCount;
    
    NSString *const CellIdentifier = @"StoreCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor blackColor]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
		backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
		backgroundView.backgroundColor = [UIColor clearColor];
		backgroundView.tag = 2;
        
        photosCount = [[UILabel alloc] initWithFrame:CGRectZero];
        [photosCount setTag:3];
        [photosCount setTextColor:[UIColor whiteColor]];
        [photosCount setTextAlignment:NSTextAlignmentCenter];
        
        
		UIView *contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), 146.f)];
		[contentStle setTag:0];
		[contentStle addSubview:backgroundView];
        [contentStle addSubview:photosCount];
		[cell.contentView addSubview:contentStle];
    } else {
        backgroundView  = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        photosCount  = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
    }
    
    
    Layout *layout = [self.layouts objectAtIndex:indexPath.row];
    Image *image = layout.backLayer.image;
    [backgroundView setImage:image.image];
    [backgroundView setContentMode:UIViewContentModeScaleAspectFit];
    
    [photosCount setText:[NSString stringWithFormat:@"%lu %@", (unsigned long)layout.backLayer.images.count, NSLocalizedString(@"photos", nil)]];
    
    
    CGRect rect;
    CGRect rectLabel;
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        rect = CGRectMake(4.f, 2.f, CGRectGetWidth(cell.frame) - 8.f, 142.f);
    } else {
        CGFloat widthView = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        CGFloat widthImage = image.image.size.width;
        CGFloat posX = (widthView - widthImage) / 2;
        rect = CGRectMake(posX, 2.f, widthView - (2 * posX), 119.f);
        rectLabel = CGRectMake(2.f, CGRectGetHeight(rect) + 5.f, widthView - 4.f, 20.f);
    }
    [backgroundView setFrame:rect];
    [photosCount setFrame:rectLabel];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Layout *layout = [self.layouts objectAtIndex:indexPath.row];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:layout forKey:LayoutChooseKey];
    NSNotification *notification = [NSNotification notificationWithName:LayoutChooseNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 146.f;
}

#pragma mark - Public
-(void)setLayoutsTemplate:(NSArray *)layouts
{
    self.layouts = layouts;
}



#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *array = [self.tableView indexPathsForVisibleRows];
    self.selectIndexPath = array;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSArray *array = [self.tableView indexPathsForVisibleRows];
    self.selectIndexPath = array;
}

@end
