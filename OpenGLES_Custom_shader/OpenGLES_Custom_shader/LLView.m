//
//  LLView.m
//  OpenGLES_Custom_shader
//
//  Created by JH on 2020/7/30.
//  Copyright © 2020 JH. All rights reserved.
//

#import "LLView.h"
#import <OpenGLES/ES2/gl.h>

@interface LLView ()

@property(nonatomic,strong) CAEAGLLayer *mayEagLayer;

@property(nonatomic,strong) EAGLContext *myContext;

@property(nonatomic,assign) GLuint myColorRenderBuffer;

@property(nonatomic,assign) GLuint myCOlorFrameBuffer;

@property(nonatomic,assign) GLuint myPrograme;



@end

@implementation LLView

- (void)layoutSubviews{
    //1.设置图层
      [self setupLayer];
      
      //2.设置图形上下文
      [self setupContent];
      
      //3.清空缓存区
      [self deleteRenderAndFrameFuffer];

      //4.设置RenderBuffer
      [self setupRenderBuffer];
      
      //5.设置FrameBuffer
      [self setupFrameBuffer];
      
      //6.开始绘制
      [self renderLayer];
}

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

-(void)renderLayer{
    glClearColor(0.3f, 0.45f, 0.5f, 1.0f);
    //清除屏幕
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
    
    self.myPrograme = [self loaderShader:vertFile withFrag:fragFile];
    
    glLinkProgram(self.myPrograme);
    GLint linkStatus;
    glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
       if (linkStatus == GL_FALSE) {
           GLchar message[512];
           glGetProgramInfoLog(self.myPrograme, sizeof(message), 0, &message[0]);
           NSString *messageString = [NSString stringWithUTF8String:message];
           NSLog(@"Program Link Error:%@",messageString);
           return;
       }
    glUseProgram(self.myPrograme);
    GLfloat attrArr[] =
      {
          0.5f, -0.25f, -1.0f,     1.0f, 0.0f,
          -0.5f, 0.25f, -1.0f,     0.0f, 1.0f,
          -0.5f, -0.25f, -1.0f,    0.0f, 0.0f,
          
          0.5f, 0.25f, -1.0f,      1.0f, 1.0f,
          -0.5f, 0.25f, -1.0f,     0.0f, 1.0f,
          0.5f, -0.25f, -1.0f,     1.0f, 0.0f,
      };
      
    GLuint attrbuffer;
    glGenBuffers(1, &attrbuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrbuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_STATIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *5, NULL + 0);
    
    GLuint textCoor = glGetAttribLocation(self.myPrograme, "textCoordinate");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL +3);
    
    [self setupTexture:@"lufei.jpg"];
    
    //设置纹理采样器
    glUniform1f(glGetUniformLocation(self.myPrograme, "colorMap"), 0);
    
    //12.绘图
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    //13.从渲染缓存区显示到屏幕上
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
}

//加载纹理
-(GLuint)setupTexture:(NSString *)fileName{
    
       //1、将 UIImage 转换为 CGImageRef
       CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
       
       //判断图片是否获取成功
       if (!spriteImage) {
           NSLog(@"Failed to load image %@", fileName);
           exit(1);
       }
    
    //2、读取图片的大小，宽和高
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    
    GLubyte *spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
     CGRect rect = CGRectMake(0, 0, width, height);
    
     //6.使用默认方式绘制
     CGContextDrawImage(spriteContext, rect, spriteImage);
    
    //翻转坐标系
    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
     //7、画图完毕就释放上下文
     CGContextRelease(spriteContext);
     
     //8、绑定纹理到默认的纹理ID（
     glBindTexture(GL_TEXTURE_2D, 0);
     
     //9.设置纹理属性
     /*
      参数1：纹理维度
      参数2：线性过滤、为s,t坐标设置模式
      参数3：wrapMode,环绕模式
      */
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
     glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
     
     float fw = width, fh = height;
     
     //10.载入纹理2D数据
     /*
      参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
      参数2：加载的层次，一般设置为0
      参数3：纹理的颜色值GL_RGBA
      参数4：宽
      参数5：高
      参数6：border，边界宽度
      参数7：format
      参数8：type
      参数9：纹理数据
      */
     glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
     
     //11.释放spriteData
     free(spriteData);
     return 0;
}

-(void)setupFrameBuffer{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myCOlorFrameBuffer = buffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.myCOlorFrameBuffer);
    
    //将renderbuffer和framebuffer绑定
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}


-(void)setupRenderBuffer{
    GLuint buffer;
    
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.mayEagLayer];
}

//4.清空缓冲区，避免残留数据
-(void)deleteRenderAndFrameFuffer{
    
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
    glDeleteBuffers(1, &_myCOlorFrameBuffer);
    self.myCOlorFrameBuffer = 0;
}

//3
-(void)setupContent{
    EAGLContext *context = [[EAGLContext alloc ] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    self.myContext = context;
}

//2.设置图层
-(void)setupLayer{
    self.mayEagLayer = (CAEAGLLayer *)self.layer;
    
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    //设置描述属性
    self.mayEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@false,kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
}


//1.加载着色器
-(GLuint) loaderShader:(NSString *)vert withFrag:(NSString *)frag{
    GLuint verShader,fragShader;
    
    GLuint program = glCreateProgram();
    
    //编译着色器源码
    [self compleShader:&verShader type:GL_VERTEX_SHADER file:vert];
     [self compleShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    //创建最终的程序
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

//编译shader
-(void)compleShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    //1.读取文件路径字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = (GLchar *) [content UTF8String];
    *shader = glCreateShader(type);
    //将source附着到shader
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
    
}

@end
