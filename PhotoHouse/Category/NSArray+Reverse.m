//
//  NSArray+Reverse.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

-(NSArray*)reverseArray/*:(NSArray*)currentArray*/ {
    NSArray *currentArray = self;
    NSMutableArray *array = [NSMutableArray array];
    NSInteger current = [currentArray count] - 1;
    do {
        id element = [currentArray objectAtIndex:current];
        [array addObject:element];
        current--;
    } while (current > -1);
    
    return array;
}


#pragma mark - Compare Arrays
-(NSArray*) removeNamesWithArray:(NSArray*)newNames {
    NSArray *savedNames = self;
    NSMutableArray *notFoundArrayNames = [NSMutableArray array];
    
    for (NSString *savename in savedNames) {
        BOOL isFound = [self searchName:savename withArraySavedNames:newNames];
        if (!isFound) {
            [notFoundArrayNames addObject:savename];
        }
    }
    
    
    return notFoundArrayNames;
}


- (BOOL) searchName:(NSString*)name withArraySavedNames:(NSArray*)savedNames {
    BOOL isFound = NO;
    
    for (NSString *saveName in savedNames) {
        if ([name isEqualToString:saveName]) {
            isFound = YES;
        }
    }
    
    return isFound;
}

@end
