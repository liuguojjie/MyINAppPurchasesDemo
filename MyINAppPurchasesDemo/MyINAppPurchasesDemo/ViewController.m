//
//  ViewController.m
//  MyINAppPurchasesDemo
//
//  Created by LGJ on 2017/11/15.
//  Copyright © 2017年 LGJ. All rights reserved.
//

#import "ViewController.h"
#import "InAppInpurchasesController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)goInAppInpurchases:(id)sender {
    
    InAppInpurchasesController *vc = [[InAppInpurchasesController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
