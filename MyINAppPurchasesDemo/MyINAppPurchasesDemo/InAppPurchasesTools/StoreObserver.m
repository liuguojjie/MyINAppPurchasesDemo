//
//  StoreObserver.m
//  MyINAppPurchasesDemo
//
//  Created by LGJ on 2017/11/15.
//  Copyright © 2017年 LGJ. All rights reserved.
//

#import "StoreObserver.h"

NSString * const IAPPurchaseNotification = @"IAPPurchaseNotification";


@implementation StoreObserver

+ (StoreObserver *)sharedInstance{
    
    static dispatch_once_t onceToken;
    
    static StoreObserver * storeObserverSharedInstance;
    
    dispatch_once(&onceToken, ^{
        
        storeObserverSharedInstance = [[StoreObserver alloc] init];
    });
    
    return storeObserverSharedInstance;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self != nil) {
        
    }
    
    return self;
}
#pragma mark - make a purchase
- (void)buy:(SKProduct *)product{
      SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    // 记录购买者ID 产品名称 产品价格  反面后面取到传给服务器
    NSString *productName = product.localizedTitle;
    NSString *productPrice = [product.price stringValue];
    NSString *userID = @"user";
    NSArray *arr = @[userID,productName,productPrice];
    NSString *applicationUsername = [arr componentsJoinedByString:@","];
    payment.applicationUsername =applicationUsername;
    payment.quantity = 1;
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods （在付款队列中有交易时调用）
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    for (SKPaymentTransaction * transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: //交易正在被添加到付款队列
                
                NSLog(@"交易正在被添加到付款队列");
                break;
            case SKPaymentTransactionStateDeferred: //最终状态未确定
                
                [self completeTransaction:transaction forStatus:IAPPurchaseFailed];
                NSLog(@"最终状态未确定");
                break;
                
            case SKPaymentTransactionStatePurchased: //购买成功
                
                NSLog(@"购买成功");
                
                [self completeTransaction:transaction forStatus:IAPPurchaseSucceeded];
                break;
                
            case SKPaymentTransactionStateRestored: //已经购买过该商品
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];//消耗型不支持恢复
                NSLog(@"已经购买过该商品");
                break;
                
            case SKPaymentTransactionStateFailed: //交易失败
                NSLog(@"交易失败");
                [self completeTransaction:transaction forStatus:IAPPurchaseFailed];
                break;
                
            default:
                break;
        }
    }
}

//检查交易状态，做出相应操作
- (void)completeTransaction:(SKPaymentTransaction *)transaction forStatus:(NSInteger)status{
    
    self.status = status;
    NSString *detail = nil;
    if (transaction.error != nil) {
        
        switch (transaction.error.code) {
                
            case SKErrorUnknown:
                
                NSLog(@"SKErrorUnknown");
                detail = @"未知的错误，请稍后重试。";
                break;
                
            case SKErrorClientInvalid:
                
                NSLog(@"SKErrorClientInvalid");
                detail = @"当前苹果账户无法购买商品(如有疑问，可以询问苹果客服)";
                break;
                
            case SKErrorPaymentCancelled:
                
                NSLog(@"SKErrorPaymentCancelled");
                detail = @"订单已取消";
                break;
            case SKErrorPaymentInvalid:
                NSLog(@"SKErrorPaymentInvalid");
                detail = @"订单无效(如有疑问，可以询问苹果客服)";
                break;
                
            case SKErrorPaymentNotAllowed:
                NSLog(@"SKErrorPaymentNotAllowed");
                detail = @"当前苹果设备无法购买商品(如有疑问，可以询问苹果客服)";
                break;
                
            case SKErrorStoreProductNotAvailable:
                NSLog(@"SKErrorStoreProductNotAvailable");
                detail = @"当前商品不可用";
                break;
                
            default:
                
                NSLog(@"No Match Found for error");
                detail = @"未知错误";
                break;
        }
        
         NSLog(@"detail == %@",transaction.error.localizedDescription);
    }
    
    if (status == IAPPurchaseSucceeded) {
        
        //获得交易 凭证
        NSURL *receipturl = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receipturl];
       
        NSLog(@"receiptData == %@",receiptData);
        //获取购买者标识
        NSLog(@"payment.applicationUsername == %@",transaction.payment.applicationUsername);
        NSArray *arr = [transaction.payment.applicationUsername componentsSeparatedByString:@","];
        NSLog(@"arr == %@",arr);
       // NSString *receiptStr = [GTMBase64 stringByEncodingData:receiptData];
      //  NSLog(@"receiptStr == %@",receiptStr);
        
       //将 1、交易凭证 2、购买者标识 3、购买的产品类型 保存到本地
       // [LGJKeyChainTools setObject:receiptStr forService:@"user" account:transaction.payment.applicationUsername ];
       
       //向本地服务器发送请求 传送 1、交易凭证 2、购买者标识 3、购买的产品类型，本地服务器向苹果服务器发送验证验证交易凭证请求。如果凭证有效，则发放产品，如果无效则提示相应的错误提示
        
       
        //删除保存到本地的相应信息
        
        
        [self checkRecipt];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPPurchaseNotification object:self];
    
    
    
}

//本地验证,向AppStore验证收据
- (void)checkRecipt{
    
    NSURL *receipturl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receipturl];
     NSString *receiptStr = [receiptData base64EncodedStringWithOptions:0];
    ////向App Store验证收据
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data":receiptStr};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];
    NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   /* ... Handle error ... */
                                   NSLog(@"connectionError == %@",connectionError);
                                   
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) {NSLog(@"jsonResponseerror == %@",error); }
                                   /* ... Send a response back to the device ... */
                                   NSLog(@"jsonResponse == %@",jsonResponse);
                               }
                           }];
    
}
@end
