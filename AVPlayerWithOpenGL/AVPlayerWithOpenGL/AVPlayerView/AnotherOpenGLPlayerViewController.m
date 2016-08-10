//
//  AnotherOpenGLPlayerViewController.m
//  AVPlayerWithOpenGL
//  该文件，使用glDrawElements 绘制
//  glDrawArrays传输或指定的数据是最终的真实数据,在绘制时效能更好
//  而glDrawElements指定的是真实数据的调用索引,在内存/显存占用上更节省
//  Created by baidu on 16/8/2.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//
# define ONE_FRAME_DURATION 0.04
#import "AnotherOpenGLPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface AnotherOpenGLPlayerViewController ()<AVPlayerItemOutputPullDelegate>
{
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
}

@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) GLKBaseEffect* mEffect;
@property(nonatomic,strong)GLKTextureInfo* textureInfo;//声明，但是在获取数据时初始化
@property (nonatomic , assign) int mCount;


//AVFoundation
@property(nonatomic,strong)AVPlayerItem * playItem;
@property(nonatomic,strong)AVPlayerItemVideoOutput *videoOutput;
@property(nonatomic,strong)dispatch_queue_t myVideoOutputQueue;
@property(nonatomic,strong)AVPlayer *avPlayer;
@property(nonatomic,strong)UIImage *img;

@property(nonatomic,assign) GLuint buffer;
@property(nonatomic,assign) GLuint index;

@end

@implementation AnotherOpenGLPlayerViewController
{
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    
    
    
    
    //初始化AVFoundation的对象
    self.avPlayer =[[AVPlayer alloc]init];
    //设置videoOutPut
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};//这里注意kCVPixelFormatType_32RGBA格式，不是所有的都能显示在UIImageView中的
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [[self videoOutput] setDelegate:self queue:_myVideoOutputQueue];
    
    //视频播放
    NSURL *url=[[NSURL alloc]initWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
    [self setupPlaybackForURL:url];
    
    
    
    [self setUpGL];
    
    
    

    
    
}

//初始化GL
-(void)setUpGL
{
    //新建OpenGLES 上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; //2.0，还有1.0和3.0
    //
    if (!self.mContext) {
        NSLog(@"创建Context失败\n");
    }
    
    GLKView* view = (GLKView *)self.view; //转化view
    view.delegate=self;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;  //颜色缓冲区格式
    
    //设置Context
    [EAGLContext setCurrentContext:self.mContext];
    
    //VC的刷新频率
    self.preferredFramesPerSecond = 60; // 设置刷新的频率，每秒多少次，默认是30次
    
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标,因为图是倒着的，调整了对角的坐标；
    //该矩阵就是贴的图和真实坐标的映射，所以这个才是360真正的需要修改的地方，纹理坐标是0，1之间的比例，左下角是(0,0)，右上角啊是(1,1)
    GLfloat squareVertexData[] =
    {
        1.0,-0.25, 0.0f,    1.0f, 1.0f, //右下
        -1.0, 0.25, 0.0f,   0.0f, 0.0f, //左上
        -1.0, -0.25, 0.0f,   0.0f, 1.0f, //左下
        1.0, 0.25, -0.0f,    1.0f, 0.0f, //右上
    };
    
    //顶点索引
    GLuint indices[] =
    {
        0,2,3,
        1,2,3
    };
    self.mCount = sizeof(indices) / sizeof(GLuint);
    
    
    //顶点数据缓存
    
    glGenBuffers(1, &_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    
    glGenBuffers(1, &_index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    // Create CVOpenGLESTextureCacheRef for optimal CVPixelBufferRef to GLES texture conversion.
    //初始化纹理缓存
    if (!_videoTextureCache) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.mContext, NULL, &_videoTextureCache);
        if (err != noErr) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
            return;
        }
    }
    
    //初始化着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
}

//销毁GL
-(void)tearDownGL
{
    if ([EAGLContext currentContext] == self.mContext) {
        [EAGLContext setCurrentContext:nil];
    }
    self.mContext = nil;
    
    glDeleteBuffers(1, &_buffer);
    glDeleteBuffers(1, &_index);
    
    self.mEffect=nil;
}

//销毁Texture
- (void)cleanUpTextures
{
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

/**
 *  场景数据变化,先调用update方法，后调用drawInRect方法
 */
- (void)update {

    
}

/**
 *  渲染场景代码，该方法在update后调用
 */
#pragma GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if ([[self videoOutput] hasNewPixelBufferForItemTime:self.playItem.currentTime])
    {
        CVPixelBufferRef pixelBuffer = NULL;
        pixelBuffer = [[self videoOutput] copyPixelBufferForItemTime:self.playItem.currentTime itemTimeForDisplay:NULL];
        if (pixelBuffer != NULL) {
            float frameWidth = (float)CVPixelBufferGetWidth(pixelBuffer);
            float frameHeight = (float)CVPixelBufferGetHeight(pixelBuffer);
                
            if (!_videoTextureCache) {
                NSLog(@"No video texture cache");
                return;
            }
                
            [self cleanUpTextures];
                /*
                 CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture optimally from CVPixelBufferRef.
                 */
                
                /*
                 Create Y and UV textures from the pixel buffer. These textures will be drawn on the frame buffer Y-plane.
                 */
            glActiveTexture(GL_TEXTURE0);
            CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                            _videoTextureCache,
                                                                            pixelBuffer,
                                                                            NULL,
                                                                            GL_TEXTURE_2D,
                                                                            GL_LUMINANCE,
                                                                            frameWidth,
                                                                            frameHeight,
                                                                            GL_LUMINANCE,
                                                                            GL_UNSIGNED_BYTE,
                                                                            0,
                                                                            &_lumaTexture);//亮度
            if (err) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
                
            glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
            // UV-plane.
            glActiveTexture(GL_TEXTURE1);
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                   _videoTextureCache,
                                                                   pixelBuffer,
                                                                   NULL,
                                                                   GL_TEXTURE_2D,
                                                                   GL_LUMINANCE_ALPHA,
                                                                   frameWidth/2,
                                                                   frameHeight/2,
                                                                   GL_LUMINANCE_ALPHA,
                                                                   GL_UNSIGNED_BYTE,
                                                                   1,
                                                                   &_chromaTexture);//色彩深度
            if (err) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            }
                
            glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                
                
            self.mEffect.texture2d0.name = CVOpenGLESTextureGetName(_lumaTexture);
            NSLog(@"id %d", self.mEffect.texture2d0.name);
                
                
                
            if (pixelBuffer != NULL) {  // 不加，会导致纹理没释放，id 不断上升
                CFRelease(pixelBuffer);
            }
        }
            
    }
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}


#pragma mark - Playback setup

- (void)setupPlaybackForURL:(NSURL *)URL
{
    /*
     设置item添加output.
     After adding the video output, we request a notification of media change in order to restart the CADisplayLink.
     */
    
    // 清空Item
    [[self.avPlayer currentItem] removeOutput:self.videoOutput];
    
    //数据源
    self.playItem= [AVPlayerItem playerItemWithURL:URL];
    [self.avPlayer addObserver:self forKeyPath:@"currentItem.status" options:NSKeyValueObservingOptionNew context:AVPlayerItemStatusContext];
    AVAsset *asset = [self.playItem asset];
    
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        
        if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] > 0) {
                // 选择 video Track.就 1 个Track
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                    
                    if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.playItem addOutput:self.videoOutput];
                            [self.avPlayer replaceCurrentItemWithPlayerItem:self.playItem];
                            [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                            [self.avPlayer play];
                        });
                        
                    }
                    
                }];
            }
        }
        
    }];
    
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
                //self.view.frame =CGRectMake(0, 0, [[self.avPlayer currentItem] presentationSize].width, [[self.avPlayer currentItem] presentationSize].height);
                NSLog(@"成功\n");
                break;
            case AVPlayerItemStatusFailed:
                [self stopLoadingAnimationAndHandleError:[[self.avPlayer currentItem] error]];
                break;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//健壮性函数
- (void)stopLoadingAnimationAndHandleError:(NSError *)error
{
    if (error) {
        NSLog(@"error\n");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//释放
- (void)viewDidUnload
{
    [super viewDidUnload];
    [self tearDownGL];
    [self cleanUpTextures];
    
}




@end
