//
//  ViewController.m
//  003--MVP
//
//  Created by Cooci on 2018/3/31.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import "MVPViewController.h"
#import "MVVMViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.navigationController pushViewController:[MVVMViewController new] animated:YES];
    });


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
