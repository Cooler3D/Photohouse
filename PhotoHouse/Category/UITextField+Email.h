//
//  UITextField+Email.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Email)
/** Проверяем введенный E-mail, нужно вызывать в методе UITextFieldDelegate - shouldChangeCharactersInRange
 *@param range диапозон
 *@param string введенная строка
 *@return если YES можем редактировать, NO нельзя
 */
- (BOOL) emailShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end
