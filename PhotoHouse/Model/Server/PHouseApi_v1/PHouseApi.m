//
//  PH_Api.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHouseApi.h"

#import "PHResponse.h"
#import "ResponseGetBanners.h"
#import "ResponseGetItems.h"
#import "ResponseAuth.h"
#import "ResponseGetDeliveries.h"
#import "ResponseGetPhoneList.h"
#import "ResponseGetAddressList.h"
#import "ResponseRegistration.h"
#import "ResponseFeedBack.h"
#import "ResponseMakeOrdes.h"
#import "ResponseGetAllOrders.h"
#import "ResponseCancelOrder.h"
#import "ResponsePayOrder.h"
#import "ResponseRestorePass.h"
#import "ResponseAlbumV2.h"
#import "ResponseGetCommands.h"
#import "ResponseUploadImage.h"
#import "ResponseGetUpdateTime.h"

#import "Json.h"
#import "JsonUploadImage.h"
#import "JsonOrder.h"
#import "JsonGetBanner.h"
#import "JsonGetItems.h"
#import "JsonGetCommands.h"
#import "JsonRestorePass.h"
#import "JsonCancelOrder.h"
#import "JsonFeedBack.h"
#import "JsonGetAddress.h"
#import "JsonGetPhone.h"
#import "JsonRegistration.h"
#import "JsonAuth.h"
#import "JsonPayOrder.h"
#import "JsonGetAllOrders.h"
#import "JsonGetDeliveries.h"
#import "JsonGetTemplates.h"
#import "JsonGetUpdateTime.h"

#import "PHRequestCommand.h"

#import "PHouseApiErrorCode.h"
#import "BundleDefault.h"

#import "Banner.h"

#import "CoreDataProfile.h"

#import "AppDelegate.h"

#import "NSString+MD5.h"

#import "MDPhotoLibrary.h"

#import "PrintImage.h"

@interface PHouseApi ()
{
    struct {
        unsigned int didBanner      : 1;
        unsigned int didGetItems    : 1;
        unsigned int didError       : 1;
        unsigned int didAuth        : 1;
        unsigned int didDeliveries  : 1;
        unsigned int didRegistration: 1;
        unsigned int didPhones      : 1;
        unsigned int didAddress     : 1;
        unsigned int didFeedBack    : 1;
        unsigned int didMakeOrder   : 1;
        unsigned int didAllOrders   : 1;
        unsigned int didCancelOrder : 1;
        unsigned int didPayURL      : 1;
        unsigned int didRestorePass : 1;
        unsigned int didAllTemplates: 1;
        unsigned int didUpdateTime  : 1;
    } _delegateFlag;
}
@end



@implementation PHouseApi

#pragma mark - GetBanner
- (void) getBannersWithDelegate:(id<PHouseApiDelegate>)delegate {
    //
    [self setDelegate:delegate];
    
    
    // Load Banner Block
    void (^LoadBannerBlock)(ResponseGetBanners *) = ^(ResponseGetBanners *response)
    {
        // Загружаем баннеры в группе
        dispatch_group_t group = dispatch_group_create();
        for (Banner *banner in [response banners]) {
            dispatch_queue_t queue = dispatch_queue_create("com.photohouse.banner.load.image", DISPATCH_QUEUE_SERIAL);
            dispatch_group_async(group, queue, ^{
                [banner loadImage];
            });
        }
        
        // После загрузки, отправляем на View
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            // Проверяем баннеры на загруженные картинки
            [response saveBanners];
            
            //
            if (_delegateFlag.didBanner)
            {
                [self.delegate pHouseApi:self didBannerReceiveData:response.banners];
            }
//            else if(_delegateFlag.didError)
//            {
//                [self.delegate pHouseApi:self didFailWithError:nil];
//            }
            
        });
    };
    
    
    // Request
    Json *jsonData = [[JsonGetBanner alloc] init];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        ResponseGetBanners *response = [[ResponseGetBanners alloc] initWitParseData:responseData];
        LoadBannerBlock(response);
        
    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        [self sendDelegateInternetNotFound:error];
    }];
}



#pragma mark - GetItems
-(void)getAllItemsWithDelegate:(id<PHouseApiDelegate>)delegate {
    //
    [self setDelegate:delegate];
    
    // Сохраняем данные Default в случае ошибки get_items
    void (^SavePriceDefaultBlock)(NSArray *) = ^(NSArray *templates) {
        // Read Default
        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
        ResponseGetItems *response = [[ResponseGetItems alloc] initWitParseData:data andTemplates:templates];
        NSLog(@"Save Default Items");
        if (_delegateFlag.didGetItems && !response.error) {
            [self.delegate pHouseApi:self didStoreItemsReceiveData:response];
        }
    };

    
    
    /*
     В данном запросе объеденены две команды, get_items(все  товары из магазина) + get_templates(шаблоны для конструктора альбомов)
     */
    
    // Сначала делвем запрос get_Templates
    // Потом его будем отпралять в Ответ к get_items
    [self getTemplatesWithBlock:^(NSArray *templates) {
        // После получения Шаблонов, нужно загрузить
        NSLog(@"Start Download GetItems");
        
//#warning ToDo: Read Bundle
//        SavePriceDefaultBlock(templates);
//        return;
        
        // Request
        Json *jsonData = [[JsonGetItems alloc] init];
        PHRequestCommand *command = [[PHRequestCommand alloc] init];
        [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
            PHResponse *response = [[ResponseGetItems alloc] initWitParseData:responseData andTemplates:templates];
            if (_delegateFlag.didGetItems && !response.error) {
                [self.delegate pHouseApi:self didStoreItemsReceiveData:response];
            } else {// if (response.error/* && SavePriceDefaultBlock*/) {
                SavePriceDefaultBlock(templates);
            }
        } progressUploadBlock:nil errorBlock:^(NSError *error) {
            //
            SavePriceDefaultBlock(templates);
        }];
    }];
}



-(void)saveDefaultTemplates
{
    NSArray* (^SaveTemplatesDefaultBlock)(void) = ^{
        // Read Default
        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2];
        NSLog(@"Save Default.GetTemplates");
        ResponseAlbumV2 *response = [[ResponseAlbumV2 alloc] initWitParseData:data];
        return response.oldTemplates;
    };

    void (^SaveGetItemsDefaultBlock)(NSArray *) = ^(NSArray *templates) {
        // Read Default
        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
        ResponseGetItems *response = [[ResponseGetItems alloc] initWitParseData:data andTemplates:templates];
        NSLog(@"Save Default GetItems");
        if (_delegateFlag.didGetItems && !response.error) {
            [self.delegate pHouseApi:self didStoreItemsReceiveData:response];
        }
    };
    
    // Получаем Templates
    NSArray *templates = SaveTemplatesDefaultBlock();
    
    // Сохраняем обе команды
    SaveGetItemsDefaultBlock(templates);
}




#pragma mark - GetDeliveries
-(void)getDeliveriesWithDelegate:(id<PHouseApiDelegate>)delegate orBlock:(void(^)(PHResponse *responce, NSError *error))completeBlock {
    //
    [self setDelegate:delegate];
    
    
    // DelegateBlock
    __weak PHouseApi *weakSelf = self;
    void (^DelegateDeliveryBlock)(PHResponse *) = ^(PHResponse *response) {
        if (_delegateFlag.didDeliveries) {
            [weakSelf.delegate pHouseApi:weakSelf didDeliveriesReceiveData:response];
        }
        if (completeBlock) {
            completeBlock(response, response.error);
        }
    };
    
    // Save Deafult Block
    void (^SaveDefaultBlock)(void) = ^{
        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeDelivery];
        PHResponse *response = [[ResponseGetDeliveries alloc] initWitParseData:data];
        DelegateDeliveryBlock(response);
    };
    
//#warning ToDo: Read Bundle
//    SaveDefaultBlock();
//    return;
    
    //
    Json *jsonData = [[JsonGetDeliveries alloc] init];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        // Read Response
        PHResponse *response = [[ResponseGetDeliveries alloc] initWitParseData:responseData];
        if (response.error) SaveDefaultBlock();
        else                DelegateDeliveryBlock(response);
    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        // Internet Fail
        SaveDefaultBlock();
    }];
}




//#pragma mark - Get Image Count
//-(void)getImageCountAndSave
//{
//    // Сохраняем данные Default в случае ошибки
//    void (^SaveDefaultBlock)(void) = ^{
//        // Read Default
//        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
//        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeRangeImages];
//        PHResponse *response = [[ResponseGetImagesCount alloc] initWitParseData:data];
//        [response description];
//    };
//    
//    SaveDefaultBlock();
//#warning ToDo: UnBlock, Resave JSON 31,31 - orange
    // Reguest
    /*PHRequest *request = [[RequestGetImagesCount alloc] initGetImagesCount];
    [request executeResultBlock:^(NSData *responseData)
    {
        PHResponse *response = [[ResponseGetImagesCount alloc] initWitParseData:responseData];
        if (response.error && SaveDefaultBlock) {
            SaveDefaultBlock();
        }
    }
                     errorBlock:^(NSError *error)
    {
        // Ошибка соедининия с интернетом, пробуем Default
        if (SaveDefaultBlock) {
            SaveDefaultBlock();
        }
    }];*/
//}





#pragma mark - Get History All Orders
-(void)getHistoryAllOrders:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    //
    Json *jsonData = [[JsonGetAllOrders alloc] init];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        // Complete
        ResponseGetAllOrders *response = [[ResponseGetAllOrders alloc] initWitParseData:responseData];
        if (_delegateFlag.didAllOrders) {
            [self.delegate pHouseApi:self didHistoryOrdersData:response.all_orders];
        }
    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        // Error
        [self sendDelegateInternetNotFound:error];
    }];
}



#pragma mark - Constructor Templates
-(void)getTemplatesWithBlock:(void(^)(NSArray *templates))complateBlock
{
    //
    void (^SaveTemplatesDefaultBlock)(void) = ^{
        // Read Default
        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2];
        NSLog(@"SaveDefault.GetTemplates");
        ResponseAlbumV2 *response = [[ResponseAlbumV2 alloc] initWitParseData:data];
        complateBlock(response.oldTemplates);
//        ResponseAlbum *response = [[ResponseAlbum alloc] initWitParseData:data andBlock:^(NSArray *templates) {
//            NSLog(@"All Templates Complete");
//            complateBlock(templates);
//        }];
//        [response description];
    };
    
//#warning ToDo: Uncommit Here
//    SaveTemplatesDefaultBlock();
//    return;
    
    // Request
//    PHRequest *phRequest = [[RequestAlbum alloc] init];
//    [phRequest executeResultBlock:^(NSData *responseData)
//     {
//         ResponseAlbum *response = [[ResponseAlbum alloc] initWitParseData:responseData];
//        if (response.error) {
//             SaveTemplatesDefaultBlock();
//        } else {
//            complateBlock(response.templates);
//        }
//     } errorBlock:^(NSError *error)
//     {
//         if (SaveTemplatesDefaultBlock) {
//             SaveTemplatesDefaultBlock();
//         }
//     }];
    
    //
    Json *jsonData = [[JsonGetTemplates alloc] init];
    PHRequestCommand *commnad = [[PHRequestCommand alloc] init];
    [commnad executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        /*ResponseAlbum *response;
        response = [[ResponseAlbum alloc] initWitParseData:responseData
                                                  andBlock:^(NSArray *templates) {
            NSLog(@"All Templates Complete");
            complateBlock(templates);
        }];*/
        ResponseAlbumV2 *response = [[ResponseAlbumV2 alloc] initWitParseData:responseData];
        if (response.error) {
            SaveTemplatesDefaultBlock();
        } else {
            complateBlock(response.oldTemplates);
        }

    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        NSLog(@"getTemplatesWithBlock.Error: %@", error);
        SaveTemplatesDefaultBlock();
    }];
}


//-(void)getAllAlbumTemplates:(id<PHouseApiDelegate>)delegate
//{
//    self.delegate = delegate;
//    
//    //
//    void (^SaveTemplatesDefaultBlock)(void) = ^{
//        // Read Default
//        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
//        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypeAlbum];
//        PHResponse *response = [[ResponseAlbum alloc] initWitParseData:data];
//        [response description];
//    };
//#warning Read from Bundle
//    SaveTemplatesDefaultBlock();
//    return;
//    
//    // Request
//    PHRequest *phRequest = [[RequestAlbum alloc] init];
//    [phRequest executeResultBlock:^(NSData *responseData)
//     {
//         ResponseAlbum *response = [[ResponseAlbum alloc] initWitParseData:responseData];
//         if (_delegateFlag.didGetItems) {
//             [self.delegate pHouseApi:self didAllConstructorTemplates:response.templates];
//         } else if (response.error && SaveTemplatesDefaultBlock) {
//             SaveTemplatesDefaultBlock();
//         }
//     } errorBlock:^(NSError *error)
//     {
//         if (SaveTemplatesDefaultBlock) {
//             SaveTemplatesDefaultBlock();
//         }
//     }];
//
//}



#pragma mark - Pay Order
- (void) payOrderID:(NSString *)order_id andDelegate:(id<PHouseApiDelegate>)delegate;
{
    //
    [self setDelegate:delegate];
    

    //
    Json *jsonData = [[JsonPayOrder alloc] initJsonOrderID:order_id];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        // Complete
        ResponsePayOrder *response = [[ResponsePayOrder alloc] initWitParseData:responseData];
        if (_delegateFlag.didPayURL) {
            [self.delegate pHouseApi:self didPayURL:response.payURL];
        }
    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        // Error
        [self sendDelegateInternetNotFound:error];
    }];
}



/*#pragma mark - Get Price
- (void) getPricePurchaseAndSave
{
    // Сохраняем данные Default в случае ошибки
    void (^SavePriceDefaultBlock)(void) = ^{
        // Read Default
        BundleDefault *bundleDefault = [[BundleDefault alloc] init];
        NSData *data = [bundleDefault defaultDataWithBundleName:BundleDefaultTypePrice];
        PHResponse *response = [[ResponseGetPrices alloc] initWitParseData:data];
        [response description];
    };
    
    
    
    // Reguest
    PHRequest *request = [[RequestGetPrices alloc] initGetPrices];
    [request executeResultBlock:^(NSData *responseData)
     {
         PHResponse *response = [[ResponseGetPrices alloc] initWitParseData:responseData];
         if (response.error && SavePriceDefaultBlock) {
             SavePriceDefaultBlock();
         }
     }
                     errorBlock:^(NSError *error)
     {
         // Ошибка соедининия с интернетом, пробуем Default
         if (SavePriceDefaultBlock) {
             SavePriceDefaultBlock();
         }
     }];
}*/




//#pragma mark - Props by id
//- (void) getPropByIDAndSave:(NSInteger)item_id
//                andDelegate:(id<PHouseApiDelegate>)delegate
//{
//    [self setDelegate:delegate];
//    
//    PHRequest *request = [[RequestGetProps alloc] initPropsWithItemID:item_id];
//    [request executeResultBlock:^(NSData *responseData) {
//        //
//    } errorBlock:^(NSError *error) {
//        //
//    }];
//}




#pragma mark - Auth
- (void) authLogin:(NSString *)login
       andPasswordHash:(NSString *)passwordHash
       andDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
//    NSString *salt = [NSString stringWithFormat:@"%@%@", SALT, password];
//    NSString *passwordHash = [salt MD5];
    
    // Request
    Json *jsonData = [[JsonAuth alloc] initAuthEMail:login andPasswordHash:passwordHash];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        //
        PHResponse *response = [[ResponseAuth alloc] initWitParseData:responseData andPasswordHash:passwordHash];
        if (response.error) {
            if (_delegateFlag.didError) {
                [self.delegate pHouseApi:self didFailWithError:response.error];
            }
        } else {
            if (_delegateFlag.didAuth) {
                [self.delegate pHouseApi:self didAuthReceiveData:response];
            }
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            [app setUserData:(ResponseAuth*)response];
        }

    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        //
        [self sendDelegateInternetNotFound:error];
    }];
}



- (void) authWithDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    // Читаем сохраненные данные из CoreData
    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
    ResponseAuth *response = [profile profile];
    NSString *login         = response.email;
    NSString *passwordHash   = response.passwordHash;
    
    if (!login || !passwordHash) {
        if (_delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:[NSError errorWithDomain:@"Нет сохраненных логина и пароля" code:ErrorCodeTypeNotLoginAndPassword userInfo:nil]];
            return;
        }
    }
    
    // Auth
    [self authLogin:login andPasswordHash:passwordHash andDelegate:delegate];
}



- (void)logout
{
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    [coreProfile logount];
}




#pragma mark - Registration
- (void) registationFirstName:(NSString *)firstname
                  andLastName:(NSString *)lastName
                     andEmail:(NSString *)email
                 withPassword:(NSString *)password
                  andDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    // Request
    Json *jsonData = [[JsonRegistration alloc] initJsonRegistationPhotoHouseFirstName:firstname andLastName:lastName andEmail:email withPassword:password];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        //
        PHResponse *response = [[ResponseRegistration alloc] initWitParseData:responseData];
        if (response.error)
        {
            if (_delegateFlag.didError) {
                [self.delegate pHouseApi:self didFailWithError:response.error];
            }
            
        }
        else
        {
            if (_delegateFlag.didRegistration) {
                [self.delegate pHouseApi:self didReqistrationReceiveData:response];
            }
            AppDelegate *app = [[UIApplication sharedApplication] delegate];
            [app setUserData:nil];
            
        }

    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        //
        [self sendDelegateInternetNotFound:error];
    }];
}



#pragma mark - PhoneList
- (void) getPhonesListAndSaveToProfileWithDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    // Request, execute
//    Json *jsonData = [[JsonGetPhone alloc] init];
//    PHRequestCommand *command = [[PHRequestCommand alloc] init];
//    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
//        ResponseGetAddressList *response = [[ResponseGetAddressList alloc] initWitParseData:responseData];
//        if (_delegateFlag.didAddress) {
//            [self.delegate pHouseApi:self didLastAddress:[response getAddress]];
//        }
//    } progressUploadBlock:nil errorBlock:nil];

}




#pragma mark - AddressList
- (void) getAddressListAndSaveToProfileWithDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    // Request, execute
//    Json *jsonData = [[JsonGetAddress alloc] init];
//    PHRequestCommand *command = [[PHRequestCommand alloc] init];
//    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
//        ResponseGetAddressList *response = [[ResponseGetAddressList alloc] initWitParseData:responseData];
//        if (_delegateFlag.didAddress) {
//            [self.delegate pHouseApi:self didLastAddress:[response getAddress]];
//        }
//    } progressUploadBlock:nil errorBlock:nil];
}





#pragma mark - Feed Back
- (void) feedbackType:(NSInteger)feedtype
             andTitle:(NSString *)title
           andMessage:(NSString *)message
             andEmail:(NSString *)email
          andDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    //
    Json *jsonData = [[JsonFeedBack alloc] initWithFeedBackType:feedtype andTitle:title andMessageText:message andEmail:email];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        //
        ResponseFeedBack *response = [[ResponseFeedBack alloc] initWitParseData:responseData];
        if (!response.error && _delegateFlag.didFeedBack) {
            [self.delegate pHouseApi:self didFeedBackData:response];
        } else if(_delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:response.error];
        }
    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        //
        if (_delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:error];
        }
    }];
}




#pragma mark - Cancel Order
- (void) cancelOrderID:(NSString *)order_id
             andUserID:(NSString *)user_id
           andDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    //
    Json *jsonData = [[JsonCancelOrder alloc] initJsonOrderID:order_id andUserID:user_id];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        //
        ResponseCancelOrder *response = [[ResponseCancelOrder alloc] initWitParseData:responseData];
        if (response.error && _delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:response.error];
        } else if (_delegateFlag.didCancelOrder) {
            [self.delegate pHouseApi:self didCanceledOrder:response];
        }

    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        // Internet Fail
        [self sendDelegateInternetNotFound:error];
    }];
}




#pragma mark - Upload Image
/*- (void) uploadImageFromRecord:(PhotoRecord*)record
                isUploadMerged:(BOOL)isUploadMerged
       andCompleteBlockSuccess:(void(^)(NSData *responseData))completeBlock
             andUpdateProgress:(void(^)(CGFloat progress))progressBlock
             andErrorBlockFail:(void(^)(NSError *error))errorBlock
{
    // Request
    PHRequest *phRequest = [[RequestUploadImage alloc] initUploadImageWithRecord:record isUploadMerged:isUploadMerged];
    [phRequest executeResultBlock:^(NSData *responseData)
    {
        // Complete
        if (completeBlock) {
            completeBlock(responseData);
        }
    }
              progressUploadBlock:^(CGFloat progress)
    {
        // Progress
        if (progressBlock) {
            progressBlock(progress);
        }
    }
                       errorBlock:^(NSError *error)
    {
        // Error
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}*/




- (void) uploadImageFromPrintImage:(PrintImage *)printImage
           andCompleteBlockSuccess:(void(^)(NSString *responseURL))completeBlock
                 andUpdateProgress:(void(^)(CGFloat progress))progressBlock
                 andErrorBlockFail:(void(^)(NSError *error))errorBlock
{
    /// Блок отправки запроса на сервер, imageLargeData может быть nil
    void (^UploadrequestBlock)(NSData *imageLargeData) = ^(NSData *imageLargeData) {
//        UIImage *image = [UIImage imageWithData:imageLargeData];
        
        /// Data
        Json *jsonData = [[JsonUploadImage alloc] initWithPrintImage:printImage andImageData:imageLargeData];
//        [jsonData updateImageData:(imageLargeData == nil || imageLargeData.length == 0) ? jsonData.imageData : imageLargeData];
        
        /// Request
        PHRequestCommand *command = [[PHRequestCommand alloc] init];
        [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
            // Complete
            ResponseUploadImage *uploadResponse = [[ResponseUploadImage alloc] initWitParseData:responseData];
            if (uploadResponse.error) {
                errorBlock(uploadResponse.error);
            } else {
                completeBlock(uploadResponse.urlImage);
            }
        } progressUploadBlock:^(CGFloat progress) {
            // Progress
            if (progressBlock) {
                progressBlock(progress);
            }
        } errorBlock:^(NSError *error) {
            // Error
            if (errorBlock) {
                errorBlock(error);
            }
        }];
    };
    
    
    // Начинается отсюда
    /// Библиотека для загрузки
    MDPhotoLibrary *library = [[MDPhotoLibrary alloc] init];
    [library getAssetWithURL:printImage.urlLibrary withResultBlock:^(NSData *imageData, UIImageOrientation orientation) {
        UploadrequestBlock(imageData);
        
    } failBlock:^(NSError *error) {
        UploadrequestBlock(nil);
    }];
}




#pragma mark - Make Order
- (void) makeOrderFirstName:(NSString*)firstName
                andLastName:(NSString*)lastName
                   andPhone:(NSString*)phone
                 andAddress:(NSString*)address
                withComment:(NSString*)text
       andPhotoRecordsArray:(NSArray*)cartArray
        andDeliveryPrintDta:(PrintData*)deliveryPrintData
                andDelegate:(id<PHouseApiDelegate>)delegate
{
    //
    [self setDelegate:delegate];
    
    //
    Json *jsonData = [[JsonOrder alloc] initWithFirstName:firstName
                                              andLastName:lastName
                                                 andPhone:phone
                                               andAddress:address
                                              withComment:text
                                     andPhotoRecordsArray:cartArray
                                      andDeliveryPrintDta:deliveryPrintData];
    PHRequestCommand *requestCommand = [[PHRequestCommand alloc] init];
    [requestCommand executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        ResponseMakeOrdes *response = [[ResponseMakeOrdes alloc] initWitParseData:responseData];
        if (!response.error && _delegateFlag.didMakeOrder) {
            [self.delegate pHouseApi:self didMakeOrderCompleteData:response];
        } else if(_delegateFlag.didError)  {
            [self.delegate pHouseApi:self didFailWithError:response.error];
        }

    } progressUploadBlock:nil
      errorBlock:^(NSError *error) {
        // Error
        if (_delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:error];
        };
    }];
}





#pragma mark - Restore Pass
-(void)restorePassWithEmail:(NSString *)email andDelegate:(id<PHouseApiDelegate>)delegate
{
    // Delegate
    [self setDelegate:delegate];
    
    // ErrorBlock
    void (^ErrorBlock)(NSError *) = ^(NSError *error) {
        if (_delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:error];
        }
    };
    
    
    // Request
    Json *jsonData = [[JsonRestorePass alloc] initJsonEmail:email];
    PHRequestCommand *command = [[PHRequestCommand alloc] init];
    [command executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        PHResponse *response = [[ResponseRestorePass alloc] initWitParseData:responseData];
        if (!response.error && _delegateFlag.didRestorePass) {
            [self.delegate pHouseApi:self didRestorePassData:response];
        } else {
            ErrorBlock(response.error);
        }

    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        //
        [self sendDelegateInternetNotFound:error];
    }];
}




#pragma mark - GetApiCommands
-(void)getApiCommands
{
    //
    Json *jsonData = [[JsonGetCommands alloc] init];
    PHRequestCommand *commnad = [[PHRequestCommand alloc] init];
    [commnad executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        PHResponse *response = [[ResponseGetCommands alloc] initWitParseData:responseData];
        if (!response.error && _delegateFlag.didRestorePass) {
            [self.delegate pHouseApi:self didRestorePassData:response];
        }
    } progressUploadBlock:nil errorBlock:^(NSError *error) {
         NSLog(@"Error: %@", error);
    }];
}



#pragma mark - GetUpdateTime
-(void)getUpdateTimeWithDelegate:(id<PHouseApiDelegate>)delegate
{
    [self setDelegate:delegate];
    
    Json *jsonData = [[JsonGetUpdateTime alloc] init];
    PHRequestCommand *commnad = [[PHRequestCommand alloc] init];
    [commnad executeCommnadWithJson:jsonData andCompleteBlock:^(NSData *responseData) {
        PHResponse *response = [[ResponseGetUpdateTime alloc] initWitParseData:responseData];
        if (!response.error && _delegateFlag.didUpdateTime) {
            [self.delegate pHouseApi:self didUpdateTime:response];
        } else if (_delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:response.error];
        }
    } progressUploadBlock:nil errorBlock:^(NSError *error) {
        if (_delegateFlag.didError) {
            [self.delegate pHouseApi:self didFailWithError:error];
        }
    }];
}



#pragma mark - SALT
-(NSString *)salt
{
    return SALT;
}




#pragma mark - Delegate
- (void)setDelegate:(id<PHouseApiDelegate>)delegate {
    _delegate = delegate;
    
    if ([delegate respondsToSelector:@selector(pHouseApi:didBannerReceiveData:)])       _delegateFlag.didBanner     = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didReqistrationReceiveData:)]) _delegateFlag.didRegistration = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didFailWithError:)])           _delegateFlag.didError      = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didStoreItemsReceiveData:)])   _delegateFlag.didGetItems   = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didAuthReceiveData:)])         _delegateFlag.didAuth       = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didDeliveriesReceiveData:)])   _delegateFlag.didDeliveries = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didLastPhone:)])               _delegateFlag.didPhones     = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didLastAddress:)])             _delegateFlag.didAddress    = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didFeedBackData:)])            _delegateFlag.didFeedBack   = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didMakeOrderCompleteData:)])   _delegateFlag.didMakeOrder  = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didHistoryOrdersData:)])       _delegateFlag.didAllOrders  = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didCanceledOrder:)])           _delegateFlag.didCancelOrder= YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didPayURL:)])                  _delegateFlag.didPayURL     = YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didRestorePassData:)])         _delegateFlag.didRestorePass= YES;
    if ([delegate respondsToSelector:@selector(pHouseApi:didUpdateTime:)])              _delegateFlag.didUpdateTime = YES;
}




#pragma mark - Methods
- (void) sendDelegateInternetNotFound:(NSError *)error
{
//    NSError *err = [NSError errorWithDomain:@"Соединение с интернет недоступно" code:ErrorCodeTypeNotConnectToInternet userInfo:nil];
    if (_delegateFlag.didError) {
        [self.delegate pHouseApi:self didFailWithError:error];
    }
}
@end
