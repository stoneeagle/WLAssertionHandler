//
//  ViewController.m
//  WLAssertionHandlerTest
//
//  Created by wulei on 2019/1/11.
//  Copyright © 2019 wulei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(0, @"NSAssert test1 %@", @"haha");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSAssert(0, @"not main thread test");
    });
    
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        tap;
    })];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSAssert(0, @"viewDidAppear assert");
}

- (void)didTap {
    ViewController *vc2 = [ViewController new];
    vc2.view.backgroundColor = [UIColor redColor];
    [self presentViewController:vc2 animated:YES completion:nil];
}

@end
