//
//  AVPlayerViewController.m
//  AVPlayerWithOpenGL
//
//  Created by baidu on 16/8/4.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//

#import "AVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"

@interface AVPlayerViewController ()

@property(nonatomic,strong)PlayerView *playerView;
@property(nonatomic,strong)AVPlayerItem * playItem;
@property(nonatomic,strong)AVPlayerItemOutput *output;
@property(nonatomic,strong)AVPlayerLooper *looper;

//
//@property(nonatomic,assign)int count;
@end

@implementation AVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //AVPlayer IOS 10
    self.view.backgroundColor=[UIColor whiteColor];
    NSURL *url=[[NSURL alloc]initWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    //[AVPlayerItemVideoOutput initWithOutputSettings:]

    //AVPlayerLooper
    self.playerView=[[PlayerView alloc]initWithFillMode:@""];
    
    
    
    self.playItem=[[AVPlayerItem alloc]initWithURL:url];
    [self.playerView.player replaceCurrentItemWithPlayerItem:_playItem];
    
    [_playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    self.playerView.layer.frame=CGRectMake(0, 100, 180, 100);
    
    //测试rate  和 automaticallyWaitsToMinimizeStalling
    
    NSLog(@"status=%ld\n",(long)self.playerView.player.timeControlStatus);
    self.playerView.player.automaticallyWaitsToMinimizeStalling=YES;
    
    
    //[self.playerView.player playImmediatelyAtRate:1.0f];
    //[self.playerView.player play];
    
    [self.view addSubview:self.playerView];
    NSLog(@"2status=%ld\n",(long)self.playerView.player.timeControlStatus);
    ///测试AVPlayerloop
    // Create player and configure
    AVQueuePlayer *player = [[AVQueuePlayer alloc] init];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame=CGRectMake(0, 300, 180, 100);
    [self.view.layer addSublayer:playerLayer];
    [player pause];
    // Create looping item
    // Create looping helper object. Loop item segment from 5sec to 7sec
    self.looper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:self.playItem timeRange:CMTimeRangeMake(CMTimeMake(5000,1000), CMTimeMake(2000,1000))];
    
    // Perform any other set up operations like setting AVPlayerItemDataOutputs on the looping item replicas
    // Start playback
    [player play];
    // itemToLoop between 5s and 7s plays repeatedly
    // To end the looping
    //[looper disableLooping];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status=[[change objectForKey:@"new"] intValue];
        //NSLog(@"status=%ld\n",(long)status);
        if (status==AVPlayerStatusReadyToPlay) {
            NSLog(@"rate=%f",self.playerView.player.rate);
            NSLog(@"ready\n");
            self.playerView.player.rate=1.0f;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSLog(@"rate=%f",self.playerView.player.rate);
        NSLog(@"automaticallyWaitsToMinimizeStalling=%d\n",self.playerView.player.automaticallyWaitsToMinimizeStalling);
        NSLog(@"reasonForWaitingToPlay=%@",self.playerView.player.reasonForWaitingToPlay);
        NSLog(@"3status=%ld\n",(long)self.playerView.player.timeControlStatus);
        if (self.looper.loopCount) {
            NSLog(@"====item=%@\n",self.looper.loopingPlayerItems);
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

