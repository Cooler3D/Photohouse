//
//  AlbumListViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 11/28/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "AlbumListViewController.h"
#import "StyleTableViewCell.h"
#import "OtherTableViewCell.h"

#import "SkinModel.h"

#import "PrintData.h"
#import "PropType.h"
#import "PropStyle.h"
#import "PropSize.h"
#import "PropCover.h"
#import "PropUturn.h"




@interface AlbumListViewController ()
{
    struct {
        unsigned int changeStyle : 1;
        unsigned int changeCover : 1;
        unsigned int changePage  : 1;
        unsigned int changeSize  : 1;
    } _chnangeFlag;
}

@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSString *titleController;
@property (strong, nonatomic) PrintData *printData;
@end



@implementation AlbumListViewController

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
    
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:_titleController];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.array count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (_chnangeFlag.changeStyle) {
        cell = [self styleTableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        cell = [self otherTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Style
    if (_chnangeFlag.changeStyle) {
        PropStyle *selectStyle = [self.array objectAtIndex:indexPath.row];
        [self.printData changeProp:selectStyle];
    }
    
    // Cover
    if (_chnangeFlag.changeCover) {
        PropCover *propCover = [self.array objectAtIndex:indexPath.row];
        [self.printData changeProp:propCover];
    }
    
    // Page
    if (_chnangeFlag.changePage) {
        PropUturn *propUturn = [self.array objectAtIndex:indexPath.row];
        [self.printData changeProp:propUturn];
    }
    
    // Size
    if (_chnangeFlag.changeSize) {
        PropSize *propSize = [self.array objectAtIndex:indexPath.row];
        [self.printData changeProp:propSize];
    }
    
    // Close
    [self.navigationController popViewControllerAnimated:YES];
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_chnangeFlag.changeStyle) {
        return 148.f;
    } else {
        return 44.f;
    }
}




#pragma mark - Configure Cell
- (UITableViewCell*) styleTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *styleImageView;
	UILabel *styleNamelabel;
    UILabel *countImageLabel;
    
    NSString *const CellIdentifier = @"StyleCell";
    StyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[StyleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor blackColor]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		
		styleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [styleImageView setBackgroundColor:[UIColor colorWithRed:63/255.f green:128/255.f blue:186/255.f alpha:1.f]];
		styleImageView.tag = 1;
		
		styleNamelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		styleNamelabel.backgroundColor = [UIColor clearColor];
		styleNamelabel.tag = 2;
		styleNamelabel.numberOfLines = 0;
		styleNamelabel.lineBreakMode = NSLineBreakByCharWrapping;
		styleNamelabel.font = [UIFont systemFontOfSize:14.f];
        styleNamelabel.textColor = [UIColor whiteColor];
        styleNamelabel.textAlignment = NSTextAlignmentCenter;
        
        countImageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		countImageLabel.backgroundColor = [UIColor clearColor];
		countImageLabel.tag = 3;
		countImageLabel.numberOfLines = 1;
		countImageLabel.lineBreakMode = NSLineBreakByCharWrapping;
		countImageLabel.font = [UIFont systemFontOfSize:14.f];
        countImageLabel.textColor = [UIColor whiteColor];
        countImageLabel.textAlignment = NSTextAlignmentCenter;
		
		UIView *contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, cell.frame.size.width, cell.frame.size.height)];
		contentStle.tag = 0;
		[contentStle addSubview:styleImageView];
		[contentStle addSubview:styleNamelabel];
        [contentStle addSubview:countImageLabel];
		[cell.contentView addSubview:contentStle];
	}
	else
	{
		styleImageView  = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		styleNamelabel  = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        countImageLabel = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
	}
    
    
    
	//
    styleImageView.frame = CGRectMake((CGRectGetWidth(cell.frame) - 312) / 2,
                                   3,
                                   312, 144);
    styleNamelabel.frame = CGRectMake((CGRectGetWidth(cell.frame) - 312) / 2,
                             90,
                             312, 44);
    countImageLabel.frame = CGRectMake((CGRectGetWidth(cell.frame) - 312) / 2,
                                 109,
                                 312, 44);
   
    
    PropStyle *style = [self.array objectAtIndex:indexPath.row];
	[styleImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"style_%@", style.styleName]]];
	[styleNamelabel setText:NSLocalizedString(style.styleName, nil)];
    if (style.minCount == style.maxCount) {
        [countImageLabel setText:[NSString stringWithFormat:@"%li %@", (long)style.minCount, NSLocalizedString(@"photos", nil)]];
    } else {
        [countImageLabel setText:[NSString stringWithFormat:@"%@ %li %@ %li %@", NSLocalizedString(@"from", nil), (long)style.minCount, NSLocalizedString(@"to", nil), (long)style.maxCount, NSLocalizedString(@"photos", nil)]];
    }
    return cell;
}



- (UITableViewCell*) otherTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OtherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *labelText;// = [self.array objectAtIndex:indexPath.row];
    NSString *priceText;
    
    NSObject *object = [self.array objectAtIndex:indexPath.row];
    if (_chnangeFlag.changeSize)
    {
        labelText = [(PropSize*)object sizeName];
        priceText = [NSString stringWithFormat:@"+%lu RUB", (unsigned long)[(PropSize*)object price]];
    }
    else if (_chnangeFlag.changePage)
    {
        labelText = [NSString stringWithFormat:@"%@ %@", [(PropUturn*)object uturn], NSLocalizedString(@"tuns", nil)];
        priceText = [NSString stringWithFormat:@"+%lu RUB", (unsigned long)[(PropUturn*)object price]];
    }
    else if (_chnangeFlag.changeCover)
    {
        labelText = NSLocalizedString([(PropCover*)object cover], nil);
        priceText = [NSString stringWithFormat:@"+%lu RUB", (unsigned long)[(PropCover*)object price]];
    }
    
    [cell.titleLabel setText:labelText];
    [cell.priceLabel setText:priceText];
    
                     
    /*if ([current isEqualToString:self.selected]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }*/
    return cell;
}


#pragma mark - Private
- (void) clear {
    _chnangeFlag.changeStyle = NO;
    _chnangeFlag.changeCover = NO;
    _chnangeFlag.changePage  = NO;
    _chnangeFlag.changeSize  = NO;
}



#pragma mark - Public

- (void) showStyleListPrintData:(PrintData *)printData
{
    //
    [self clear];
    
    //
    self.titleController = NSLocalizedString(@"choose_style", nil);
    
    
    //
    _chnangeFlag.changeStyle = YES;
    self.array      = [printData.storeItem.propType styles];
    self.printData  = printData;

    
    //
    [self.tableView reloadData];
}



- (void) showSizeListPrintData:(PrintData *)printData
{
    //
    [self clear];
    
    //
    self.titleController = NSLocalizedString(@"choose_size", nil);
    
    
    //
    _chnangeFlag.changeSize = YES;
    self.array      = [printData.storeItem.propType sizes];
    self.printData  = printData;

    
    //
    [self.tableView reloadData];
}



- (void) showCoverListPrintData:(PrintData *)printData
{
    //
    [self clear];
    
    //
    self.titleController = NSLocalizedString(@"choose_cover", nil);
    
    
    //
    _chnangeFlag.changeCover = YES;
    self.array      = [printData.storeItem.propType covers];
    self.printData  = printData;

    
    //
    [self.tableView reloadData];
}



- (void) showUturnListPrintData:(PrintData *)printData
{
    //
    [self clear];
    
    //
    self.titleController = NSLocalizedString(@"choose_uturn", nil);
    
    
    //
    _chnangeFlag.changePage = YES;
    self.array      = [printData.storeItem.propType uturns];
    self.printData  = printData;
    
    //
    [self.tableView reloadData];
}

@end
