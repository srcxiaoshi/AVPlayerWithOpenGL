//
//  NewPlayerView.m
//  test2
//
//  Created by baidu on 16/7/6.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>


@implementation PlayerView
#pragma mark 重写set get 方法
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


#pragma arguments
- (instancetype)initWithFillMode:(NSString *)fillMode
{
    if (self = [super init])
    {
        if (!self.player) {
            self.player=[[AVPlayer alloc]init];
        }
        //设置播放页面的大小
        self.layer.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 300);
        self.layer.backgroundColor = [UIColor cyanColor].CGColor;
        //设置播放窗口和当前视图之间的比例显示内容
        ((AVPlayerLayer*)self.layer).videoGravity = AVLayerVideoGravityResizeAspect;
        //设置播放的默认音量值
        self.player.volume = 1.0f;
    }
    return self;
}


@end
