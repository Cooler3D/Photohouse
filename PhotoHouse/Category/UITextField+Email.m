//
//  UITextField+Email.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "UITextField+Email.h"


typedef enum {
    AtSymbolFound,
    AtSymbolNotFound
} AtSymbol;


@implementation UITextField (Email)
- (BOOL) emailShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextField *textField = self;
    
    /*NSLog(@"textField Text: %@", textField.text);
    NSLog(@"range: %@", NSStringFromRange(range));
    NSLog(@"new symbols: %@", string);*/
    
    // E-mail
    NSString *badSymbols = @" '?!/|\"#$^&*()[];:,±><=";
    NSCharacterSet *validator = [NSCharacterSet characterSetWithCharactersInString:badSymbols];
    NSArray *components = [string componentsSeparatedByCharactersInSet:validator];
    
    /*if ([string length] > 1) {
        self.limitText -= [string length];
    }*/
    
    if ([components count] > 1 ||
        ([self findSymbol:@"@" withWord:string] == AtSymbolFound &&
         [self findSymbol:@"@" withWord:textField.text] == AtSymbolFound) ) {
            return NO;
        }
    
    if ([textField.text length] == 0 && [string isEqualToString:@"@"]) {
        return NO;
    } else if([string isEqualToString:@"@"] && [self findSymbol:@"@" withWord:textField.text] == AtSymbolNotFound) {
        //NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return YES;
    } else if([string isEqualToString:@"@"] && [self findSymbol:@"@" withWord:textField.text] == AtSymbolFound) {
        return NO;
    }

    return YES;
}


- (AtSymbol) findSymbol:(NSString*)symbol withWord:(NSString*)word {
    NSInteger loc = [word rangeOfString:symbol].location;
    
    if (loc == NSNotFound) {
        return AtSymbolNotFound;
    } else {
        return AtSymbolFound;
    }
}

@end
