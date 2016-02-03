//
//  CartDetailViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/30/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "CartDetailViewController.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "CoreDataShopCart.h"

#import "MBProgressHUD.h"

#import "PrintData.h"
#import "PrintImage.h"


@interface CartDetailViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *photoDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoPriceLabel;


@property (strong, nonatomic) NSArray *records;

@property (strong, nonatomic) NSMutableArray *arrayImageViews;
@property (assign, nonatomic) NSInteger indexShow;
@property (assign, nonatomic) NSInteger lastPositionX;

@property (strong, nonatomic) PrintData *printData;
@end



@implementation CartDetailViewController

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
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"CartDetail Screen"];
    
    
    // Navigation Bar
    SkinModel *photomodel = [SkinModel sharedManager];
    
    // Название
    self.navigationItem.titleView = [photomodel headerForViewControllerWithTitle:NSLocalizedString(@"detail_shop", nil)];
    
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[photomodel headerColorWithViewController]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    //
    NSString *title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(self.printData.nameCategory, nil), NSLocalizedString(self.printData.namePurchase, nil)];
    [self.photoDescriptionLabel setText:title];
    [self.photoPriceLabel setText:[NSString stringWithFormat:@"%@: %lu", NSLocalizedString(@"price", nil), (unsigned long)self.printData.price]];
    
    
    //
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    PrintData *printData = [coreShop getItemImagesWithPrintData:self.printData];
    self.printData = printData;
    [self showImages:self.printData.mergedImages.count == 0 ? self.printData.imagesPreview : self.printData.mergedImages];
    
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // Analitics
    [[AnaliticsModel sharedManager] sendEventCategory:@"Warning" andAction:@"CartDetail.ReceiveMemoryWarning" andLabel:@"CartDetail" withValue:nil];
}






- (void) showImages:(NSArray*)printImages {
    _arrayImageViews = [NSMutableArray array];
    
    
    
    // Сколько картинок будет
    NSInteger pageCount = printImages.count;
    
    
    // Setup Scroll View
//    UIScrollView *scroller = self.scrollView;
    CGFloat top = self.topLayoutGuide.length;
    UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top,
                                                                            CGRectGetWidth(self.view.frame),
                                                                            CGRectGetHeight(self.view.frame) - 79.f - top)];
    scroller.pagingEnabled = YES;
    scroller.contentSize = CGSizeMake(pageCount * scroller.bounds.size.width, scroller.bounds.size.height);
    scroller.delegate = self;
    
    // Setup Each VIew Size
    CGRect viewSize = scroller.bounds;
    
    NSInteger cnt = 1;
    //
    for (PrintImage *printImage in printImages) {
        // Offset
        if (cnt != 1) {
            viewSize = CGRectOffset(viewSize, scroller.bounds.size.width, 0);
        }
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:viewSize];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setImage:printImage.previewImage];
        [scroller addSubview:imageView];
        
        // Add in Array
        [_arrayImageViews addObject:imageView];
        
        //
        //[[CoreDataModel sharedManager] imageWithUniqueID:record.unique_id andIndex:record.indexPhotoPosition andManyPhoto:YES];
        
        cnt++;
    }
    
    
    
    // Скролим до нужного места
    CGRect curViewSize = scroller.bounds;
    curViewSize = CGRectOffset(curViewSize, 320 * _indexShow, 0);
    [scroller scrollRectToVisible:curViewSize animated:YES];
    
    //
    [self.view addSubview:scroller];
//    self.scrollView = scroller;
    
    
    // Стартовая позиция
    _lastPositionX = 320 * _indexShow;
    
    
    [self loadPhotoAndShowTitle];
}




#pragma mark - Scroll View Delegate
// После того как прокрутка закончилась
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //NSLog(@"End. CurPage: %ld", (long)indexShow);
    //NSLog(@"Scroll: %f", [scrollView contentOffset].x);
    
    // Определяем Позицию
    // Если значение X уменьшилось то index --
    // Если увеличилось, то index ++
    NSInteger scrollPositionX = [scrollView contentOffset].x;
    
    //
    if (_lastPositionX < scrollPositionX) {
        //
        _indexShow++;
    } else if(_lastPositionX > scrollPositionX) {
        //
        _indexShow--;
    }
    
    //
    _lastPositionX = scrollPositionX;
    
    //
    [self loadPhotoAndShowTitle];
}


-(void)loadPhotoAndShowTitle {
    // Clear
    /*for (UIImageView *imgView in _arrayImageViews) {
        [imgView setImage:nil];
    }
    
    
    PhotoRecord *record = [_records objectAtIndex:_indexShow > _records.count - 1 ? 0 : _indexShow];
    UIImage *image = [[CoreDataModel sharedManager] imageWithUniqueID:record.unique_id andIndex:record.indexPhotoPosition];
    // Куда будем загружать
    UIImageView *imageView = [_arrayImageViews objectAtIndex:_indexShow > _records.count - 1 ? 0 : _indexShow];
    [imageView setImage:image];*/
}




#pragma mark - Public

/*- (void) setCurrentArrayPhotoRecords:(NSArray*)arrayRecords
{
    self.records = arrayRecords;
}*/

-(void)setDetailPrintData:(PrintData *)printData
{
    self.printData = printData;
}

@end
