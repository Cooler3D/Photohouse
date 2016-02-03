//
//  HistoryDetailViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "HistoryDetailPhotoViewController.h"


#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "MBProgressHUD.h"

#import "UIView+Toast.h"

#import "LoadImageManager.h"

#import "PrintData.h"
#import "PrintImage.h"


@interface HistoryDetailPhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;


@property (strong, nonatomic) PrintData *printData;

@property (assign, nonatomic) NSInteger indexShow;
@property (assign, nonatomic) NSInteger lastPositionX;
@property (strong, nonatomic) NSMutableArray *arrayImageViews;
@end

@implementation HistoryDetailPhotoViewController

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
    [[AnaliticsModel sharedManager] setScreenName:@"HistoryOrderDetail Screen"];
    
    // Navigation Bar
    SkinModel *photomodel = [SkinModel sharedManager];
    
    // Название
    self.navigationItem.titleView = [photomodel headerForViewControllerWithTitle:self.printData.namePurchase];
    
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[photomodel headerColorWithViewController]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    
    // Images
   [self showAlbumWithImagesUrls:[self.printData uploadURLs]];
    
    
    // Цена, описание
    [self.descriptionLabel setText:self.printData.namePurchase];//[NSString stringWithFormat:@"%@ - %@", self.printData.namePurchase, self.order.nameOrder]];
    [self.priceLabel setText:[NSString stringWithFormat:@"Цена: %li RUR", (long)[self.printData price]]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    // Analitics
    [[AnaliticsModel sharedManager] sendEventCategory:@"Warning" andAction:@"ReceiveMemoryWarning" andLabel:@"HistoryOrderDetailPhoto" withValue:nil];
}



#pragma mark - Album
- (void) showAlbumWithImagesUrls:(NSArray*)urls {
    _arrayImageViews = [NSMutableArray array];
    
    // Сколько картинок будет
    NSInteger pageCount = urls.count;
    
    
    // Setup Scroll View
    UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                            CGRectGetWidth(self.view.frame),
                                                                            CGRectGetHeight(self.view.frame) - 70 - 70)];
    scroller.pagingEnabled = YES;
    scroller.contentSize = CGSizeMake(pageCount * scroller.bounds.size.width, scroller.bounds.size.height);
    scroller.delegate = self;
    
    // Setup Each VIew Size
    CGRect viewSize = scroller.bounds;
    
    //NSInteger cnt = 1;
    //
    //for (NSString *urlPath in urls) {
    for(int cnt = 1; cnt <= [urls count]; cnt++) {
        // Offset
        if (cnt != 1) {
            viewSize = CGRectOffset(viewSize, scroller.bounds.size.width, 0);
        }
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:viewSize];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [scroller addSubview:imageView];
        
        // Add in Array
        [_arrayImageViews addObject:imageView];
        
        //cnt++;
    }
    
    
    
    // Скролим до нужного места
    CGRect curViewSize = scroller.bounds;
    curViewSize = CGRectOffset(curViewSize, 320 * _indexShow, 0);
    [scroller scrollRectToVisible:curViewSize animated:YES];
    
    //
    [self.view addSubview:scroller];
    
    
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



// загружаем данные
-(void)loadPhotoAndShowTitle {
    // Crear
    for (UIImageView *imageView in self.arrayImageViews) {
        [imageView setImage:nil];
    }
    
    // Куда будем загружать
    UIImageView *imageView = [_arrayImageViews objectAtIndex:_indexShow];
    // Возможно фотка уже есть
    if (imageView.image) {
        return;
    }
    
    
    //
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Загрузка";
    
    
    NSString *path = [self getPreviewPathWithURL:[[self.printData.uploadURLs objectAtIndex:_indexShow] absoluteString]];
    NSURL *urlName = [NSURL URLWithString:path];
    /*CoreDataSocialImages *coreImages = [[CoreDataSocialImages alloc] init];
    [coreImages loadImageWithURL:[urlName absoluteString] usingBlock:^(BOOL isSuccess, UIImage *image) {
        if (isSuccess) {
            [imageView setImage:image];
        }
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];*/
    
    
    LoadImageManager *manager = [[LoadImageManager alloc] init];
    [manager loadImageWithURL:urlName usingCompleteBlock:^(UIImage *image) {
        // Complete
        [imageView setImage:image];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    } progressBlock:^(CGFloat progress) {
        // Progress
        [hud setProgress:progress];
        
        
    }  errorBlock:^(NSError *error) {
        // Error
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // Toast
        [self.view makeToast:@"Не удалось загрузить"];
    }];
}


- (NSString *) getPreviewPathWithURL:(NSString *)url {
    NSString *original = [url stringByReplacingOccurrencesOfString:@".png" withString:@"_n.png"];
    return original;
}





#pragma mark - Public
- (void) setPrintDataOrder:(PrintData *)printData {
    self.printData = printData;
}

@end
