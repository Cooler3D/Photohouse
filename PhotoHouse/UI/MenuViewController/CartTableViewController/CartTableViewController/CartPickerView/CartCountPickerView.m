//
//  CartCountPickerView.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/4/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "CartCountPickerView.h"



@interface CartCountPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (assign, nonatomic) NSInteger *currentIndex;
@property (strong, nonatomic) NSArray *arrayPickerPosition;
@end



@implementation CartCountPickerView

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
    self.arrayPickerPosition = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    
    [self.pickerView reloadAllComponents];
    [self.pickerView setBackgroundColor:[UIColor blackColor]];
    
    [self.okButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
}



#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}



#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.arrayPickerPosition objectAtIndex:row];
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = (self.arrayPickerPosition ? [self.arrayPickerPosition objectAtIndex:row] : @"1");
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    return attString;
}

#pragma mark - Public
- (void) showActualNumber:(NSUInteger)index {
    [self.pickerView selectRow:index-1 inComponent:0 animated:YES];
}



#pragma mark - Action
- (IBAction)actionCancelButton:(UIButton *)sender {
    [self.delegate cartCountCancel:self];
}


- (IBAction)actionOkButton:(UIButton *)sender {
    NSInteger index = [self.pickerView selectedRowInComponent:0] + 1;
    [self.delegate cartPicker:self countOk:index];
}

@end
