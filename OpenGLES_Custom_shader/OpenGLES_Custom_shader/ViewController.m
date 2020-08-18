//
//  ViewController.m
//  OpenGLES_Custom_shader
//
//  Created by JH on 2020/7/30.
//  Copyright © 2020 JH. All rights reserved.
//

#import "ViewController.h"
#import "LLView.h"

@interface ViewController ()

@property(nonatomic,strong) LLView *myView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myView =(LLView *) self.view ;
}


@end
