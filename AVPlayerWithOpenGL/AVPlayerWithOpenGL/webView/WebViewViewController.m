//
//  WebViewViewController.m
//  AVPlayerWithOpenGL
//
//  Created by baidu on 16/8/11.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//

#import "WebViewViewController.h"
#import "NewWebView.h"


@interface WebViewViewController ()

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NewWebView *webView=[[NewWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+64)];
    webView.backgroundColor=[UIColor redColor];
    webView.scalesPageToFit=YES;
    
    [self.view addSubview:webView];
    
    self.view.backgroundColor=[UIColor blueColor];
    //
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
