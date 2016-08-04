//
//  NotificationViewController.m
//  AVPlayerWithOpenGL
//
//  Created by baidu on 16/8/3.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//
#define NotificationTypePlainId @"notificationPlainId"
#define NotificationTypeServiceExtensionId @"notificationServiceExtensionId"
#define NotificationTypeContentExtensionId @"notificationContentExtensionId"

#define ActionIdentifier @"ActionIdentifier"

#import "UNNotificationViewController.h"
#import <UserNotifications/UserNotifications.h>


@interface UNNotificationViewController ()<UNUserNotificationCenterDelegate>

@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIImageView *imgView;


@end

@implementation UNNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title=@"通知";
    self.view.backgroundColor=[UIColor whiteColor];
    [self registerForNotification];
    
    //通知button
    UIButton *plainBtn=[[UIButton alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    [plainBtn setTitle:@"发送本地简单通知" forState:UIControlStateNormal];
    [plainBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [plainBtn addTarget:self action:@selector(sendPlainNoti:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:plainBtn];
    
    
    UIButton *serviceBtn=[[UIButton alloc]initWithFrame:CGRectMake(100, 200, 200, 100)];
    [serviceBtn setTitle:@"发送本地动图通知" forState:UIControlStateNormal];
    [serviceBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [serviceBtn addTarget:self action:@selector(sendServiceExtensionNoti:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serviceBtn];
    
    
    UIButton *contentExtensionBtn=[[UIButton alloc]initWithFrame:CGRectMake(100, 300, 200, 100)];
    [contentExtensionBtn setTitle:@"发送本地视频通知" forState:UIControlStateNormal];
    [contentExtensionBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [contentExtensionBtn addTarget:self action:@selector(sendContentExtensionNoti:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:contentExtensionBtn];
    
}

#pragma 三个按钮事件
- (void)sendPlainNoti:(id)sender
{
    _imgView.hidden = YES;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [NSString localizedUserNotificationStringForKey:@"我是Title" arguments:nil];
    content.subtitle=[NSString localizedUserNotificationStringForKey:@"我是subTitle" arguments:nil];;
    content.body = [NSString localizedUserNotificationStringForKey:@"我是body" arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    content.categoryIdentifier = NotificationTypePlainId;
    
    //添加music
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"]];
    UNNotificationAttachment *attach = [UNNotificationAttachment attachmentWithIdentifier:@"attachId" URL:url options:nil error:nil];
    if (attach)
    {
        content.attachments = @[attach];
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"requestId" content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2.0 repeats:NO]];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
}

- (void)sendServiceExtensionNoti:(id)sender {
    _imgView.hidden = YES;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [NSString localizedUserNotificationStringForKey:@"我是Title" arguments:nil];
    content.subtitle=[NSString localizedUserNotificationStringForKey:@"我是subTitle" arguments:nil];;
    content.body = [NSString localizedUserNotificationStringForKey:@"我是body" arguments:nil];
    //content.badge=[NSNumber numberWithInt:1];//0时会隐藏UNNotificationAttachment的图标，在上方的通知中
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = NotificationTypeServiceExtensionId;
    
    //添加了动图,在不添加UNNotificationContentExtension target 情况下，UNNotificationAttachment 会自动添加动图，无需额外加代码
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"giftest" ofType:@"gif"]];
    UNNotificationAttachment *attach = [UNNotificationAttachment attachmentWithIdentifier:@"attachId" URL:url options:nil error:nil];
    if (attach)
    {
        content.attachments = @[attach];
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"requestId" content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2.0 repeats:NO]];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
}

- (void)sendContentExtensionNoti:(id)sender
{
    _imgView.hidden = YES;
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [NSString localizedUserNotificationStringForKey:@"我是Title" arguments:nil];
    content.subtitle=[NSString localizedUserNotificationStringForKey:@"我是subTitle" arguments:nil];;
    content.body = [NSString localizedUserNotificationStringForKey:@"我是body" arguments:nil];
    
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = NotificationTypeContentExtensionId;
    
    //视频
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"no" ofType:@"mp4"]];
    
    UNNotificationAttachment *attach = [UNNotificationAttachment attachmentWithIdentifier:@"attachId" URL:url options:nil error:nil];
    if (attach)
    {
        content.attachments = @[attach];
    }
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"requestId" content:content trigger:[UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2.0 repeats:NO]];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@",error);
        }
    }];
}

#pragma mark 推送授权
//推送通知授权
- (void)registerForNotification
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound |UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted)
        {
            //添加3种action
            UNNotificationAction *actOne = [UNNotificationAction actionWithIdentifier:ActionIdentifier title:@"进入应用" options:UNNotificationActionOptionForeground];
            UNNotificationAction *actTwo = [UNNotificationAction actionWithIdentifier:ActionIdentifier title:@"关闭" options:UNNotificationActionOptionDestructive];
            UNNotificationAction *actThree = [UNNotificationAction actionWithIdentifier:ActionIdentifier title:@"啥也不做" options:UNNotificationActionOptionNone];
            
            UNNotificationCategory *plainCategory = [UNNotificationCategory categoryWithIdentifier:NotificationTypePlainId actions:@[actOne,actTwo] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
            
            UNNotificationCategory *serviceCategory =[UNNotificationCategory categoryWithIdentifier:NotificationTypeServiceExtensionId actions:@[actOne,actThree] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
            
            UNNotificationCategory *contentCategory = [UNNotificationCategory categoryWithIdentifier:NotificationTypeContentExtensionId actions:@[actOne,actTwo,actThree] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
            
            [center setNotificationCategories:[NSSet setWithObjects:plainCategory,serviceCategory,contentCategory, nil]];
        }
    }];
}

#pragma mark UNUserNotificationCenterDelegate
//将用户对通知响应结果告诉app，用户事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSString *actid = response.actionIdentifier;
    if (![actid isEqualToString:ActionIdentifier])
    {
        completionHandler();
    }
    else
    {
        NSLog(@"No Completion\n");
    }
    
}
//将通知传递给前台运行的app,在展示通知前执行
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    //这里需要下载网络图片到本地，然后 ？？？
    completionHandler(UNNotificationPresentationOptionBadge |UNNotificationPresentationOptionSound |UNNotificationPresentationOptionAlert);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
