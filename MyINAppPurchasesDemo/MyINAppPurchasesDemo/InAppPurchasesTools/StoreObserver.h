//
//  StoreObserver.h
//  MyINAppPurchasesDemo
//
//  Created by LGJ on 2017/11/15.
//  Copyright © 2017年 LGJ. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

extern NSString * const IAPPurchaseNotification;

typedef NS_ENUM(NSInteger, IAPPurchaseNotificationStatus){
    
    IAPPurchaseFailed, // Indicates that the purchase was unsuccessful(表示购买未成功)
    IAPPurchaseSucceeded, // Indicates that the purchase was successful(表示购买成功)
    IAPRestoredFailed, // Indicates that restoring products was unsuccessful (表示恢复产品不成功)
    IAPRestoredSucceeded, // Indicates that restoring products was successful (表示恢复产品成功)
    IAPDownloadStarted, // Indicates that downloading a hosted content has started (表示下载托管内容已经开始)
    IAPDownloadInProgress, // Indicates that a hosted content is currently being downloaded (表示当前正在下载托管内容)
    IAPDownloadFailed,  // Indicates that downloading a hosted content failed (表示下载托管内容失败)
    IAPDownloadSucceeded // Indicates that a hosted content was successfully downloaded (表示托管内容已成功下载)
};

@interface StoreObserver : NSObject <SKPaymentTransactionObserver>

@property (nonatomic) IAPPurchaseNotificationStatus status;

+ (StoreObserver *)sharedInstance;
- (void)buy:(SKProduct *)product;
@end
