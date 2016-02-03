//
//  CoreDataStore.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/29/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "CoreDataStore.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropCover.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropColor.h"
#import "PropStyle.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"
#import "PlaceHolder.h"

#import "StoreEntity.h"
#import "PropCoverEntity.h"
#import "PropSizeEntity.h"
#import "PropTypeEntity.h"
#import "PropUturnEntity.h"
#import "PropColorEntity.h"
#import "PropStyleEntity.h"

#import "PropTemplateEntity.h"
#import "PropLayoutEntity.h"
#import "PropLayerImageEntity.h"
#import "PropPlaceHolderEntity.h"



typedef enum {
    AlbumTypeFrontImage,    // Передняя картинка разворот
    AlbumTypeBackImage,     // Задняя картинка разворот
    AlbumTypeClearImage,    // Разворот очистки
    AlbumFrontImages,       // Картинки для передний пользовательские
    AlbumBackImages         // Каринки для задней пользовательские
} AlbumTypeImage;



NSString *const STORE_ENTITY        = @"StoreEntity";
NSString *const PROP_COVER_ENTITY   = @"PropCoverEntity";
NSString *const PROP_UTURN_ENTITY   = @"PropUturnEntity";
NSString *const PROP_SIZE_ENTITY    = @"PropSizeEntity";
NSString *const PROP_TYPE_ENTITY    = @"PropTypeEntity";
NSString *const PROP_COLOR_ENTITY   = @"PropColorEntity";
NSString *const PROP_STYLE_ENTITY   = @"PropStyleEntity";

NSString *const PROP_TEMPLATE_ENTITY     = @"PropTemplateEntity";
NSString *const PROP_LAYOUT_ENTITY       = @"PropLayoutEntity";
NSString *const PROP_LAYERIMAGE_ENTITY   = @"PropLayerImageEntity";
NSString *const PROP_PLACEHOLDER_ENTITY  = @"PropPlaceHolderEntity";

@implementation CoreDataStore
#pragma mark - Save
- (void) saveStoreArray:(NSArray *)storeItems andTemplates:(NSArray *)templates
{
    //
    [self clearStory];
    
    //
    for (StoreItem *store in storeItems) {
        StoreEntity *storeEntity = [NSEntityDescription insertNewObjectForEntityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [storeEntity setId_puchase:store.purchaseID];
        [storeEntity setCategory_id:[NSString stringWithFormat:@"%li", (long)store.categoryID]];
        [storeEntity setCategory_name:store.categoryName];
        [storeEntity setName:store.namePurchase];
        [storeEntity setType:store.typeStore];
        [storeEntity setAvailability:[NSNumber numberWithBool:store.isAvailable]];
        
        NSSet *types = [self getEntityTypesWithPropTypes:store.types andPurchaseID:store.purchaseID andTemplates:templates];
        [storeEntity addPropTypes:types];
    }
    
    [self.managedObjectContext save:nil];
}



#pragma mark - Get (Public)
- (NSArray *) getTypesWithPurchaseID:(NSString *)purchaseID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"id_puchase == %@ ", purchaseID];
    [request setPredicate:predacate];
    [request setEntity:description];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    StoreItem *item;
    
    for (StoreEntity *storyEntity in result) {
        NSArray *types = [self getPropTypesWithEntityTypes:storyEntity.propTypes andUseTemplates:NO];
        item = [[StoreItem alloc] initStoreWithPurchaseID:storyEntity.id_puchase
                                                        andTypeStore:storyEntity.type
                                                 andDescriptionStory:@""
                                                     andNamePurchase:storyEntity.name
                                                       andCategoryID:storyEntity.category_id
                                                     andCategoryName:storyEntity.category_name
                                                        andAvailable:[storyEntity.availability boolValue]
                                                            andTypes:types];
    }

    return item.types;
}



- (NSArray *) getSizesWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName
{
    //
    NSArray *result = [self getPropTypeEntityWithPurchaseID:purchaseID andPropTypeName:typeName];
    
    // Read
    PropType *propType = [[self getPropTypesWithEntityTypes:[NSSet setWithArray:result] andUseTemplates:NO] firstObject];
    return propType.sizes;
}


-(NSArray *)getUturnWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName
{
    NSArray *result = [self getPropTypeEntityWithPurchaseID:purchaseID andPropTypeName:typeName];
    
    // Read
    PropType *propType = [[self getPropTypesWithEntityTypes:[NSSet setWithArray:result] andUseTemplates:NO] firstObject];
    return propType.uturns;
}



- (NSArray *) getCoversWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName
{
    NSArray *result = [self getPropTypeEntityWithPurchaseID:purchaseID andPropTypeName:typeName];
    
    // Read
    PropType *propType = [[self getPropTypesWithEntityTypes:[NSSet setWithArray:result] andUseTemplates:NO] firstObject];
    return propType.covers;
}



-(NSArray *)getStylesWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName
{
    NSArray *result = [self getPropTypeEntityWithPurchaseID:purchaseID andPropTypeName:typeName];
    
    // Read
    PropType *propType = [[self getPropTypesWithEntityTypes:[NSSet setWithArray:result] andUseTemplates:NO] firstObject];
    return propType.styles;
}



- (NSArray *) getColorsWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName
{
    NSArray *result = [self getPropTypeEntityWithPurchaseID:purchaseID andPropTypeName:typeName];
    
    // Read
    PropType *propType = [[self getPropTypesWithEntityTypes:[NSSet setWithArray:result] andUseTemplates:NO] firstObject];
    return propType.colors;
}



- (PropType *) getDefaultAlbumParamsWithAlbumID:(NSString *)albumID andTypePropName:(NSString *)propTypeName
{
    // В массиве содержится PropTypeEntity
    NSArray *result = [self getPropTypeEntityWithPurchaseID:albumID andPropTypeName:propTypeName];
    
    // Все размеры и обложки и развороты
    PropType *propType = [[self getPropTypesWithEntityTypes:[NSSet setWithArray:result] andUseTemplates:NO] firstObject];
    
    return propType;
}




#pragma mark - Get (Public) Category
- (NSArray *) getStoreCategoryes
{
    // Block Search
    BOOL (^SearchCategoryInArrayBlock)(NSArray *, NSString *) = ^(NSArray *categoryArray, NSString *categoryName) {
        //
        for (NSString *category in categoryArray) {
            if ([category isEqualToString:categoryName]) {
                return YES;
            }
        }
        
        return NO;
    };
    
    
    
    NSArray *result = [self allObjects];
    NSMutableArray *categories = [NSMutableArray array];
    NSMutableArray *stories = [NSMutableArray array];
    for (StoreEntity *storeEntity in result) {
        BOOL isFound = SearchCategoryInArrayBlock([categories copy], storeEntity.category_name);
        if (!isFound && ![storeEntity.category_name isEqualToString:@"Услуги"]) {
            StoreItem *item = [[StoreItem alloc] initStoreWithPurchaseID:storeEntity.id_puchase
                                                            andTypeStore:storeEntity.type
                                                     andDescriptionStory:@""
                                                         andNamePurchase:storeEntity.name
                                                           andCategoryID:storeEntity.category_id
                                                         andCategoryName:storeEntity.category_name
                                                            andAvailable:[storeEntity.availability boolValue]
                                                                andTypes:[NSArray array]];
            [stories addObject:item];
            [categories addObject:storeEntity.category_name];
        }
    }
    
    // Sort
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryID" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray *final = [stories sortedArrayUsingDescriptors:descriptors];
    
    categories = [NSMutableArray array];
    for (StoreItem *item in final) {
        [categories addObject:item.categoryName];
    }
    
    return [categories copy];
}






- (NSArray *) getStoreItemsWithCategoryName:(NSString *)categoryName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"category_name CONTAINS %@ ", categoryName];
    [request setPredicate:predacate];
    [request setEntity:description];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    
    NSMutableArray *storeItems = [NSMutableArray array];
    
    for (StoreEntity *storyEntity in result) {
        NSArray *types = [self getPropTypesWithEntityTypes:storyEntity.propTypes andUseTemplates:NO];
        // Если больше одного, то делаем 1 StoreItem и в нем 1 PropType
        // Чтобы правильно отображались в магазине
        for (PropType *propType in types) {
            StoreItem *item = [[StoreItem alloc] initStoreWithPurchaseID:storyEntity.id_puchase
                                                            andTypeStore:storyEntity.type
                                                     andDescriptionStory:@""
                                                         andNamePurchase:storyEntity.name
                                                           andCategoryID:storyEntity.category_id
                                                         andCategoryName:storyEntity.category_name
                                                            andAvailable:[storyEntity.availability boolValue]
                                                                andTypes:[NSArray arrayWithObject:propType]];
            if ([storyEntity.availability boolValue]) {
                [storeItems addObject:item];
            }
            
        }
    }
    
    return [storeItems copy];
}



- (NSArray *) getAlbumStoreItemsWithCategoryName:(NSString *)categoryName andAlbumPurshaseID:(NSInteger)purchaseID
{
//    CoreDataImageCount *coreCount = [[CoreDataImageCount alloc] init];
//#warning ToDo: ImageCount
//    NSArray *styles = [coreCount getPropStylesForAlbumWithPurchaseID:[NSString stringWithFormat:@"%li", (long)purchaseID] andUturnPagesCount:@""];
//    
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    NSEntityDescription *description = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
//    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"category_name CONTAINS %@ ", categoryName];
//    [request setPredicate:predacate];
//    [request setEntity:description];
//    
//    
//    NSError *fetchError = nil;
//    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
//    if (fetchError) {
//        NSLog(@"fetchError: %@", fetchError);
//    }
//    
//    
//    NSMutableArray *storeItems = [NSMutableArray array];
//    StoreEntity *storyEntity = [result firstObject];
    
    StoreItem *storeItem = [[self getStoreItemsWithCategoryName:categoryName] firstObject];
    NSArray *styles = [self getStylesWithPurchaseID:storeItem.purchaseID andTypePropName:TypeNameDesign];
    NSMutableArray *mutable = [NSMutableArray array];
    
    
    NSArray *result = [self getPropTypeEntityWithPurchaseID:storeItem.purchaseID andPropTypeName:TypeNameDesign];
    PropType *propType = [[self getPropTypesWithEntityTypes:[NSSet setWithArray:result] andUseTemplates:NO] firstObject];

    
    for (PropStyle *style in styles) {
        PropType *pType = [[PropType alloc] initTypeName:propType.name
                                                andPrice:propType.price
                                                andSizes:propType.sizes
                                               andUturns:propType.uturns
                                               andCovers:propType.covers
                                               andColors:propType.colors
                                               andStyles:propType.styles
                                            andTemplates:propType.templates];
        [pType setSelectPropStyle:style];
        
        //
        StoreItem *item = [[StoreItem alloc] initStoreWithPurchaseID:storeItem.purchaseID
                                                        andTypeStore:storeItem.typeStore
                                                 andDescriptionStory:@""
                                                     andNamePurchase:storeItem.namePurchase
                                                       andCategoryID:[NSString stringWithFormat:@"%li", (long)storeItem.categoryID]
                                                     andCategoryName:storeItem.categoryName
                                                        andAvailable:[storeItem isAvailable]
                                                            andTypes:[NSArray arrayWithObject:pType]];
        if ([storeItem isAvailable]) {
            [mutable addObject:item];
        }
    }
    
    return [mutable copy];
}



#pragma mark - Get Price (Public)
- (NSString *) getCategoryTitleWithCategoryID:(NSInteger)categoryID {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"category_id CONTAINS %@", [NSString stringWithFormat:@"%li", (long)categoryID]];
    [request setPredicate:predacate];
    [request setEntity:description];
    [request setFetchLimit:1];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    StoreEntity *storeEntity = [result firstObject];

    return storeEntity.category_name;
}




#pragma mark - Get Templates (Public)
-(NSArray *)getStylesWithAlbumPropSize:(PropSize *)propSize
{
    // Блок поиска обложки из шаблона
//    PropStyle* (^SearchCoverLayoutBlock)(Template *) = ^(Template *curTemplate) {
//        for (Layout *layout in curTemplate.layouts) {
//            if ([layout.layoutType isEqualToString:@"cover"]) {
//                UIImage *imagePreview = layout.backLayer.image.image;
//                PropStyle *propsTyle = [[PropStyle alloc] initWithStyleName:curTemplate.name andMaxCount:9 andMinCount:9 andImage:imagePreview];
//                return propsTyle;
//            }
//        }
//        
//        return [PropStyle new];
//    };
//    
//    
//    //
//    NSArray *result = [self getAllTemplates];
//    
//    //
//    NSMutableArray *styles = [NSMutableArray array];
//    for (Template *template in result) {
//        if ([template.size isEqualToString:propSize.size]) {
//            
//            PropStyle *style = SearchCoverLayoutBlock(template);
//            if (style.styleName) {
//                [styles addObject:style];
//            }
//            
//        }
//    }
    return [NSArray array];//[styles copy];
}




- (NSArray *) getAllTemplatesWithPurchaseID:(NSString *)purchaseID andPropTypeName:(NSString *)propTypeName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"id_puchase CONTAINS %@ ", purchaseID];
    [request setPredicate:predacate];
    [request setEntity:description];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    StoreItem *item;
    
    for (StoreEntity *storyEntity in result) {
        NSArray *types = [self getPropTypesWithEntityTypes:storyEntity.propTypes andUseTemplates:YES];
        item = [[StoreItem alloc] initStoreWithPurchaseID:storyEntity.id_puchase
                                             andTypeStore:storyEntity.type
                                      andDescriptionStory:@""
                                          andNamePurchase:storyEntity.name
                                            andCategoryID:storyEntity.category_id
                                          andCategoryName:storyEntity.category_name
                                             andAvailable:[storyEntity.availability boolValue]
                                                 andTypes:types];
    }
    
    NSArray *propTypes = item.types;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", propTypeName];
    PropType *propType = [[propTypes filteredArrayUsingPredicate:predicate] firstObject];
    
    //NSMutableArray *templates = [NSMutableArray array];
//    for (TemplateEntity *templateEntity in result) {
//        NSArray *layouts = [self getLayoutsWithEntityLayouts:templateEntity.layouts];
//        Template *template = [[Template alloc] initTemplateName:templateEntity.name
//                                                    andFontName:templateEntity.font
//                                                  andIdTemplate:templateEntity.id_template
//                                                        andSize:templateEntity.size
//                                                     andLayouts:layouts];
//        [templates addObject:template];
//    }
    
    return propType.templates;//[templates copy];
}


- (Template *) getTemplateWithPurchaseID:(NSString *)purchaseID
                         andPropTypeName:(NSString *)propTypeName
                            TemplateSize:(NSString *)templateSize
                         andTemplateName:(NSString *)templateName;
{
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    NSEntityDescription *description = [NSEntityDescription entityForName:TemplateEntitys inManagedObjectContext:self.managedObjectContext];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND processInsert == NO", templateName];
//    [request setPredicate:predicate];
//    [request setEntity:description];
//    
//    NSError *fetchError = nil;
//    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
//    if (fetchError) {
//        NSLog(@"fetchError: %@", fetchError);
//    }
//    
//    NSMutableArray *templates = [NSMutableArray array];
//    for (TemplateEntity *templateEntity in result) {
//        NSArray *layouts = [self getLayoutsWithEntityLayouts:templateEntity.layouts];
//        
//        // Sorted with paegeIndex
//        NSMutableArray *mutable = [layouts mutableCopy];
//        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pageIndex" ascending:YES];
//        NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
//        layouts = [mutable sortedArrayUsingDescriptors:descriptors];
//        
//        Template *template = [[Template alloc] initTemplateName:templateEntity.name
//                                                    andFontName:templateEntity.font
//                                                  andIdTemplate:templateEntity.id_template
//                                                        andSize:templateEntity.size
//                                                     andLayouts:layouts];
//        if ([template.size isEqualToString:templateSize]) {
//            [templates addObject:template];
//        }
//    }
    
    NSArray *allTemplates = [self getAllTemplatesWithPurchaseID:purchaseID andPropTypeName:propTypeName];
    Template *originalTemplate;
    for (Template *template in allTemplates) {
        if ([template.size isEqualToString:templateSize] && [template.name isEqualToString:templateName]) {
            originalTemplate = template;
        }
    }
    
    return originalTemplate;//[templates firstObject];
}


-(Layout *) getCoverAlbumLayoutSize:(PropSize *)size andStyle:(PropStyle *)style
{
//    Template *template = [self getTemplateWithTemplateSize:size.size andTemplateName:style.styleName];
//    Layout *cover = template.layoutCover;
    return nil;//cover;
}



-(NSArray *)getPagesAlbumLayoutSize:(PropSize *)size andStyle:(PropStyle *)style
{
//    Template *template = [self getTemplateWithTemplateSize:size.size andTemplateName:style.styleName];
//    NSArray *pages = template.layoutPages;
    return nil;//pages;
}


-(void)synchorizeTemplateAfterDowloadImages:(Template *)albumTemplate
                              andPurchaseID:(NSString *)purchaseID
                            andPropTypeName:(NSString *)propTypeName
                               TemplateSize:(NSString *)templateSize
                            andTemplateName:(NSString *)templateName
{
    if (!albumTemplate) {
        return;
    }
    //
    NSParameterAssert(albumTemplate);
    
    // Remove Template
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"id_puchase CONTAINS %@ ", purchaseID];
    [request setPredicate:predacate];
    [request setEntity:description];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    PropTypeEntity *propTypeEntity;
    
    for (StoreEntity *storeEntity in result) {
        propTypeEntity = [self getPropTypeEntityWithSet:storeEntity.propTypes andPropTypeName:propTypeName];
        NSParameterAssert(propTypeEntity);
        
        PropTemplateEntity *propTemplate = [self getPropTemplateEntityWithTemplatesSet:propTypeEntity.templates andSize:templateSize andNameTemplate:templateName];
        NSParameterAssert(propTemplate);
        //NSLog(@"template: %@; %@", propTemplate.name, propTemplate.size);
        
        [propTypeEntity removeTemplatesObject:propTemplate];
    }
    
    
    // Add
    Template *template = [self getTemplateWithPurchaseID:purchaseID andPropTypeName:propTypeName TemplateSize:templateSize andTemplateName:templateName];
    NSLog(@"Template: %@ == null", template);
    
    PropTemplateEntity *newTemplateEntity = [[self getEntityTemplatesWithTemplates:[NSArray arrayWithObject:albumTemplate]] anyObject];
    [propTypeEntity addTemplatesObject:newTemplateEntity];
    
    template = [self getTemplateWithPurchaseID:purchaseID andPropTypeName:propTypeName TemplateSize:templateSize andTemplateName:templateName];
    NSLog(@"Template: %@ != null", template);
}




#pragma mark - Get NSSet's (Private)
- (NSSet *) getEntityTypesWithPropTypes:(NSArray *)types andPurchaseID:(NSString *)purchaseID andTemplates:(NSArray *)templates
{
    NSMutableSet *typesSet = [[NSMutableSet alloc] init];
    
    //
    for (PropType *propType in types)
    {
        PropTypeEntity *propTypeEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_TYPE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [propTypeEntity setItem_id:purchaseID];
        [propTypeEntity setPrice:[NSNumber numberWithInteger:propType.price]];
        [propTypeEntity setPropName:propType.name];
        
        NSSet *sizes = [self getEntitySizesWithPropSizes:propType.sizes];
        NSSet *uturns = [self getEntityUturnsWithPropUturs:propType.uturns];
        NSSet *covers = [self getEntityCoversWithPropCovers:propType.covers];
        NSSet *colors = [self getEntityColorsWithPropColors:propType.colors];
        NSSet *styles = [self getEntityStylesWithPropStyles:propType.styles];
//        NSSet *templs = [self getEntityTemplatesWithTemplates:templates];
        [propTypeEntity addSizes:sizes];
        [propTypeEntity addCovers:covers];
        [propTypeEntity addUturns:uturns];
        [propTypeEntity addColors:colors];
        [propTypeEntity addStyles:styles];
//        [propTypeEntity addTemplates:templs];
        
        // Если это конструкторский альбом, то сохраняем Templates
        // Для остальных не добавляем, чтобы не тратить время
        if ([propType.name isEqualToString:TypeNameConstructor]) {
            NSSet *templs = [self getEntityTemplatesWithTemplates:templates];
            [propTypeEntity addTemplates:templs];
        }
        
        [typesSet addObject:propTypeEntity];
    }
    
    return [typesSet copy];
}



- (NSSet *) getEntitySizesWithPropSizes:(NSArray *)sizes
{
    NSMutableSet *sizeSet = [[NSMutableSet alloc] init];
    
    for (PropSize *propSize in sizes) {
        PropSizeEntity *propSizeEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_SIZE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [propSizeEntity setSize:propSize.sizeName];
        [propSizeEntity setPrice:[NSNumber numberWithInteger:propSize.price]];
        [sizeSet addObject:propSizeEntity];
    }
    
    return [sizeSet copy];
}



- (NSSet *) getEntityCoversWithPropCovers:(NSArray *)covers
{
    NSMutableSet *coverSet = [[NSMutableSet alloc] init];
    
    for (PropCover *propCover in covers) {
        PropCoverEntity *propCoverEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_COVER_ENTITY inManagedObjectContext:self.managedObjectContext];
        [propCoverEntity setCover:propCover.cover];
        [propCoverEntity setPrice:[NSNumber numberWithInteger:propCover.price]];
        [coverSet addObject:propCoverEntity];
    }
    
    return [coverSet copy];
}



- (NSSet *) getEntityUturnsWithPropUturs:(NSArray *)uturns
{
    NSMutableSet *uturnSet = [[NSMutableSet alloc] init];
    
    for (PropUturn *propUturn in uturns) {
        PropUturnEntity *propUturnEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_UTURN_ENTITY inManagedObjectContext:self.managedObjectContext];
        [propUturnEntity setUturn:propUturn.uturn];
        [propUturnEntity setPrice:[NSNumber numberWithInteger:propUturn.price]];
        [uturnSet addObject:propUturnEntity];
    }
    
    return [uturnSet copy];
}


- (NSSet *) getEntityColorsWithPropColors:(NSArray *)colors
{
    NSMutableSet *colorSet = [[NSMutableSet alloc] init];
    
    for (PropColor *propColor in colors) {
        PropColorEntity *propColorEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_COLOR_ENTITY inManagedObjectContext:self.managedObjectContext];
        [propColorEntity setColorName:propColor.color];
        [propColorEntity setPrice:[NSNumber numberWithInteger:propColor.price]];
        [colorSet addObject:propColorEntity];
    }
    
    return [colorSet copy];
}


- (NSSet *) getEntityStylesWithPropStyles:(NSArray *)styles
{
    NSMutableSet *styleSet = [[NSMutableSet alloc] init];
    
    for (PropStyle *propStyle in styles) {
        PropStyleEntity *propStyleEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_STYLE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [propStyleEntity setStyleName:propStyle.styleName];
        [propStyleEntity setMaxCount:[NSNumber numberWithInteger:propStyle.maxCount]];
        [propStyleEntity setMinCount:[NSNumber numberWithInteger:propStyle.minCount]];
        [propStyleEntity setStyleImage:UIImagePNGRepresentation(propStyle.imagePreview)];
        [styleSet addObject:propStyleEntity];
    }
    
    return [styleSet copy];
}



- (NSSet *) getEntityTemplatesWithTemplates:(NSArray *)templates
{
    NSMutableSet *templatesSet = [NSMutableSet set];
    
    for (Template *template in templates) {
        PropTemplateEntity *templateEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_TEMPLATE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [templateEntity setFont:template.fontName];
        [templateEntity setName:template.name];
        [templateEntity setId_template:template.id_template];
        [templateEntity setSize:template.size];
        
        NSSet *layouts = [self getEntityLayoutWithLayouts:template.layouts];
        [templateEntity addLayouts:layouts];
        
        [templatesSet addObject:templateEntity];
    }

    
    return [templatesSet copy];
}


- (NSSet *) getEntityLayoutWithLayouts:(NSArray *)layouts
{
    NSMutableSet *mutablelayouts = [NSMutableSet set];
    
    for (Layout *layout in layouts) {
        PropLayoutEntity *layoutEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_LAYOUT_ENTITY inManagedObjectContext:self.managedObjectContext];
        [layoutEntity setId_layout:layout.id_layout];
        [layoutEntity setLayoutType:layout.layoutType];
        [layoutEntity setTemplate_psd:layout.template_psd];
        [layoutEntity setCombinedLayer:[self getPlaceHolderEntityWithPlaceHolder:layout.combinedLayer]];
        [layoutEntity setNoScaleCombined:NSStringFromCGRect(layout.noscaleCombinedLayer)];
         
        
        NSArray *back = [self getEntityLayerImageWithImages:[NSArray arrayWithObject:layout.backLayer.image] andLayerTypeImage:AlbumTypeBackImage];
        NSArray *front = [self getEntityLayerImageWithImages:[NSArray arrayWithObject:layout.frontLayer.image] andLayerTypeImage:AlbumTypeFrontImage];
//        NSArray *clear = [self getEntityLayerImageWithImages:[NSArray arrayWithObject:layout.clearLayer.image] andLayerTypeImage:AlbumTypeClearImage];
        
        NSArray *backImages = [self getEntityLayerImageWithImages:layout.backLayer.images andLayerTypeImage:AlbumBackImages];
        NSArray *frontImages = [self getEntityLayerImageWithImages:layout.frontLayer.images andLayerTypeImage:AlbumFrontImages];
        
        NSMutableSet *set = [NSMutableSet set];
        [set addObjectsFromArray:back];
        [set addObjectsFromArray:front];
//        [set addObjectsFromArray:clear];
        [set addObjectsFromArray:backImages];
        [set addObjectsFromArray:frontImages];
        [layoutEntity addLayer:[set copy]];
        
        [mutablelayouts addObject:layoutEntity];
    }
    
    
    return [mutablelayouts copy];
}


- (NSArray *) getEntityLayerImageWithImages:(NSArray *)images andLayerTypeImage:(AlbumTypeImage)layerTypeImage
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (Image *image in images) {
        PropLayerImageEntity *layerEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_LAYERIMAGE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [layerEntity setLayerType:[NSNumber numberWithInteger:layerTypeImage]];
        [layerEntity setPixelLimit:[NSNumber numberWithInteger:[image.pixelsLimit integerValue]]];
        [layerEntity setPixelMin:[NSNumber numberWithInteger:[image.pixelsMin integerValue]]];
        [layerEntity setZ:[NSNumber numberWithInteger:[image.z integerValue]]];
        [layerEntity setRect:NSStringFromCGRect(image.rect)/*[self getStringRectWithPosition:image.rect]*/];
        [layerEntity setCrop:NSStringFromCGRect(image.crop)/*[self getStringRectWithPosition:image.crop]*/];
        [layerEntity setImage:UIImagePNGRepresentation(image.image)];
        [layerEntity setUrl:image.url_image];
        
        [mutableArray addObject:layerEntity];
    }
    
    return [mutableArray copy];
}


- (PropPlaceHolderEntity *) getPlaceHolderEntityWithPlaceHolder:(PlaceHolder *)placeHolder
{
    PropPlaceHolderEntity *pHolderEntity = [NSEntityDescription insertNewObjectForEntityForName:PROP_PLACEHOLDER_ENTITY inManagedObjectContext:self.managedObjectContext];
    [pHolderEntity setPsdPath:placeHolder.psdPath];
    [pHolderEntity setLayerNum:placeHolder.layerNum];
    [pHolderEntity setPngPath:placeHolder.pngPath];
    [pHolderEntity setRect:NSStringFromCGRect(placeHolder.rect)];
    return pHolderEntity;
}




#pragma mark - Get Array's
/*! Возвращаем массив PropType
 *@entityTypes из CoreData PropTypeEntity
 *@useTemplates нужно ли добавлять шаблоны в PropType, Yes - нужно, No - не требуется
 *@return возвращаем массив PropType
 */
- (NSArray *) getPropTypesWithEntityTypes:(NSSet *)entityTypes andUseTemplates:(BOOL)useTemplates
{
    NSMutableArray *types = [NSMutableArray array];
    
    for (PropTypeEntity *typeEntity in entityTypes)
    {
        NSArray *sizes = [self getPropSizeWithEntitySizes:typeEntity.sizes];
        NSArray *uturns = [self getPropUturnWithEntityUturns:typeEntity.uturns];
        NSArray *covers = [self getPropCoverWithEntityCovers:typeEntity.covers];
        NSArray *colors = [self getPropColorWithEntityColors:typeEntity.colors];
        NSArray *styles = [self getPropStyleWithEntityStyless:typeEntity.styles];
        NSArray *templates = useTemplates ? [self getPropTemplateWithEntityTemplates:typeEntity.templates] : nil;
        
        PropType *type = [[PropType alloc] initTypeName:typeEntity.propName
                                               andPrice:[typeEntity.price integerValue]
                                               andSizes:sizes andUturns:uturns
                                              andCovers:covers
                                              andColors:colors
                                              andStyles:styles
                                           andTemplates:templates];
        [types addObject:type];
    }
    
    return [types copy];
}



- (NSArray *) getPropSizeWithEntitySizes:(NSSet *)entitySizes
{
    NSMutableArray *sizes = [NSMutableArray array];
    
    for (PropSizeEntity *sizeEntity in entitySizes) {
        PropSize *size = [[PropSize alloc] initSize:sizeEntity.size andPrice:[sizeEntity.price integerValue]];
        [sizes addObject:size];
    }
    return [sizes copy];
}



- (NSArray *) getPropUturnWithEntityUturns:(NSSet *)entityUturns
{
    NSMutableArray *uturns = [NSMutableArray array];
    
    for (PropUturnEntity *uturnEntity in entityUturns) {
        PropUturn *uturn = [[PropUturn alloc] initUturn:uturnEntity.uturn andPrice:[uturnEntity.price integerValue]];
        [uturns addObject:uturn];
    }
    return [uturns copy];
}



- (NSArray *) getPropCoverWithEntityCovers:(NSSet *)entityCovers
{
    NSMutableArray *covers = [NSMutableArray array];
    
    for (PropCoverEntity *coverEntity in entityCovers) {
        PropCover *cover = [[PropCover alloc] initCover:coverEntity.cover andPrice:[coverEntity.price integerValue]];
        [covers addObject:cover];
    }
    return [covers copy];
}



- (NSArray *) getPropColorWithEntityColors:(NSSet *)entityColors
{
    NSMutableArray *colors = [NSMutableArray array];
    
    for (PropColorEntity *colorEntity in entityColors) {
        PropColor *color = [[PropColor alloc] initColor:colorEntity.colorName andPrice:[colorEntity.price integerValue]];
        [colors addObject:color];
    }
    return [colors copy];
}


- (NSArray *) getPropStyleWithEntityStyless:(NSSet *)entityStyles
{
    NSMutableArray *styles = [NSMutableArray array];
    
    for (PropStyleEntity *styleEntity in entityStyles) {
        PropStyle *style = [[PropStyle alloc] initWithStyleName:styleEntity.styleName andMaxCount:[styleEntity.maxCount integerValue] andMinCount:[styleEntity.minCount integerValue] andImage:[UIImage imageWithData:styleEntity.styleImage]];
        [styles addObject:style];
    }
    return [styles copy];
}


- (NSArray *) getPropTemplateWithEntityTemplates:(NSSet *)entityTemplates
{
    NSMutableArray *templates = [NSMutableArray array];
    for (PropTemplateEntity *templateEntity in [entityTemplates allObjects]) {
        NSArray *layouts = [self getPropLayoutsWithEntityLayouts:templateEntity.layouts];
        Template *template = [[Template alloc] initTemplateName:templateEntity.name
                                                    andFontName:templateEntity.font
                                                  andIdTemplate:templateEntity.id_template
                                                        andSize:templateEntity.size
                                                     andLayouts:layouts];
        [templates addObject:template];
    }
    
    return [templates copy];
}

- (NSArray *) getPropLayoutsWithEntityLayouts:(NSSet *)entitylayouts
{
    NSMutableArray *layouts = [NSMutableArray array];
    
    for (PropLayoutEntity *layoutEntity in [entitylayouts allObjects]) {
        Layer *backLayer    = [self getPropLayerWithLayerImageEntitys:layoutEntity.layer withType:AlbumTypeBackImage];
        Layer *frontLayer   = [self getPropLayerWithLayerImageEntitys:layoutEntity.layer withType:AlbumTypeFrontImage];
        Layer *clearLayer   = [self getPropLayerWithLayerImageEntitys:layoutEntity.layer withType:AlbumTypeClearImage];
        PlaceHolder *combinedLayer = [self getPlaceHolderWithEntity:layoutEntity.combinedLayer];
        Layout *layout = [[Layout alloc] initLayoutWithID:layoutEntity.id_layout
                                            andLayoutType:layoutEntity.layoutType
                                           andtemplatePSD:layoutEntity.template_psd
                                             andBackLayer:backLayer
                                            andFlontLayer:frontLayer
                                            andClearLayer:clearLayer
                                             andPageIndex:0 andCombinedLayer:combinedLayer
                                  andNoscaleCombinedLayer:CGRectFromString(layoutEntity.noScaleCombined)];
        [layouts addObject:layout];
    }
    
    [layouts sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        Layout *layout1 = (Layout*)obj1;
        Layout *layout2 = (Layout*)obj2;
        
        NSString *idLayout1 = [layout1.id_layout isEqualToString:LayoutCover] ? @"unwrap_00" : layout1.id_layout;
        NSString *idLayout2 = [layout2.id_layout isEqualToString:LayoutCover] ? @"unrwap_00" : layout2.id_layout;
        
        idLayout1 = [idLayout1 stringByReplacingOccurrencesOfString:@"unwrap_" withString:@""];
        idLayout2 = [idLayout2 stringByReplacingOccurrencesOfString:@"unwrap_" withString:@""];
        
        NSInteger layoutInt1 = [idLayout1 integerValue];
        NSInteger layoutInt2 = [idLayout2 integerValue];
        
        if (layoutInt1 < layoutInt2) {
            return NSOrderedAscending;
        } else if (layoutInt1 > layoutInt2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return [layouts copy];
}

- (Layer *) getPropLayerWithLayerImageEntitys:(NSSet *)layerImageEntitys withType:(AlbumTypeImage )albumType
{
    Image *back;
    NSArray *backImages;
    
    switch (albumType) {
        case AlbumTypeBackImage:
            back = [[self getImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumTypeBackImage] firstObject];
            backImages = [self getImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumBackImages];
            break;
            
        case AlbumTypeFrontImage:
            back = [[self getImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumTypeFrontImage] firstObject];
            backImages = [self getImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumFrontImages];
            break;
            
        case AlbumTypeClearImage:
            back = [[self getImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumTypeClearImage] firstObject];
            backImages = [NSArray array];
            break;
            
        default:
            break;
    }
    
    //
    Layer *layer = [[Layer alloc] initWithImage:back andImages:backImages];
    return layer;
}


// Возвращаем массив картинок пользовательских
- (NSArray *) getImagesWithLayerImageEntitys:(NSSet *)layerImageEntitys andLayerTypeImage:(AlbumTypeImage)layerTypeImage
{
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"layerType == %i", layerTypeImage];
    NSSet *result = [layerImageEntitys filteredSetUsingPredicate:predacate];
    
    
    NSMutableArray *final = [NSMutableArray array];
    for (PropLayerImageEntity *layerEntity in [result allObjects]) {
        Image *image = [[Image alloc] initWithPixelsMin:[NSString stringWithFormat:@"%li", (long)[layerEntity.pixelMin integerValue]]
                                         andPixelsLimit:[NSString stringWithFormat:@"%li",(long)[layerEntity.pixelLimit integerValue]]
                                                   andZ:[NSString stringWithFormat:@"%li",(long)[layerEntity.z  integerValue]]
                                            andUrlImage:layerEntity.url
                                           andUrlUpload:@""
                                           andPermanent:@"1"
                                                andRect:CGRectFromString(layerEntity.rect)/*[self getPositionWithStringRect:layerEntity.rect]*/
                                                andCrop:CGRectFromString(layerEntity.crop)/*[self getPositionWithStringRect:layerEntity.crop]*/
                                               andImage:[UIImage imageWithData:layerEntity.image]
                                    andImageOrientation:UIImageOrientationUp
                             andImageOrientationDefault:UIImageOrientationUp];
        [final addObject:image];
    }
    
    return [final copy];
}



- (PlaceHolder *) getPlaceHolderWithEntity:(PropPlaceHolderEntity *)pHolderEntity
{
    PlaceHolder *pholder = [[PlaceHolder alloc] initWithPsdPath:pHolderEntity.psdPath andLayerNum:pHolderEntity.layerNum andPngPath:pHolderEntity.pngPath andScalePngUrl:@"" andRect:CGRectFromString(pHolderEntity.rect)];
    return pholder;
}



#pragma mark - Remove
//- (void) removeTemplateEntityWithPurchseID:(NSString *)purchaseID
//                           andPropTypeName:(NSString *)propTypeName
//                           andSizeTemplate:(NSString *)sizeTemplate
//                           andNametemplate:(NSString *) nameTemplate
//{
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    
//    NSEntityDescription *description = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
//    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"id_puchase CONTAINS %@ ", purchaseID];
//    [request setPredicate:predacate];
//    [request setEntity:description];
//    [request setFetchLimit:1];
//    
//    
//    NSError *fetchError = nil;
//    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
//    if (fetchError) {
//        NSLog(@"fetchError: %@", fetchError);
//    }
//    
//    PropTypeEntity *propTypeEntity;
//
//    for (StoreEntity *storeEntity in result) {
//        propTypeEntity = [self getPropTypeEntityWithSet:storeEntity.propTypes andPropTypeName:propTypeName];
//        PropTemplateEntity *propTemplate = [self getPropTemplateEntityWithTemplatesSet:propTypeEntity.templates andSize:sizeTemplate andNameTemplate:nameTemplate];
//        
//        NSLog(@"template: %@; %@", propTemplate.name, propTemplate.size);
//        NSParameterAssert(PropTypeEntity);
//        
//        [propTypeEntity removeTemplatesObject:propTemplate];
//    }
//    
//    
//    Template *template = [self getTemplateWithPurchaseID:purchaseID andPropTypeName:propTypeName TemplateSize:sizeTemplate andTemplateName:nameTemplate];
//    NSLog(@"%@", template);
//    
//    //PropTemplateEntity *newTemplate = [self getEntityTemplatesWithTemplates:[NSArray arrayWithObject:temp]]
//}



- (PropTypeEntity *) getPropTypeEntityWithSet:(NSSet *)propTypeEntitys andPropTypeName:(NSString *)propTypeName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"propName == %@", propTypeName];
    PropTypeEntity *propEntity = [[propTypeEntitys filteredSetUsingPredicate:predicate] anyObject];
    
    /*for (PropTypeEntity *propTypeEntity in [propTypeEntitys allObjects]) {
        if ([propTypeEntity.propName isEqualToString:propTypeName]) {
            propEntity = propTypeEntity;
        }
    }*/
    
    return propEntity;
}


- (PropTemplateEntity *) getPropTemplateEntityWithTemplatesSet:(NSSet *)templatesSets andSize:(NSString *)sizeTemplate andNameTemplate:(NSString *)nameTemplate
{
    //PropTemplateEntity *propTemplate;
    
    for (PropTemplateEntity *propTemplate in [templatesSets allObjects]) {
        if ([propTemplate.size isEqualToString:sizeTemplate] && [propTemplate.name isEqualToString:nameTemplate]) {
            return propTemplate;
        }
    }
    
    return nil;
}


#pragma mark - Private
-(BOOL)hasStoreData
{
    NSString *categoryName = [[self getStoreCategoryes] firstObject];
    return categoryName ? YES : NO;
}


- (void) clearStory
{
    NSArray *objects = [self allObjects];
    
    for (id object in objects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Clear.Story.Error: %@", error);
    }
}



- (NSArray*) allObjects {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *desription = [NSEntityDescription entityForName:STORE_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:desription];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Fetch.Error: %@", fetchError);
    }
    
    return result;
}


- (NSArray *) getPropTypeEntityWithPurchaseID:(NSString *)purchaseID andPropTypeName:(NSString *)propTypeName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:PROP_TYPE_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"item_id == %@ AND propName CONTAINS %@",purchaseID, propTypeName];
    [request setPredicate:predacate];
    [request setEntity:description];
    
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }

    return result;
}


//- (NSString *) getStringRectWithPosition:(Position *)position
//{
//    CGRect rect = CGRectMake(position.left,
//                             position.top,
//                             position.right,
//                             position.bottom);
//    return NSStringFromCGRect(rect);
//}
//
//- (Position *) getPositionWithStringRect:(NSString *)rectString
//{
//    CGRect rect = CGRectFromString(rectString);
//    Position *position = [[Position alloc] initPositionWithRect:rect];
//    return position;
//}

@end
