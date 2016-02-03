



#import "HistoryOrder.h"
#import "PersonOrderInfo.h"
#import "PrintData.h"


@implementation HistoryOrder

- (id) initWithOrderInfo:(NSDictionary *)orderInfo andOrderItems:(NSArray *)orderItems
{
    self = [super init];
    if (self) {
        _prints = [NSMutableArray array];
        [self parsePersonInfo:orderInfo andOrderItems:orderItems];
    }
    return self;
}



- (void) parsePersonInfo:(NSDictionary *)orderInfo andOrderItems:(NSArray *)orderItems
{
    // Personal
    _personInfo = [[PersonOrderInfo alloc] initWithOrderInfo:orderInfo];
    
    //
    for (NSDictionary *printDictionary in orderItems) {
        PrintData *print = [[PrintData alloc] initWithHistoryOrderItemsDictionary:printDictionary];
        [_prints addObject:print];
    }
}


- (NSUInteger) priceOrder
{
    NSUInteger symma = 0;
    for (PrintData *printData in _prints) {
        NSUInteger cost = [printData price];
        symma += cost;
    }
    return symma;
}

-(UIImage *)statusOrderImage
{
    return [_personInfo statusImage];
}



- (UIImage *) iconOrderImage
{
    if (_prints > 0)
    {
        UIImage *icon = [[_prints firstObject] iconShopCart];
        BOOL isCompareEqual = YES;
        
        for (PrintData *print in _prints) {
            UIImage *printIcon = [print iconShopCart];
            if (![printIcon isEqual:icon] && isCompareEqual) {
                isCompareEqual = NO;
            }
        }
        
        
        if (!isCompareEqual) {
            return [UIImage imageNamed:@"many_128"];
        }
    }
    
    return [[_prints firstObject] iconShopCart];
}
@end
