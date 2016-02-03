//
//  PropType.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PropType.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropCover.h"
#import "PropStyle.h"
#import "PropColor.h"
#import "StoreItem.h"

#import "Template.h"

#import "CoreDataStore.h"


NSString *const TypeNameDesign = @"design";
NSString *const TypeNameConstructor = @"constructor";


NSString *const MUG_TYPE_COLOR = @"colored";
NSString *const MUG_TYPE_HEART = @"heart";
NSString *const MUG_TYPE_LATTE = @"latte";
NSString *const MUG_TYPE_GLASS = @"glass";
NSString *const MUG_TYPE_CHAMELEON = @"chameleon";


/*@interface PropType ()
@property (nonatomic, strong) PropCover *selectPropCover;
@property (nonatomic, strong) PropUturn *selectPropUturn;
@property (nonatomic, strong) PropSize *selectPropSize;
@property (nonatomic, strong) PropStyle *selectPropStyle;
@property (nonatomic, strong) PropColor *selectPropColor;
@end*/

@implementation PropType
@synthesize price = _price;
@synthesize styles = _styles;
@synthesize selectTemplate = _selectTemplate;
@synthesize selectPropStyle = _selectPropStyle;

#pragma mark - Init
- (id) initTypeName:(NSString *)name
           andPrice:(NSInteger)price
           andSizes:(NSArray *)sizes
          andUturns:(NSArray *)uturns
          andCovers:(NSArray *)covers
          andColors:(NSArray *)colors
          andStyles:(NSArray *)styles
       andTemplates:(NSArray *)templates
{
    self = [super init];
    if (self)
    {
        //
        _name   = name;
        _price  = price;
        _sizes = sizes;
        _uturns = uturns;
        _covers = covers;
        _colors = colors;
        _styles = styles;
        _templates = templates;
        
        [self selectedSizes:sizes andUturns:uturns andCovers:covers andColors:colors andStyles:styles];
    }
    
    return self;
}



- (id) initWithDictionary:(NSDictionary *)dictionaryType
{
    self = [super init];
    if (self) {
        //
        _name   = [dictionaryType objectForKey:@"name"];
        _price  = [[dictionaryType objectForKey:@"price"] integerValue];
        
        //
        NSDictionary *sizes = [dictionaryType objectForKey:@"size"];
        if (sizes) {
            [self parseSize:sizes];
        }
        
        NSDictionary *uturns = [dictionaryType objectForKey:@"uturn"];
        if (uturns) {
            [self parseUturn:uturns];
        }
        
        NSDictionary *covers = [dictionaryType objectForKey:@"cover"];
        if (covers) {
            [self parseCover:covers];
        }
        
        NSDictionary *colors = [dictionaryType objectForKey:@"colorized"];
        if (colors) {
            [self parseColor:colors];
        }
        
        NSArray *styles = [dictionaryType objectForKey:@"style"];
        if (styles) {
            [self parseStyle:styles];
        }
    }
    return self;
}



- (id) initTypeName:(NSString *)name
           andPrice:(NSInteger)price
        andSizeName:(NSString *)sizeName
       andUturnName:(NSString *)uturnName
       andCoverName:(NSString *)coverName
       andColorName:(NSString *)colorName
       andStyleName:(NSString *)styleName
    andUserTemplate:(Template *)userTemplate
{
    self = [super init];
    if (self)
    {
        _name = name;
        _price = price;
        _userTemplate = userTemplate;
        [self createPropsWithSizeName:sizeName andUturnName:uturnName andCoverName:coverName andColorName:colorName andStyleName:styleName];
    }

    return self;
}


- (id) initTypeName:(NSString *)name
           andPrice:(NSInteger)price
        andSizeName:(NSString *)sizeName
       andUturnName:(NSString *)uturnName
       andCoverName:(NSString *)coverName
       andColorName:(NSString *)colorName
       andStyleName:(NSString *)styleName
    andUserTemplate:(Template *)userTemplate
           andSizes:(NSArray *)sizes
          andUturns:(NSArray *)uturns
          andCovers:(NSArray *)covers
          andColors:(NSArray *)colors
          andStyles:(NSArray *)styles
{
    self = [super init];
    if (self)
    {
        _name = name;
        _price = price;
        _userTemplate = userTemplate;
        _sizes = sizes;
        _uturns = uturns;
        _covers = covers;
        _colors = colors;
        _styles = styles;
        [self createComparePropsWithSizeName:sizeName andUturnName:uturnName andCoverName:coverName andColorName:colorName andStyleName:styleName];
    }
    return self;
}



#pragma mark - Create Select
- (void) selectedSizes:(NSArray *)sizes
             andUturns:(NSArray *)uturns
             andCovers:(NSArray *)covers
             andColors:(NSArray *)colors
             andStyles:(NSArray *)styles
{
    for (PropSize *propSize in sizes) {
        if (propSize.price == 0) {
            _selectPropSize = propSize;
        }
    }
    
    for (PropUturn *propUturn in uturns) {
        if (propUturn.price == 0) {
            _selectPropUturn = propUturn;
        }
    }
    
    for (PropCover *propCover in covers) {
        if (propCover.price == 0) {
            _selectPropCover = propCover;
        }
    }
    
    for (PropColor *propColor in colors) {
        if (propColor.price == 0) {
            _selectPropColor = propColor;
        }
    }
    
    _selectPropStyle = [styles firstObject];
}



#pragma mark - Parse
- (void) parseSize:(NSDictionary *)sizes
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *key in [sizes allKeys]) {
        PropSize *propSize = [[PropSize alloc] initSize:key andPrice:[[sizes objectForKey:key] integerValue]];
        [array addObject:propSize];
    }
    
    _sizes = [array copy];
}





- (void) parseUturn:(NSDictionary *)uturns
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *key in [uturns allKeys]) {
        PropUturn *propUturn = [[PropUturn alloc] initUturn:key andPrice:[[uturns objectForKey:key] integerValue]];
        [array addObject:propUturn];
    }
    
    _uturns = [array copy];
}



- (void) parseCover:(NSDictionary *)covers
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *key in [covers allKeys]) {
        PropCover *propCover = [[PropCover alloc] initCover:key andPrice:[[covers objectForKey:key] integerValue]];
        [array addObject:propCover];
    }
    
    _covers = [array copy];
}



- (void) parseColor:(NSDictionary *)colors
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSString *key in [colors allKeys]) {
        PropColor *propColor = [[PropColor alloc] initColor:key andPrice:[[colors objectForKey:key] integerValue]];
        [array addObject:propColor];
    }
    
    _colors = [array copy];
}


- (void) parseStyle:(NSArray *)styles
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *styleDict in styles) {
        PropStyle *propStyle = [[PropStyle alloc] initWithStyleDictionary:styleDict];
        [array addObject:propStyle];
    }
    
    _styles = [array copy];
}



#pragma mark - History Order
- (void) createPropsWithSizeName:(NSString *)sizeName
                    andUturnName:(NSString *)uturnName
                    andCoverName:(NSString *)coverName
                    andColorName:(NSString *)colorName
                    andStyleName:(NSString *)styleName
{
    if(sizeName) _selectPropSize = [[PropSize alloc] initSize:sizeName andPrice:0];
    if(uturnName) _selectPropUturn = [[PropUturn alloc] initUturn:uturnName andPrice:0];
    if(coverName) _selectPropCover = [[PropCover alloc] initCover:coverName andPrice:0];
    if(colorName) _selectPropColor = [[PropColor alloc] initColor:colorName andPrice:0];
    if(styleName) _selectPropStyle = [[PropStyle alloc] initWithStyleName:styleName andMaxCount:0 andMinCount:0 andImage:nil];
    
    
    if (_selectPropSize) _sizes = [NSArray arrayWithObject:_selectPropSize];
    if (_selectPropUturn) _uturns = [NSArray arrayWithObject:_selectPropUturn];
    if (_selectPropCover) _covers = [NSArray arrayWithObject:_selectPropCover];
    if (_selectPropColor) _colors = [NSArray arrayWithObject:_selectPropColor];
    if (_selectPropStyle) _styles = [NSArray arrayWithObject:_selectPropStyle];
}



#pragma mark - Unsaved
// Здесь нужно сравнить занчения и массивами и установить правильное значение
- (void) createComparePropsWithSizeName:(NSString *)sizeName
                           andUturnName:(NSString *)uturnName
                           andCoverName:(NSString *)coverName
                           andColorName:(NSString *)colorName
                           andStyleName:(NSString *)styleName
{
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"sizeName == %@", sizeName];
    if(sizeName) _selectPropSize = (self.sizes) ? [[[self.sizes mutableCopy] filteredArrayUsingPredicate:predicate] firstObject] : [[PropSize alloc] initSize:sizeName andPrice:0];
    
    predicate = [NSPredicate predicateWithFormat:@"uturn == %@", uturnName];
    if(uturnName) _selectPropUturn = (self.uturns) ? [[[self.uturns mutableCopy] filteredArrayUsingPredicate:predicate] firstObject] :  [[PropUturn alloc] initUturn:uturnName andPrice:0];
    
    predicate = [NSPredicate predicateWithFormat:@"cover == %@", coverName];
    if(coverName) _selectPropCover = (self.covers) ? [[[self.covers mutableCopy] filteredArrayUsingPredicate:predicate] firstObject] :  [[PropCover alloc] initCover:coverName andPrice:0];
    
    predicate = [NSPredicate predicateWithFormat:@"color == %@", colorName];
    if(colorName) _selectPropColor = (self.colors) ? [[[self.colors mutableCopy] filteredArrayUsingPredicate:predicate] firstObject] :  [[PropColor alloc] initColor:colorName andPrice:0];
    
    predicate = [NSPredicate predicateWithFormat:@"styleName == %@", styleName];
    if(styleName) _selectPropStyle = (self.styles) ? [[[self.styles mutableCopy] filteredArrayUsingPredicate:predicate] firstObject] :  [[PropStyle alloc] initWithStyleName:styleName andMaxCount:0 andMinCount:0 andImage:nil];
    
    
    if (_selectPropSize) _sizes = _sizes ? _sizes : [NSArray arrayWithObject:_selectPropSize];
    if (_selectPropUturn) _uturns = _uturns ? _uturns : [NSArray arrayWithObject:_selectPropUturn];
    if (_selectPropCover) _covers = _covers ? _covers : [NSArray arrayWithObject:_selectPropCover];
    if (_selectPropColor) _colors = _colors ? _colors : [NSArray arrayWithObject:_selectPropColor];
    if (_selectPropStyle) _styles = _styles ? _styles : [NSArray arrayWithObject:_selectPropStyle];
}


-(void)updateUserTemplate:(Template *)userTemplate
{
    _userTemplate = userTemplate;
}



#pragma mark - Price
-(NSInteger)price
{
    NSUInteger symma = _price;
    symma += [_selectPropColor price];
    symma += [_selectPropUturn price];
    symma += [_selectPropSize price];
    symma += [_selectPropCover price];
    return symma;
}


#pragma mark - Styles
-(NSArray *)styles {
    return _styles;
}


- (PropStyle *)selectPropStyle {
    return _selectPropStyle ? _selectPropStyle : [self.styles firstObject];
}


#pragma mark - Selected (Getter)
-(PropColor *)selectPropColor
{
    return _selectPropColor == nil ? [_colors firstObject] : _selectPropColor;
}

-(PropCover *)selectPropCover
{
    return _selectPropCover == nil ? [_covers firstObject] : _selectPropCover;
}

-(PropSize *)selectPropSize
{
    return _selectPropSize == nil ? [_sizes firstObject] : _selectPropSize;
}


-(PropUturn *)selectPropUturn
{
    return _selectPropUturn == nil ? [_uturns firstObject] : _selectPropUturn;
}


-(Template *)selectTemplate
{
    if (!_selectTemplate || ![_selectTemplate.name isEqualToString:_selectPropStyle.styleName] || ![_selectTemplate.size isEqualToString:_selectPropSize.sizeName])
    {
        CoreDataStore *coreStore = [[CoreDataStore alloc] init];
        NSArray *allTempaltes = [coreStore getAllTemplatesWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum] andPropTypeName:_name];
        
        for (Template *template in allTempaltes) {
            if ([template.size isEqualToString:_selectPropSize.sizeName] && [template.name isEqualToString:_selectPropStyle.styleName]) {
                _selectTemplate = template;
            }
        }
        
    }
    
//#warning ToDo: Здесь может быть ошибка, если стиль не найдется!!!
    
    return _selectTemplate;
}

#pragma mark - Setter
-(void)setSelectPropStyle:(PropStyle *)selectPropStyle {
    _selectPropStyle = selectPropStyle;
    
    _selectTemplate = nil;
    _userTemplate = nil;
}

@end