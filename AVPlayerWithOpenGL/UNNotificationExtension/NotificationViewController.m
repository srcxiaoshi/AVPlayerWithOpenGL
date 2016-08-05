//
//  NotificationViewController.m
//  UNNotificationExtension
//
//  Created by baidu on 16/8/3.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "UIImageView+WebCache.h"
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIImageView *imgView;

@property(nonatomic,strong)PlayerView *playerView;
@property(nonatomic,strong)AVPlayerItem * playItem;

@end

@implementation NotificationViewController
//viewDidLoad方法先运行
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    //
    self.view.backgroundColor=[UIColor blueColor];
    self.view.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 300);//个人推荐，高度可以和宽度成比例，但是会受到plist中UNNotificationExtensionInitialContentSizeRatio 的影响
    
    //测试label
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(0, 200, 320, 100)];
    [self.view addSubview:self.label];
    
    //测试图片
    self.imgView=[[UIImageView alloc]init];
    self.imgView.frame=CGRectMake(100, 200, 100, 100);
    [self.view addSubview:self.imgView];
    
    //self.imgView.image=[UIImage imageNamed:@"jpgtest.jpg"];//静图
    //动图
    //[self setImageWithUrlString:@"http://e.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=b95df6f978899e5178db32107797f505/35a85edf8db1cb13c5f31917de54564e92584b1f.jpg"];
    
    //测试视频播放  avplayer
    NSURL *url=[[NSURL alloc]initWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    self.playerView=[[PlayerView alloc]initWithFillMode:@""];
    self.playItem=[[AVPlayerItem alloc]initWithURL:url];
    [self.playerView.player replaceCurrentItemWithPlayerItem:_playItem];
    self.playerView.layer.frame=CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width-10 , ([[UIScreen mainScreen] bounds].size.width-10)/180.0*100);
    [self.view addSubview:self.playerView];
    [self.playerView.player play];

}
//后调用
- (void)didReceiveNotification:(UNNotification *)notification {
    
    if (notification.request.content.categoryIdentifier) {
        //[self setImageWithUrlString:@"http://e.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=b95df6f978899e5178db32107797f505/35a85edf8db1cb13c5f31917de54564e92584b1f.jpg"];
        self.label.text=[NSString stringWithFormat:@"%@",[notification.request.content.attachments objectAtIndex:0].identifier];
    }
}

//加图
- (void)setImageWithUrlString:(NSString *)urlString
{
    if (urlString && [urlString isKindOfClass:[NSString class]] && [urlString length] > 0) {
        [_imgView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"jpgtest.jpg"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    else
    {
        [_imgView setImage:[UIImage imageNamed:@"jpgtest.jpg"]];
    }
}




@end
