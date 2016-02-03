//
//  OthersPrintViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/13/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "OthersPrintViewController.h"
#import "OtherPrintCollectionCell.h"
#import "AlbumConfiguratorViewController.h"
#import "ShowCaseViewController.h"


//#import "PhotoPrintData.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "StoreItem.h"
#import "CoreDataStore.h"

NSString *const SEGUE_SELECT = @"segue_select_image";
NSString *const SEGUE_SIZE_ALBUM = @"segue_size_album";
NSString *const SEGUE_ALBUM_CONFIGURATOR = @"segue_album_configurator";
NSString *const SEGUE_SHOWCASE_OBJECTS = @"segue_showcase_objects";



@interface OthersPrintViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//@property (strong, nonatomic) NSArray *printObjects;
//@property (assign, nonatomic) StoreType storeType;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSArray *storeItems;
@end



@implementation OthersPrintViewController

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
    [[AnaliticsModel sharedManager] setScreenName:@"PrintObjects Screen"];
    
    
    //
    [self.navigationController setTitle:_categoryName];
    
    //
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UIEdgeInsets insert = UIEdgeInsetsMake(0, 4, 0, 4);
    [self.collectionView setContentInset:insert];
    
    
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    NSArray *list = [coreStore getStoreItemsWithCategoryName:_categoryName];
    if (list.count == 0) {
        [self developMenu];
    } else {
        self.storeItems = list;
        [self.collectionView reloadData];
    }
    
    //
    [[SkinModel sharedManager] headerForDetailViewWithNavigationBar:self.navigationController.navigationBar];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Rotate
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.storeItems count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifer = @"Cell";
    
    OtherPrintCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifer forIndexPath:indexPath];
    StoreItem *storeItem = [self.storeItems objectAtIndex:indexPath.row];
    [cell setBackgroundColor:[self colorWithInteger:indexPath.row]];
    [cell.imageView setImage:storeItem.iconStoreImage];
    [cell.titleLabel setText:NSLocalizedString(storeItem.namePurchase, nil)];
    [cell.priceLabel setText:[NSString stringWithFormat:@"%ld RUB", (long)storeItem.price]];
    
    return cell;

}



#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SEGUE_SHOWCASE_OBJECTS sender:self];
}




#pragma mark - Public
/*- (void) setStoreTypes:(StoreType)storeType andTitleController:(NSString*)title {
    self.storeType = storeType;
    self.title = title;
}*/

- (void) setCategoryTitleStore:(NSString *)categoryTitle
{
    self.categoryName = categoryTitle;
    NSLog(@"category: %@", categoryTitle);
}



#pragma mark - Private Methods
/** 
 Заглушка
 */
- (void) developMenu {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:headerView.frame];
    [imageView setImage:[UIImage imageNamed:@"sectionInConstructor"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [headerView addSubview:imageView];
    [self.view addSubview:headerView];
}



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
    
    
    int delitel = 0;
    
    if (current % 2 == 0) {
        delitel = (int)current / 2;
    } else {
        delitel = (int)current - 1;
        
        delitel = delitel / 2;
    }
    
    //NSLog(@"currnt: %i - %i",current, current % 8);
    
    //NSLog(@"current: %li; delitel: %i", (long)current, delitel % 8);
    
    //
    UIColor *color = [colorArray objectAtIndex:delitel % 8];
    
    
    return color;
}


/*- (NSArray*) makeSouvenirList {
    PhotoPrintData *cup = [[PhotoPrintData alloc] init];
    [cup setNameSize:@"Кружка"];
    [cup setImageIcon:[UIImage imageNamed:@"Mug_308"]];
    [cup setPhotoObject:PhotoObjectCup];
    
    PhotoPrintData *cupHameleon = [[PhotoPrintData alloc] init];
    [cupHameleon setNameSize:@"Кружка-Хамелеон"];
    [cupHameleon setImageIcon:[UIImage imageNamed:@"Mug3_308"]];
    [cupHameleon setPhotoObject:PhotoObjectCupHameleon];
    
    PhotoPrintData *cupColor = [[PhotoPrintData alloc] init];
    [cupColor setNameSize:@"Кружка Цветная"];
    [cupColor setImageIcon:[UIImage imageNamed:@"Mug_308"]];
    [cupColor setPhotoObject:PhotoObjectCupColor];
    
    PhotoPrintData *cupHeart = [[PhotoPrintData alloc] init];
    [cupHeart setNameSize:@"Кружка Love"];
    [cupHeart setImageIcon:[UIImage imageNamed:@"Mug2_308"]];
    [cupHeart setPhotoObject:PhotoObjectCupLove];
    
    PhotoPrintData *cupGlass = [[PhotoPrintData alloc] init];
    [cupGlass setNameSize:@"Кружка Стекло"];
    [cupGlass setImageIcon:[UIImage imageNamed:@"Mug4_308"]];
    [cupGlass setPhotoObject:PhotoObjectCupGlass];
    
    PhotoPrintData *cupLatte = [[PhotoPrintData alloc] init];
    [cupLatte setNameSize:@"Кружка Latte"];
    [cupLatte setImageIcon:[UIImage imageNamed:@"Mug1_308"]];
    [cupLatte setPhotoObject:PhotoObjectCupLatte];
    
    PhotoPrintData *tShirt = [[PhotoPrintData alloc] init];
    [tShirt setNameSize:@"Фуболка"];
    [tShirt setPhotoObject:PhotoObjectTShirt];
    [tShirt setImageIcon:[UIImage imageNamed:@"T-shirt_308"]];
    
    PhotoPrintData *mouseMat = [[PhotoPrintData alloc] init];
    [mouseMat setNameSize:@"Коврик для мыши"];
    [mouseMat setPhotoObject:PhotoObjectMouseMat];
    [mouseMat setImageIcon:[UIImage imageNamed:@"mat_308"]];
    
    PhotoPrintData *puzzle = [[PhotoPrintData alloc] init];
    [puzzle setNameSize:@"Puzzle"];
    [puzzle setPhotoObject:PhotoObjectPuzzle];
    [puzzle setImageIcon:[UIImage imageNamed:@"puzzle_308"]];
    
    PhotoPrintData *puzzleHeart = [[PhotoPrintData alloc] init];
    [puzzleHeart setNameSize:@"Puzzle Сердце"];
    [puzzleHeart setPhotoObject:PhotoObjectPuzzleHeart];
    //[puzzleHeart setImageIcon:[UIImage imageNamed:@"puzzle_308"]];
    
    PhotoPrintData *brelok = [[PhotoPrintData alloc] init];
    [brelok setNameSize:@"Брелок"];
    [brelok setImageIcon:[UIImage imageNamed:@"trinket_308"]];
    [brelok setPhotoObject:PhotoObjectBrelok];

    PhotoPrintData *brelok8 = [[PhotoPrintData alloc] init];
    [brelok8 setNameSize:@"Брелок 8 граней"];
    //[brelok8 setImageIcon:[UIImage imageNamed:@"Mug_308"]];
    [brelok8 setPhotoObject:PhotoObjectBrelokEightCorner];

    PhotoPrintData *clock = [[PhotoPrintData alloc] init];
    [clock setNameSize:@"Часы"];
    [clock setImageIcon:[UIImage imageNamed:@"clock_308"]];
    [clock setPhotoObject:PhotoObjectClock];
    
    PhotoPrintData *bag = [[PhotoPrintData alloc] init];
    [bag setNameSize:@"Сумка Хлопок"];
    //[clock setImageIcon:[UIImage imageNamed:@"Mug_308"]];
    [bag setPhotoObject:PhotoObjectBagCoton];
    
    PhotoPrintData *bagStudent = [[PhotoPrintData alloc] init];
    [bagStudent setNameSize:@"Сумка Молодежь"];
    //[bagStudent setImageIcon:[UIImage imageNamed:@"Mug_308"]];
    [bagStudent setPhotoObject:PhotoObjectBagStudents];
    
    PhotoPrintData *plate = [[PhotoPrintData alloc] init];
    [plate setNameSize:@"Тарелка"];
    [plate setImageIcon:[UIImage imageNamed:@"plate_308"]];
    [plate setPhotoObject:PhotoObjectPlate];
    
    PhotoPrintData *canvas = [[PhotoPrintData alloc] init];
    [canvas setNameSize:@"Холст"];
    [canvas setCategoryType:StoreTypePhotoAlbum];
    [canvas setImageIcon:[UIImage imageNamed:@"canvas_308"]];
    [canvas setPhotoObject:PhotoObjectCanvas];
    
    NSArray *array = [NSArray arrayWithObjects://cup,
                      cupHameleon,
                      //cupColor,
                      cupHeart,
                      cupGlass,
                      cupLatte,
                      tShirt,
                      mouseMat,
                      //puzzle,
                      //puzzleHeart,
                      brelok,
                      //brelok8,
                      clock,
                      //bag,
                      //bagStudent,
                      plate,
                      //canvas,
                      nil];
    return array;
}




- (NSArray*) makeCoverCaseList {
    PhotoPrintData *cover4 = [[PhotoPrintData alloc] init];
    [cover4 setNameSize:@"Чехол iPhone 4"];
    [cover4 setCategoryType:StoreTypeCoverCase];
    [cover4 setImageIcon:[UIImage imageNamed:@"iPhone4_308"]];
    [cover4 setPhotoObject:PhotoObjectCaseIPhone4];
    
    PhotoPrintData *cover5 = [[PhotoPrintData alloc] init];
    [cover5 setNameSize:@"Чехол iPhone 5"];
    [cover5 setCategoryType:StoreTypeCoverCase];
    [cover5 setImageIcon:[UIImage imageNamed:@"iPhone5_308"]];
    [cover5 setPhotoObject:PhotoObjectCaseIPhone5];
    
    PhotoPrintData *cover6 = [[PhotoPrintData alloc] init];
    [cover6 setNameSize:@"Чехол iPhone 6"];
    [cover6 setCategoryType:StoreTypeCoverCase];
    [cover6 setImageIcon:[UIImage imageNamed:@"iPhone6_308"]];
    [cover6 setPhotoObject:PhotoObjectCaseIPhone6];
    
    PhotoPrintData *magnitCollage = [[PhotoPrintData alloc] init];
    [magnitCollage setNameSize:@"Магнит Коллаж"];
    [magnitCollage setCategoryType:StoreTypePhotoAlbum];
    [magnitCollage setImageIcon:[UIImage imageNamed:@"magnet_308"]];
    [magnitCollage setPhotoObject:PhotoObjectMagnitCollage];
    
    PhotoPrintData *magnitSingle = [[PhotoPrintData alloc] init];
    [magnitSingle setNameSize:@"Магнит 7x11"];
    [magnitSingle setCategoryType:StoreTypePhotoAlbum];
    [magnitSingle setImageIcon:[UIImage imageNamed:@"magnet_308"]];
    [magnitSingle setPhotoObject:PhotoObjectMagnitSingle];
    
    PhotoPrintData *magnitHeart = [[PhotoPrintData alloc] init];
    [magnitHeart setNameSize:@"Магнит 'Сердце'"];
    [magnitHeart setCategoryType:StoreTypePhotoAlbum];
    [magnitHeart setImageIcon:[UIImage imageNamed:@"magnet_heart_308"]];
    [magnitHeart setPhotoObject:PhotoObjectMagnitHeart];
    
    NSArray *array = [NSArray arrayWithObjects://cover4,
                      cover5,
                      cover6,
                      magnitCollage,
                      //magnitSingle,
                      magnitHeart,
                      nil];
    return array;
}



- (NSArray*) makePhotoAlbum {
    PhotoPrintData *albumRectangle = [[PhotoPrintData alloc] init];
    [albumRectangle setNameSize:@"Прямоугольный"];
    [albumRectangle setAlbumType:AlbumTypeRectangle];
    [albumRectangle setCategoryType:StoreTypePhotoAlbum];
    [albumRectangle setImageIcon:[UIImage imageNamed:@"album_rect"]];
    [albumRectangle setPhotoObject:PhotoObjectAlbum_Marriage];
    
    
    PhotoPrintData *albumSquare = [[PhotoPrintData alloc] init];
    [albumSquare setNameSize:@"Квадратный"];
    [albumSquare setAlbumType:AlbumTypeSquare];
    [albumSquare setCategoryType:StoreTypePhotoAlbum];
    [albumSquare setImageIcon:[UIImage imageNamed:@"album_square"]];
    [albumSquare setPhotoObject:PhotoObjectAlbum_Marriage];
    
    NSArray *array = [NSArray arrayWithObjects:albumRectangle, albumSquare, nil];
    return array;
}*/




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Select Photo
//    if ([segue.destinationViewController isKindOfClass:[SelectedPhotoViewController class]]) {
//        NSArray *selectedArray = [self.collectionView indexPathsForSelectedItems];
//        if ([selectedArray count] > 0) {
//            NSIndexPath *selected = [selectedArray firstObject];
//            StoreItem *item = [self.storeItems objectAtIndex:selected.row];
//            [segue.destinationViewController setStoreItemInit:item];
//        }
//    }
    
    
    // ShowCase
    if ([segue.destinationViewController isKindOfClass:[ShowCaseViewController class]]) {
        NSArray *selectedArray = [self.collectionView indexPathsForSelectedItems];
        if ([selectedArray count] > 0) {
            NSIndexPath *selected = [selectedArray firstObject];
            StoreItem *item = [self.storeItems objectAtIndex:selected.row];
            [segue.destinationViewController setPurshaseStoreItem:item];
        }
    }
    
    
    // Size Album
    /*if ([segue.destinationViewController isKindOfClass:[AlbumSizeViewController class]]) {
        NSArray *selectedArray = [self.collectionView indexPathsForSelectedItems];
        if ([selectedArray count] > 0) {
            NSIndexPath *indexpath = [selectedArray firstObject];
            
            PhotoPrintData *print = [self.printObjects objectAtIndex:indexpath.row];
            [segue.destinationViewController setPhotoPrintData:print];
        }
    }*/
    
    
    
    // Album Configurator
    if ([segue.destinationViewController isKindOfClass:[AlbumConfiguratorViewController class]]) {
        NSArray *selectedArray = [self.collectionView indexPathsForSelectedItems];
        if ([selectedArray count] > 0) {
            NSIndexPath *indexpath = [selectedArray firstObject];

            StoreItem *storeItem = [self.storeItems objectAtIndex:indexpath.row];
            [segue.destinationViewController setStoreItemInit:storeItem];
        }

    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    CGFloat offset = 8.f;
    CGFloat maxSide = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    CGFloat minSide = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        // Landscape
        size = CGSizeMake((maxSide - offset) / 3 - 3.f, 148.f);
    } else {
        // PORTRAIT
        size = CGSizeMake((minSide - offset) / 2 - 2.f, 148.f);
    }
    
    return size;//CGRectGetWidth(self.view.frame) > CGRectGetHeight(self.view.frame) ?  CGSizeMake(90, 90) : CGSizeMake(154.f, 148.f);
}

// Высота
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4.f;
}

// Ширина
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.f;
}

@end
