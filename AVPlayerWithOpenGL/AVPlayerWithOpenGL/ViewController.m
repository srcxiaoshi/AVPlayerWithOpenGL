//
//  ViewController.m
//  AVPlayerWithOpenGL
//
//  Created by 史瑞昌 on 16/7/31.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//
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
    
    [self.OpenGLPlayerView setupGL];
    
    //设置displayLink
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [[self displayLink] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVPlayerItemStatusContext) {
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusReadyToPlay:
                self.OpenGLPlayerView.presentationRect = [[self.playerView.player currentItem] presentationSize];
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
    [self addObserver:self forKeyPath:@"playerView.player.currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    AVAsset *asset = [self.playItem asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                // 选择 video Track.
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                    
                    if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                        CGAffineTransform preferredTransform = [videoTrack preferredTransform];
                        
                        //旋转变化
                        self.OpenGLPlayerView.preferredRotation = -1 * atan2(preferredTransform.b, preferredTransform.a);
                        
                        [self addDidPlayToEndTimeNotificationForPlayerItem:self.playItem];
                        
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
        NSString *cancelButtonTitle = NSLocalizedString(@"好的", @"取消");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - CADisplayLink Callback
- (void)displayLinkCallback:(CADisplayLink *)sender
{
    /*
     The callback gets called once every Vsync.
     Using the display link's timestamp and duration we can compute the next time the screen will be refreshed, and copy the pixel buffer for that time
     This pixel buffer can then be processed and later rendered on screen.
     同步，获取视频 画帧， 稍后绘制到屏幕上，使用OpenGL ES
     */
    CMTime outputItemTime = kCMTimeInvalid;
    
    // Calculate the nextVsync time which is when the screen will be refreshed next.
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
    // Restart display link.
    [[self displayLink] setPaused:NO];
}

- (void)addDidPlayToEndTimeNotificationForPlayerItem:(AVPlayerItem *)item
{
    if (_notificationToken)
        _notificationToken = nil;
    
    /*
     Setting actionAtItemEnd to None prevents the movie from getting paused at item end. A very simplistic, and not gapless, looped playback.
     */
    self.playerView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // Simple item playback rewind.
        [[self.playerView.player currentItem] seekToTime:kCMTimeZero];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
