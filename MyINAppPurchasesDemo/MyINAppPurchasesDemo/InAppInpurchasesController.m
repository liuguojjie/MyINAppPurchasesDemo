//
//  InAppInpurchasesController.m
//  MyINAppPurchasesDemo
//
//  Created by LGJ on 2017/11/15.
//  Copyright © 2017年 LGJ. All rights reserved.
//

#import "StoreManager.h"
#import "StoreObserver.h"
#import "InAppInpurchasesController.h"
@interface InAppInpurchasesController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *itemArr;
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation InAppInpurchasesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProductRequestNotification:) name:IAPProductRequestNotification object:[StoreManager sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePurchasesNotification:) name:IAPPurchaseNotification object:[StoreObserver sharedInstance]];
    
    [self fetchProductInformation];
}

- (void)buildUI{
    
    self.myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.view addSubview:self.myTableView];
    
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPProductRequestNotification object:[StoreManager sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPPurchaseNotification object:[StoreObserver sharedInstance]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.itemArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    return cell;
    
}
//然后就是产品的展示了
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.itemArr.count > 0) {
        
        SKProduct *product = self.itemArr[indexPath.row];
        cell.textLabel.text = product.localizedTitle;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@元",product.price];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     SKProduct *product = self.itemArr[indexPath.row];
    
    [[StoreObserver sharedInstance] buy:product];
    
}
#pragma mark - Fetch product information
//从App Store检索产品信息
- (void)fetchProductInformation{
    
    if ([SKPaymentQueue canMakePayments]) {//
        
        // Load the product identifiers fron ProductIds.plist
        NSURL *plistURL = [[NSBundle mainBundle] URLForResource:@"ProductIds" withExtension:@"plist"];
        NSArray*productIds = [NSArray arrayWithContentsOfURL:plistURL];
        
        NSLog(@"productIds == %@",productIds);
        [[StoreManager sharedInstance] fetchProductInformationForIds:productIds];
        
    }else{
        
        //提示警告用户他们不允许进行购买。
        NSLog(@"无法进行购买");
    }
}

#pragma mark Handle product request notification (处理产品请求通知)
// Update the UI according to the product request notification result(根据产品请求通知结果更新UI)
- (void)handleProductRequestNotification:(NSNotification *)notification{
    
    StoreManager *productRequestNotificaton = (StoreManager *)notification.object;
    IAPProductRequestStatus result = (IAPProductRequestStatus)productRequestNotificaton.status;
    
    if (result == IAPProductRequestResponse) {
        
        self.itemArr = [StoreManager sharedInstance].availableProducts;
        
        NSLog(@"self.products == %@",self.itemArr);
        
        [self.myTableView reloadData];
    }
    
}
#pragma mark Handle purchase request notification (处理购买请求通知)
//// Update the UI according to the purchase request notification result(根据购买请求通知结果更新UI)
- (void)handlePurchasesNotification:(NSNotification *)notification{
    
    StoreObserver *purchasesNotification = (StoreObserver *)notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus)purchasesNotification.status;
    
    if (status == IAPPurchaseSucceeded){
        
        //处理相关UI
        
    }else if (status == IAPPurchaseFailed){
        
        //处理相关UI
    }
    
}

@end
