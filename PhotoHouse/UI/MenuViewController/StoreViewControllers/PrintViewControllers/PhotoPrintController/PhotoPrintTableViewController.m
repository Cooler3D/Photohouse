//
//  PhotoPrintTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/6/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PhotoPrintTableViewController.h"
#import "ShowCaseViewController.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropStyle.h"
#import "CoreDataStore.h"

#import "SelectNavigationViewController.h"
#import "SelectImagesNotification.h"


static NSString *const SEGUE_PHOTO_IMPORT = @"segue_select_images";
static NSString *const SEGUE_SHOWCASE_PHOTOPRINT = @"segue_showcase_photoprint";




@interface PhotoPrintTableViewController ()
@property (strong, nonatomic) NSArray *purchaseItems;

@property (assign, nonatomic) NSInteger selectedPrintInteger;
@property (strong, nonatomic) NSString *categoryTitle;

/// Массив выбранных фотографий [PrintImage]
@property (strong, nonatomic) NSArray *printImages;
@end



@implementation PhotoPrintTableViewController

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
    
    // Header
    [[SkinModel sharedManager] headerForDetailViewWithNavigationBar:self.navigationController.navigationBar];
    
    // Название
    NSString *title = NSLocalizedString(self.categoryTitle, nil);
    self.navigationItem.titleView = [[SkinModel sharedManager] headerForViewControllerWithTitle:title];
    
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"PrintPhoto Screen"];
    
    
    //
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    NSArray *purchaseItems = [coreStore getStoreItemsWithCategoryName:[self.categoryTitle capitalizedString]];
    self.purchaseItems = purchaseItems;
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.purchaseItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView;
    UIImageView *iconView;
	UILabel *sizelabel;
    UILabel *pricelabel;
    UILabel *countPhotoLabel;
    
    // Create Cell
    static NSString *const CellIdentifier = @"FormatCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor colorWithRed:(76 / 255.0) green:(71 / 255.0) blue:(72 / 255.0) alpha:1]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
        backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		backgroundView.backgroundColor = [UIColor clearColor];
		backgroundView.tag = 1;
        
        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
		iconView.tag = 2;

		sizelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		sizelabel.backgroundColor = [UIColor clearColor];
		sizelabel.tag = 3;
		sizelabel.numberOfLines = 0;
		sizelabel.lineBreakMode = NSLineBreakByCharWrapping;
		sizelabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.f];//[UIFont systemFontOfSize:15.0];
        sizelabel.textColor = [UIColor whiteColor];
        
        pricelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		pricelabel.backgroundColor = [UIColor clearColor];
		pricelabel.tag = 4;
		pricelabel.numberOfLines = 1;
		pricelabel.lineBreakMode = NSLineBreakByCharWrapping;
		pricelabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f];
        pricelabel.textColor = [UIColor blackColor];
        
        countPhotoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		countPhotoLabel.backgroundColor = [UIColor clearColor];
		countPhotoLabel.tag = 5;
		countPhotoLabel.numberOfLines = 1;
		countPhotoLabel.lineBreakMode = NSLineBreakByCharWrapping;
		countPhotoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.f];
        countPhotoLabel.textColor = [UIColor blackColor];
		
		UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
		cellView.tag = 0;
		[cellView addSubview:backgroundView];
		[cellView addSubview:iconView];
        [cellView addSubview:sizelabel];
        [cellView addSubview:pricelabel];
        [cellView addSubview:countPhotoLabel];
		[cell.contentView addSubview:cellView];

    } else {
		backgroundView  = (UIView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
        iconView        = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        sizelabel       = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
        pricelabel      = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:4];
        countPhotoLabel = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:5];
    }
    
    // Config
    [backgroundView setFrame:CGRectMake(4, 2, CGRectGetWidth(cell.frame) - 8, 68)];
    [iconView setFrame:CGRectMake(80, 0, 68, 68)];
    [sizelabel setFrame:CGRectMake(192, 7, 100, 21)];
    [pricelabel setFrame:CGRectMake(192, 25, 100, 21)];
    [countPhotoLabel setFrame:CGRectMake(192, 43, 100, 21)];
    
    // Set Data
    StoreItem *data = [self.purchaseItems objectAtIndex:indexPath.row];
    [sizelabel setText:data.namePurchase];
    [pricelabel setText:[NSString stringWithFormat:@"%ld RUB", (long)[data price]]];
    [iconView setImage:data.iconStoreImage];
    [backgroundView setBackgroundColor:[self colorWithInteger:indexPath.row]];
    [cell setBackgroundColor:[UIColor colorWithRed:6.f/255.f green:28.f/255.f blue:45.f/255.f alpha:1]];
    
    PropStyle *style = data.propType.selectPropStyle;
    if (style.maxCount == style.minCount) {
        [countPhotoLabel setText:[NSString stringWithFormat:@"%i %@", (int)style.minCount,  NSLocalizedString(@"pcs.", nil)]];
    } else {
        [countPhotoLabel setText:[NSString stringWithFormat:@"%i - %i %@", (int)style.minCount, (int)style.maxCount,  NSLocalizedString(@"pcs.", nil)]];
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Переходим к выбору фото
    [self performSegueWithIdentifier:SEGUE_PHOTO_IMPORT sender:self];
    
    //
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationImagesDidSelected:) name:SelectAllImagesSelectCompleteNotification object:nil];
    [nc addObserver:self selector:@selector(notificationImagesDidSelectedCancel:) name:SelectAllImagesSelectCancelNotification object:nil];
}



#pragma mark - Private Methods
/**
 Возвращаем цвет по номеру.
 Массив цветов colorArray состоит из 5-ти цветов.
 */
- (UIColor*) colorWithInteger:(NSInteger)current {
    
    NSArray *colorArray = [NSArray arrayWithObjects:   [UIColor colorWithRed:63/255.f green:129/255.f blue:187/255.f alpha:1.f],
                                                       [UIColor colorWithRed:56/255.f green:146/255.f blue:198/255.f alpha:1.f],
                                                       [UIColor colorWithRed:49/255.f green:162/255.f blue:208/255.f alpha:1.f],
                                                       [UIColor colorWithRed:42/255.f green:178/255.f blue:218/255.f alpha:1.f],
                                                       [UIColor colorWithRed:35/255.f green:195/255.f blue:229/255.f alpha:1.f],
                                                       [UIColor colorWithRed:42/255.f green:178/255.f blue:218/255.f alpha:1.f],
                                                       [UIColor colorWithRed:49/255.f green:162/255.f blue:208/255.f alpha:1.f],
                                                       [UIColor colorWithRed:63/255.f green:129/255.f blue:187/255.f alpha:1.f], nil];
    
    //
    UIColor *color = [colorArray objectAtIndex:current % 8];
    return color;
}



#pragma mark - Public
- (void) setCategoryTitleStore:(NSString *)categoryTitle
{
    self.categoryTitle = categoryTitle;
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Select Images
    if ([segue.destinationViewController isKindOfClass:[SelectNavigationViewController class]]) {
        NSInteger selected = [[self.tableView indexPathForSelectedRow] row];
        StoreItem *item = [self.purchaseItems objectAtIndex:selected];
        [segue.destinationViewController setRootStoreItem:item andImages:@[] andCoreDataUse:NO];
    }
    
    
    // ShowCase
    if ([segue.destinationViewController isKindOfClass:[ShowCaseViewController class]]) {
        NSInteger selected = [[self.tableView indexPathForSelectedRow] row];
        StoreItem *item = [self.purchaseItems objectAtIndex:selected];
        [segue.destinationViewController setPhotoPrintItem:item andSelectedImages:self.printImages];
    }
}

#pragma mark - Notification
- (void) notificationImagesDidSelected:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SelectAllImagesSelectCompleteNotification object:nil];
    
    
    NSDictionary *info = notification.userInfo;
    NSArray *printImages = [info objectForKey:SelectAllImagesKey];
    self.printImages = printImages;
    
    [self performSegueWithIdentifier:SEGUE_SHOWCASE_PHOTOPRINT sender:self];
}

- (void) notificationImagesDidSelectedCancel:(NSNotification *)notification {
}

@end
