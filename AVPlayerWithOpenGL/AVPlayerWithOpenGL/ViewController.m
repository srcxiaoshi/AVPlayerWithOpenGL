//
//  ViewController.m
//  AVPlayerWithOpenGL
//
//  Created by 史瑞昌 on 16/7/31.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//  该VC继承的是UIViewController
# define ONE_FRAME_DURATION 0.04
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
#import "APLEAGLView.h"

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface ViewController ()<AVPlayerItemOutputPullDelegate>
{
    
    
}

@property(nonatomic,strong)PlayerView *playerView;
@property(nonatomic,strong)APLEAGLView *OpenGLPlayerView;
@property(nonatomic,strong)AVPlayerItem * playItem;
@property(nonatomic,strong)AVPlayerItemVideoOutput *videoOutput;
@property(nonatomic,strong)dispatch_queue_t myVideoOutputQueue;
@property(nonatomic,strong)CADisplayLink* displayLink;
@property(nonatomic,strong) id notificationToken;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //创建avplayer，展示层
    self.playerView=[[PlayerView alloc]initWithFillMode:@""];
    self.OpenGLPlayerView=[[APLEAGLView alloc]initWithFrame:CGRectMake(100, 100, 180, 100)];
    
    self.OpenGLPlayerView.lumaThreshold = 1.0f;
    self.OpenGLPlayerView.chromaThreshold = 1.0f;
    //self.OpenGLPlayerView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    //self.OpenGLPlayerView.enableSetNeedsDisplay = NO;
    [self.OpenGLPlayerView setupGL];
    //self.preferredFramesPerSecond = 0.0f;//帧率,设置成0，系统不再自行渲染，而是走displaylink
    
    //设置displayLink
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [[self displayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [[self displayLink] setPaused:YES];
    
    //设置videoOutPut
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};//这里注意kCVPixelFormatType_32RGBA格式，不是所有的都能显示在UIImageView中的
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [[self videoOutput] setDelegate:self queue:_myVideoOutputQueue];
    
    
    //视频播放
    NSURL *url=[[NSURL alloc]initWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    [self setupPlaybackForURL:url];
    [self.view addSubview:self.OpenGLPlayerView];


}
//作为一个触发监控口，即视频准备好，设置frame，所以只执行一次
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVPlayerItemStatusContext) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                self.OpenGLPlayerView.presentationRect = [[self.playerView.player currentItem] presentationSize];//这里不影响内存
                break;
            case AVPlayerItemStatusFailed:
                [self stopLoadingAnimationAndHandleError:[[self.playerView.player currentItem] error]];
                break;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Playback setup
- (void)setupPlaybackForURL:(NSURL *)URL
{
    /*
     设置item添加output.
     After adding the video output, we request a notification of media change in order to restart the CADisplayLink.
     */
    
    // 清空Item
    [[self.playerView.player currentItem] removeOutput:self.videoOutput];
    
    //数据源
    self.playItem= [AVPlayerItem playerItemWithURL:URL];
    [self.playerView.player addObserver:self forKeyPath:@"currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    AVAsset *asset = [self.playItem asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                // 选择 video Track.就 1 个Track
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                    
                    if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                        CGAffineTransform preferredTransform = [videoTrack preferredTransform];
                        
                        //旋转变化
                        self.OpenGLPlayerView.preferredRotation = -1 * atan2(preferredTransform.b, preferredTransform.a);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.playItem addOutput:self.videoOutput];
                            [self.playerView.player replaceCurrentItemWithPlayerItem:self.playItem];
                            [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                            [self.playerView.player play];
                        });
                        
                    }
                    
                }];
            }
        }
        
    }];
    
}

//健壮性函数
- (void)stopLoadingAnimationAndHandleError:(NSError *)error
{
    if (error) {
        NSLog(@"error\n");
    }
}

#pragma mark - CADisplayLink Callback
- (void)displayLinkCallback:(CADisplayLink *)sender
{
    /*
      同步，获取视频 画帧， 稍后绘制到屏幕上，使用OpenGL ES
     */
    CMTime outputItemTime = kCMTimeInvalid;
    
    // 计算下一次刷新时间戳
    CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
    
    outputItemTime = [[self videoOutput] itemTimeForHostTime:nextVSync];
    
    if ([[self videoOutput] hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        
        [[self OpenGLPlayerView] displayPixelBuffer:pixelBuffer];
        
        if (pixelBuffer != NULL) {
            CFRelease(pixelBuffer);
        }
    }
}

#pragma mark - AVPlayerItemOutputPullDelegate
- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    // 重新开始 display link.
    [[self displayLink] setPaused:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
