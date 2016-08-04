//
//  AnotherOpenGLPlayerViewController.m
//  AVPlayerWithOpenGL
//
//  Created by baidu on 16/8/2.
//  Copyright © 2016年 史瑞昌. All rights reserved.
//

#import "AnotherOpenGLPlayerViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.709, which is the standard for HDTV.
static const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

@interface AnotherOpenGLPlayerViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (assign, nonatomic) GLuint *program;
@property (strong, nonatomic) CADisplayLink* displayLink;
@property(assign,nonatomic)const GLfloat *preferredConversion;

@end

@implementation AnotherOpenGLPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化OpenGL 2.0上下文
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.enableSetNeedsDisplay = NO;
    self.preferredFramesPerSecond = 0.0f;//帧率,设置成0，系统不再自行渲染，而是走displaylink

    
    // Set the default conversion to BT.709, which is the standard for HDTV.
    self.preferredConversion = kColorConversion709;
 
//    [self setupGL];
//    [self startDeviceMotion];
//    [self startRender];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
