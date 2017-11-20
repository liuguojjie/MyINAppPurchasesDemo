//
//  StoreManager.m
//  MyINAppPurchasesDemo
//
//  Created by LGJ on 2017/11/15.
//  Copyright © 2017年 LGJ. All rights reserved.
//

#import "StoreManager.h"
#import <StoreKit/StoreKit.h>

NSString * const IAPProductRequestNotification = @"IAPProductRequestNotification";

@interface StoreManager()<SKRequestDelegate, SKProductsRequestDelegate>

@end

@implementation StoreManager
+(StoreManager *)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    static StoreManager * storeManagerSharedInstance;
    dispatch_once(&onceToken, ^{
        
        storeManagerSharedInstance = [[StoreManager alloc] init];
    });
    
    return storeManagerSharedInstance;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self != nil) {
        
        _availableProducts = [[NSMutableArray alloc] initWithCapacity:0];
        _invalidProductIds = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

#pragma mark Request information
// Fetch information about your products from the App Store
- (void)fetchProductInformationForIds:(NSArray *)productIds{
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    request.delegate = self;
    [request start];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    if (response.products.count > 0) { //有效产品
        
        self.availableProducts = [NSMutableArray arrayWithArray:response.products];
    }
    if (response.invalidProductIdentifiers.count > 0) {//无效产品标示
        
        self.invalidProductIds = [NSMutableArray arrayWithArray:response.invalidProductIdentifiers];
    }
    self.status = IAPProductRequestResponse;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPProductRequestNotification object:self];
}

#pragma mark SKRequestDelegate method
//产品请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    self.status = IAPRequestFailed;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPProductRequestNotification object:self];
    NSLog(@"Product Request Status: %@",error.localizedDescription);
}

- (NSString *)titleMatchingProductIdentifier:(NSString *)identifier{
    
    NSString *productTitle = nil;
    
    for (SKProduct *product in self.availableProducts) {
        
        if ([product.productIdentifier isEqualToString:identifier]) {
            
            productTitle = product.localizedTitle;
        }
    }
    
    return productTitle;
}
@end
