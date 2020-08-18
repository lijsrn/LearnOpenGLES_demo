//
//  ViewController.m
//  OpenGLes_demo
//
//  Created by JH on 2020/7/26.
//  Copyright © 2020 JH. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3//glext.h>

@interface ViewController ()
{
    EAGLContext *context;
    // 简单的光源和着色系统（固定着色器）
    GLKBaseEffect *effect; //
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.初始化
    [self setupConfig];
    
    //2、设置顶点数据
    [self setupVertexData];
    //3. 
    [self setUpTexture];
}

//1.初始化设置
-(void)setupConfig{
    //1.初始化openGLEs上下文
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

    //2.
    if (!context) {
        NSLog(@"失败");
        return;
    }
    
    //3.设置当前上下文，可以有多个上下文，但是只能有一个当前上下文
    [EAGLContext setCurrentContext:context];

    
    //4. 接管view
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    
    //4.1颜色缓冲区格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    //4.2 深度缓冲区渲染格式， GLKViewDrawableDepthFormat16 和 GLKViewDrawableDepthFormat24两中，值越大z-fighting的概率就越小，但现代设备很少出现z-fighting
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //5. 背景色
    glClearColor(0, 0, 1, 1);
}

//2.设置顶点数据
-(void) setupVertexData {
    
    //顶点数组，在内存中
    GLfloat vertextData[] = {
      
        // 顶点坐标              纹理坐标
        0.5f,  -0.5f, 0.0f,   1.0f, 0.0f, // 右下
        0.5f,  0.5f, 0.0f,    1.0f, 1.0f, // 右上
        -0.5f, 0.5f, 0.0f,    0.0f, 1.0f, // 左上
        
        0.5f,  -0.5f, 0.0f,   1.0f, 0.0f, // 右下
        -0.5f,  0.5f, 0.0f,   0.0f, 1.0f, // 左上
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, // 左上
    };
    
    //2.顶点缓冲区 -> GPU显存
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    
    //3.绑定顶点缓冲区
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    
    //4.顶点从内存中复制到顶点缓冲区
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertextData), vertextData, GL_STATIC_DRAW);
    
    //顶点着色器在服务端的属性是关闭的，所以需要手动开启
    
    //4. 打开顶点数据的通道
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //5. 读取顶点数据  顶点缓冲区 -> 顶点着色器
    // size
    glVertexAttribPointer(GLKVertexAttribPosition,//打开的是哪个属性，现在是顶点
                          3, // 每次读取vertexData 3个数据
                          GL_FLOAT,
                          false,
                          sizeof(GL_FLOAT) * 5 //步长，间隔多少去从一位数组中取顶点数据
                        , (GLfloat *)NULL + 0);// 从哪个位置取
    
    //6.打开纹理数据通道
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, //打开纹理属性
                          2,        //每次从vertexData 2个数据
                          GL_FLOAT,
                          false, sizeof(GL_FLOAT) * 5 , //步长
                          (GLfloat *)NULL + 3);
}

-(void)setUpTexture{
    
    //1.获取图片路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lufei" ofType:@"jpg"];
    //2.设置纹理的参数
    //翻转坐标系，  纹理坐标原点：左下角，图片的原点：坐上
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@(1)};
    
    //3.加载图片
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //4.  baseEffect 固定着色器，（顶点和片元着色器）
    effect = [[GLKBaseEffect alloc] init];
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = textureInfo.name;
    
}


//这个会不断调用
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{

    glClear(GL_COLOR_BUFFER_BIT );
    
    //准备绘制
    [effect prepareToDraw];
    //开始绘制
    glDrawArrays(GL_TRIANGLES, //图元类型
                 0, //从第几个顶点开始
                 6); //顶点数量
}


@end
