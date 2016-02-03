//
//  HistoryOrderTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/21/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PrintData.h"
#import "PrintImage.h"

#import "HistoryOrder.h"
#import "PersonOrderInfo.h"


/*NSString *const HISTORY_ORDER_IPHONE6 = @"{\"get_all_orders\":\"OK\",\"orders\":[{\"token\":\"NULL\",\"order_info\":{\"id\":\"161\",\"full_name\":\"\u041c\u0430\u0440\u0442\u044b\u043d\u043e\u0432 \u0414\u043c\u0438\u0442\u0440\u0438\u0439\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"8976532314\",\"description\":\"\",\"date\":\"2015-01-20 16:38:55\",\"status\":\"\u0417\u0430\u043a\u0430\u0437 \u043e\u0442\u043f\u0440\u0430\u0432\u043b\u0435\u043d\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"740\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"391\",\"item_id\":\"21\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"images\":[{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142161120004535.png\"}],\"item_info\":{\"name\":\"\u0427\u0435\u0445\u043e\u043b \u0434\u043b\u044f iPhone 6\",\"price\":\"740\",\"description\":\" \",\"category_name\":\"\u0427\u0435\u0445\u043b\u044b \u0438 \u043c\u0430\u0433\u043d\u0438\u0442\u044b\"},\"props\":[]}]}],\"time\":1421775747}";
*/

NSString *const HISTORY_ORDER_IPHONE6 = @"{\"get_all_orders\":\"OK\",\"orders\":[{\"token\":\"NULL\",\"order_info\":{\"id\":\"161\",\"full_name\":\"Мартынов Дмитрий\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"8976532314\",\"description\":\"\",\"date\":\"2015-01-20 16:38:55\",\"status\":\"Заказ отправлен\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"740\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"682\",\"item_id\":\"21\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"zip_link\":\"http://s01.photohouse.info/serv/uploads/zip/15/[307]Chehol dlya iPhone 6.zip\",\"images\":[{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360022754.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360037121.png\"}],\"item_info\":{\"name\":\"Чехол для iPhone 6\",\"price\":\"740\",\"description\":\" \",\"category_name\":\"Чехлы и магниты\"},\"props\":[]},{\"id\":\"683\",\"item_id\":\"13\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"zip_link\":\"http://s01.photohouse.info/serv/uploads/zip/15/[307]Alybom[rectangle].zip\",\"images\":[{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360078639.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360067397.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360089848.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360034681.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360096240.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360025054.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360082613.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360035737.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360067584.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360093426.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360052431.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360017325.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360044846.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360088535.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360075633.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360023875.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360035977.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360001460.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142299360057674.png\"}],\"item_info\":{\"name\":\"Альбом\",\"description\":\"\",\"category_name\":\"Альбомы\",\"price\":\"2390\"},\"props\":{\"type\":\"rectangle\",\"uturn\":\"7\",\"size\":\"14x21\",\"cover\":\"frosted\",\"style\":\"children\"}}]}],\"time\":1421849993}";
// PhotoPrint
/*@"{\"get_all_orders\":\"OK\",\"orders\":[{\"token\":\"NULL\",\"order_info\":{\"id\":\"161\",\"full_name\":\"Мартынов Дмитрий\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"8976532314\",\"description\":\"\",\"date\":\"2015-01-20 16:38:55\",\"status\":\"Заказ отправлен\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"740\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"697\",\"item_id\":\"11\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"zip_link\":\"http://s01.photohouse.info/serv/uploads/zip/15/[313]15h21.zip\",\"images\":[{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000059581.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000069159.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000049598.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000091090.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000067290.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000014875.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000088477.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000010512.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000062759.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000067872.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000005834.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000021158.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000054820.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000039183.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000000937.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000084995.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000057521.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000044640.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000059792.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000081492.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000041690.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000072770.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000027011.png\"},{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142308000064998.png\"}],\"item_info\":{\"name\":\"15х21\",\"price\":\"290\",\"description\":\"\",\"category_name\":\"Фотопечать\"},\"props\":[]}]},{\"token\":\"NULL\",\"order_info\":{\"id\":\"165\",\"full_name\":\"Дмитрий\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"+7 (897) 6532314\",\"description\":\"\",\"date\":\"2015-01-21 12:07:46\",\"status\":\"Заказ отправлен\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"690\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"397\",\"item_id\":\"6\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"images\":[{\"image\":\"http://151.248.113.74/serv/uploads/15/15142169760029187.png\"}],\"item_info\":{\"name\":\"Чехол для iPhone 5\",\"price\":\"690\",\"description\":\"\",\"category_name\":\"Чехлы и магниты\"},\"props\":[]}]},{\"token\":\"NULL\",\"order_info\":{\"id\":\"166\",\"full_name\":\"Мартынов Дмитрий\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"8976532314\",\"description\":\"\",\"date\":\"2015-01-21 13:16:25\",\"status\":\"Заказ отправлен\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"390\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"399\",\"item_id\":\"1\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"images\":[{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142169760066428.png\"}],\"item_info\":{\"name\":\"Кружка\",\"description\":\"\",\"category_name\":\"Сувениры и подарки\",\"price\":390},\"props\":{\"color\":\"pink\",\"type\":\"heart\"}}]}],\"time\":1421849993}";
 */

// Iphone 5, iPhone6, Mug
/*@"{\"get_all_orders\":\"OK\",\"orders\":[{\"token\":\"NULL\",\"order_info\":{\"id\":\"161\",\"full_name\":\"\u041c\u0430\u0440\u0442\u044b\u043d\u043e\u0432 \u0414\u043c\u0438\u0442\u0440\u0438\u0439\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"8976532314\",\"description\":\"\",\"date\":\"2015-01-20 16:38:55\",\"status\":\"\u0417\u0430\u043a\u0430\u0437 \u043e\u0442\u043f\u0440\u0430\u0432\u043b\u0435\u043d\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"740\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"391\",\"item_id\":\"21\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"images\":[{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142161120004535.png\"}],\"item_info\":{\"name\":\"\u0427\u0435\u0445\u043e\u043b \u0434\u043b\u044f iPhone 6\",\"price\":\"740\",\"description\":\" \",\"category_name\":\"\u0427\u0435\u0445\u043b\u044b \u0438 \u043c\u0430\u0433\u043d\u0438\u0442\u044b\"},\"props\":[]}]},{\"token\":\"NULL\",\"order_info\":{\"id\":\"165\",\"full_name\":\"\u0414\u043c\u0438\u0442\u0440\u0438\u0439\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"+7 (897) 6532314\",\"description\":\"\",\"date\":\"2015-01-21 12:07:46\",\"status\":\"\u0417\u0430\u043a\u0430\u0437 \u043e\u0442\u043f\u0440\u0430\u0432\u043b\u0435\u043d\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"690\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"397\",\"item_id\":\"6\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"images\":[{\"image\":\"http://151.248.113.74/serv/uploads/15/15142169760029187.png\"}],\"item_info\":{\"name\":\"\u0427\u0435\u0445\u043e\u043b \u0434\u043b\u044f iPhone 5\",\"price\":\"690\",\"description\":\"\",\"category_name\":\"\u0427\u0435\u0445\u043b\u044b \u0438 \u043c\u0430\u0433\u043d\u0438\u0442\u044b\"},\"props\":[]}]},{\"token\":\"NULL\",\"order_info\":{\"id\":\"166\",\"full_name\":\"\u041c\u0430\u0440\u0442\u044b\u043d\u043e\u0432 \u0414\u043c\u0438\u0442\u0440\u0438\u0439\",\"address\":\"S-peterburg, nevskiy\",\"phone\":\"8976532314\",\"description\":\"\",\"date\":\"2015-01-21 13:16:25\",\"status\":\"\u0417\u0430\u043a\u0430\u0437 \u043e\u0442\u043f\u0440\u0430\u0432\u043b\u0435\u043d\",\"user_id\":\"15\",\"studio_id\":\"0\",\"total_cost\":\"390\",\"status_id\":\"1\"},\"order_items\":[{\"id\":\"399\",\"item_id\":\"1\",\"item_num\":\"1\",\"image_proc\":\"1\",\"comment\":\"\",\"images\":[{\"image\":\"http://s01.photohouse.info/serv/uploads/15/15142169760066428.png\"}],\"item_info\":{\"name\":\"\u041a\u0440\u0443\u0436\u043a\u0430\",\"description\":\"\",\"category_name\":\"\u0421\u0443\u0432\u0435\u043d\u0438\u0440\u044b \u0438 \u043f\u043e\u0434\u0430\u0440\u043a\u0438\",\"price\":390},\"props\":{\"color\":\"pink\",\"type\":\"heart\"}}]}],\"time\":1421849993}";*/


@interface HistoryOrderTest : XCTestCase

@end

@implementation HistoryOrderTest
{
    PrintData *printData;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    printData = [[PrintData alloc] init];
}

- (void)tearDown
{
    printData = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseHistoryOrders
{
    NSData *data = [HISTORY_ORDER_IPHONE6 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    XCTAssertNil(localError, @"Error Parse");
    
    
    NSArray *arrayOrders = [parsedObject objectForKey:@"orders"];
    for (NSDictionary *order in arrayOrders) {
        NSArray *order_items = [order objectForKey:@"order_items"];
        NSDictionary *order_info = [order objectForKey:@"order_info"];
        
        HistoryOrder *historyOrder = [[HistoryOrder alloc] initWithOrderInfo:order_info andOrderItems:order_items];
        PersonOrderInfo *personInfo = historyOrder.personInfo;
        
        // Prints
        XCTAssertFalse(historyOrder.prints.count == 0, @"Prints == %lu", (unsigned long)historyOrder.prints.count);
        XCTAssertNotNil([historyOrder statusOrderImage], @"Status image nil");
        
        // PresonInfo
        XCTAssertNotNil(personInfo.status, @"Status nil");
        XCTAssertNotNil(personInfo.user_id, @"user_id nil");
        XCTAssertNotNil(personInfo.studio_id, @"studio_id nil");
        XCTAssertNotNil(personInfo.order_id, @"order_id nil");
        XCTAssertNotNil(personInfo.deliveryComment, @"deliveryComment nil");
        XCTAssertNotNil(personInfo.dateString, @"dateString nil");
        XCTAssertNotNil(personInfo.fullName, @"fullName nil");
        XCTAssertNotNil(personInfo.address, @"address nil");
        XCTAssertNotNil(personInfo.phone, @"phone nil");
        
        
        // Symma Order
        XCTAssertFalse([historyOrder priceOrder] == 0, @"History price empty: %li", (long)historyOrder.priceOrder);
        XCTAssertNotNil([historyOrder iconOrderImage], @"Icon image nil");
        
        
        for (PrintData *print in historyOrder.prints) {
            XCTAssertTrue(print.purchaseID > 0, @"PurchaseId == 0");
            XCTAssertFalse([print count] == 0, @"Count == %lu", (unsigned long)print.count);
            XCTAssertFalse([print price] == 0, @"Price == %li", (long)print.price);
            XCTAssertFalse([[print images] count] == 0, @"Images == %lu; PurchaseID: %li", (unsigned long)print.images.count, (long)print.purchaseID);
            XCTAssertNotNil([print iconShopCart], @"Icon image nil: ID: %li", (long)print.purchaseID);
            XCTAssertFalse([[print uploadURLs] count] == 0, @"Images URLs == %lu; PurchaseID: %li", (unsigned long)print.images.count, (long)print.purchaseID);

            
            // Images
            for (PrintImage *img in print.images) {
                XCTAssertFalse([[img.uploadURL absoluteString] length] == 0, @"URL == %@", img.uploadURL);
            }
            
            for (NSURL *url in [print uploadURLs]) {
                XCTAssertFalse([url absoluteString].length == 0, @"URL == %@", url);
            }
        }
    }
}

@end

