//
//  StoreManager.h
//  MyINAppPurchasesDemo
//
//  Created by LGJ on 2017/11/15.
//  Copyright © 2017年 LGJ. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const IAPProductRequestNotification;

typedef NS_ENUM(NSInteger, IAPProductRequestStatus){
    
    IAPProductsFound,//(有效的产品)
    IAPIdentifiersNotFound,// (无效的商品标识符)
    IAPProductRequestResponse,//  (返回有效的和无效的商品标示符)
    IAPRequestFailed //（产品请求失败）
};

@interface StoreManager : NSObject

// (产品请求状态)
@property (nonatomic) IAPProductRequestStatus status;
// (跟踪所有有效的产品。 这些产品可在App Store上销售)
@property (nonatomic, strong) NSMutableArray *availableProducts;
// (跟踪所有无效的商品标识符)
@property (nonatomic, strong) NSMutableArray *invalidProductIds;

//(表示产品请求失败的原因)
@property (nonatomic, copy) NSString *errorMessage;

+ (StoreManager *)sharedInstance;

// (查询App Store有关给定的产品标识符)
- (void)fetchProductInformationForIds:(NSArray *)productIds;
// (返回与给定产品标识符相匹配的产品标题)
- (NSString *)titleMatchingProductIdentifier:(NSString *)identifier;
@end
