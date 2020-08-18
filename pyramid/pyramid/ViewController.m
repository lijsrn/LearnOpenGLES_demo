//
//  ViewController.m
//  pyramid
//
//  Created by JH on 2020/8/2.
//  Copyright © 2020 JH. All rights reserved.
//

#import "ViewController.h"
#import "LLView.h"

@interface ViewController ()

@property(nonatomic,strong) LLView *llView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.llView = (LLView *) self.view;
}


@end
