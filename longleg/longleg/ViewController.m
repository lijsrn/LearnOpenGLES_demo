//
//  ViewController.m
//  longleg
//
//  Created by JH on 2020/8/15.
//  Copyright © 2020 JH. All rights reserved.
//

#import "ViewController.h"
#import "LongLegView.h"

@interface ViewController ()

@property(weak,nonatomic) IBOutlet LongLegView *springView;

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *topLineSpace;

@property(weak,nonatomic) IBOutlet NSLayoutConstraint *bottomLineSpace;

//top按钮
@property(weak,nonatomic) IBOutlet UIButton *topButton;

@property(weak,nonatomic) IBOutlet UIButton *bottomButton;

@property(nonatomic,weak) IBOutlet UIView *mask;

@property(weak,nonatomic) IBOutlet UISlider *slider;

@property(weak,nonatomic) IBOutlet UIView *topLine;

@property(weak,nonatomic) IBOutlet UIView *bottomLine;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}


@end
