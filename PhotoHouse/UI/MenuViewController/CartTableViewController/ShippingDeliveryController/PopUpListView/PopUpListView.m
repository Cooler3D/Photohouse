//
//  EarlyInputView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/10/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PopUpListView.h"
#import "PopUpCell.h"

#import "DeliveryType.h"


@interface PopUpListView () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) TypeInput typeInput;
@property (strong, nonatomic) NSArray *stringsArray;
@end

@implementation PopUpListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setAllowsSelection:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stringsArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *identifer = @"Cell";
    
    PopUpCell *cell;
    if (self.typeInput == TypeInputTypeDelivery) {
        cell = [self configCellDeliveryTypeWithTableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        cell = [self configCellDefaultWithTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
    
}


#pragma mark - Cell
- (PopUpCell *) configCellDeliveryTypeWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifer = @"Cell";
    
    PopUpCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    
    if (cell == nil) {
        cell = [[PopUpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    
    DeliveryType *delType = [self.stringsArray objectAtIndex:indexPath.row];
    [cell.infoLabel setText:[NSString stringWithFormat:@"%@ - %li RUB", delType.deldescription, (long)delType.cost]];
    
    // Button
    [cell.button setTag:indexPath.row];
    [cell.button addTarget:self action:@selector(actionSelected:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (PopUpCell *) configCellDefaultWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifer = @"Cell";
    
    PopUpCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    
    if (cell == nil) {
        cell = [[PopUpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    
    NSString *string = [self.stringsArray objectAtIndex:indexPath.row];
    [cell.infoLabel setText:string];
    
    // Button
    [cell.button setTag:indexPath.row];
    [cell.button addTarget:self action:@selector(actionSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}



#pragma mark - Private
- (NSString*) formatingString:(NSString*)string {
    static const int localNumberMaxLenght = 7;
    static const int areaCodeMaxLenght = 3;
    //static const int contryCodeMaxLenght = 3;
    
    NSRange localRange = NSMakeRange([string length] - localNumberMaxLenght, localNumberMaxLenght);
    NSString *localNumberString = [string substringWithRange:localRange];
    
    NSRange codeRange = NSMakeRange([string length] - localNumberMaxLenght - areaCodeMaxLenght, areaCodeMaxLenght);
    NSString *codeString = [string substringWithRange:codeRange];
    
    return [NSString stringWithFormat:@"(%@) %@", codeString, localNumberString];
}




- (NSString*) stringRemoveCodeCountry:(NSString*)numberString {
    NSInteger index = [numberString rangeOfString:@"("].location;
    NSString *plusSymbol = [numberString substringWithRange:NSMakeRange(0, 1)];
    
    if (index != NSNotFound && [plusSymbol isEqualToString:@"+"]) {
        NSString *final = [numberString substringFromIndex:index-1];
        return final;
    } else {
        NSString *final = [self formatingString:numberString];
        return final;
    }
    
    return numberString;
}


#pragma mark - Public
- (void) showTypesArray:(NSArray*)array withTypeInput:(TypeInput)typeInput;
{
    self.typeInput = typeInput;
    self.stringsArray = array;
    [self.tableView reloadData];
}


/*- (void) showDeliveryTypes:(NSArray *)array
{
    self.stringsArray = array;
    self.typeInput = TypeInputTypeDelivery;
    [self.tableView reloadData];
}*/


#pragma mark - Actions
- (void) actionSelected:(UIButton*)sender
{
    NSString *selectString;
    if (self.typeInput == TypeInputTypeDelivery)
    {
        DeliveryType *delType = [self.stringsArray objectAtIndex:sender.tag];
        selectString = delType.code;
    }
    else
    {
        selectString = [self.stringsArray objectAtIndex:sender.tag];
        if(self.typeInput == TypeInputPhone)
        {
            selectString = [self stringRemoveCodeCountry:selectString];
        }
    }
    
    [self.delegate popUpListView:self didSelectErlyInput:selectString withType:self.typeInput];
}

@end
