//
//  LLView.m
//  pyramid
//
//  Created by JH on 2020/8/2.
//  Copyright © 2020 JH. All rights reserved.
//

#import "LLView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLESMath.h"

@interface LLView()

@property(nonatomic,strong) CAEAGLLayer *myEaglLayer;

@property(nonatomic,strong) EAGLContext *myContext;

@property(nonatomic,assign)GLuint myColorRenderBuffer;
@property(nonatomic,assign)GLuint myColorFrameBuffer;

@property(nonatomic,assign)GLuint myProgram;
@property (nonatomic , assign) GLuint  myVertices;

@end

@implementation LLView

{
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL bX;
    BOOL bY;
    BOOL bZ;
    NSTimer* myTimer;
    
    
}

-(void)layoutSubviews{
    
    //1.设置图层
    [self setupLayer];
    
    //2.设置上下文
    [self setupContext];
    
    //3.清空缓存区
    [self deletBuffer];
    
    //4.设置renderBuffer;
    [self setupRenderBuffer];
    
    //5.设置frameBuffer
    [self setupFrameBuffer];
    
    //6.绘制
    [self render];
    
}

+(Class)layerClass{
    return  [CAEAGLLayer class];
}

-(void)render{
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    //2.设置视口
      glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    //3.获取顶点着色程序、片元着色器程序文件位置
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    if (self.myProgram) {
        glDeleteProgram(self.myProgram);
        self.myProgram = 0;
    }
    self.myProgram = [self loadSahder:vertFile frag:fragFile];
    
    glLinkProgram(self.myProgram);
    GLint linkSuccess;
    
    //7.获取链接状态
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        
        return ;
    }else {
        glUseProgram(self.myProgram);
    }
    //8.创建顶点数组 & 索引数组
    //(1)顶点数组 前3顶点值（x,y,z），后3位颜色值(RGB)
    GLfloat attrArr[] =
    {
        -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, 0.0f, 1.0f,//左上0
        0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, 1.0f, 1.0f,//右上1
        -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, 0.0f, 0.0f,//左下2
        
        0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, 1.0f, 0.0f,//右下3
        0.0f, 0.0f, 1.0f,       0.0f, 1.0f, 0.0f,  0.5, 0.5//顶点4
    };
    
    //(2).索引数组
    GLuint indices[] =
    {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    if (self.myVertices == 0) {
        glGenBuffers(1, &_myVertices);
        
        
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat ) * 8, (GLfloat *) NULL);
    
    GLuint positionColor = glGetAttribLocation(self.myProgram, "positionColor");
    
     //(2).设置合适的格式从buffer里面读取数据
     glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat ) * 8, (GLfloat *) NULL+ 3);
    
    
    GLuint textCoord = glGetAttribLocation(self.myProgram, "textCoord");
    
    glEnableVertexAttribArray(textCoord);
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat ) * 8, (GLfloat *) NULL + 6);
    
    [self loadTexture:@"lufei.jpg"];
    glUniform1i(glGetUniformLocation(self.myProgram, "colorMap"), 0);
    
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix");
    GLuint modeviewMatrixSlot =glGetUniformLocation(self.myProgram, "modeViewMatrix");
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float aspect = width / height;
    //投影矩阵
    KSMatrix4 _projectionMatrix;
    //加载单元矩阵
    ksMatrixLoadIdentity(&_projectionMatrix);
    //投影变换
    ksPerspective(&_projectionMatrix, 30, aspect, 5, 20);
    
    //将投影矩阵传递到顶点着色器中
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE,(GLfloat *) &_projectionMatrix.m[0][0]);
    
    //模型视图矩阵
    KSMatrix4 _modelviewMatrix;
    ksMatrixLoadIdentity(&_modelviewMatrix);
    //矩阵后移10
    ksTranslate(&_modelviewMatrix, 0, 0, -10);
    //旋转矩阵
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, xDegree, 1, 0, 0); // x轴旋转度数
    ksRotate(&_rotationMatrix, yDegree, 0, 1, 0); // y轴旋转度数
    ksRotate(&_rotationMatrix, zDegree, 0, 0, 1); // z轴旋转度数
    
    //模型视图矩阵与选择矩阵进行叉乘
    ksMatrixMultiply(&_modelviewMatrix, &_rotationMatrix, &_modelviewMatrix);
    //将叉乘后的modelviewMatrix传入顶点着色器
    glUniformMatrix4fv(modeviewMatrixSlot, 1, GL_FALSE, (GLfloat *)&_modelviewMatrix);
    
    glEnable(GL_CULL_FACE);
    
    // 使用索引绘制图形
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    
}

-(void)loadTexture:(NSString *)imageName{
    
    CGImageRef spriteImage = [UIImage imageNamed:imageName].CGImage;
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte *spriteData = (GLubyte *)calloc(width * height *4 , sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGContextDrawImage(spriteContext, rect, spriteImage);
    CGContextTranslateCTM(spriteContext, 0, rect.size.height);
    CGContextScaleCTM(spriteContext, 1.0, -1.0);
     CGContextDrawImage(spriteContext, rect, spriteImage);
     
      //7、画图完毕就释放上下文
      CGContextRelease(spriteContext);
    
    glBindTexture(GL_TEXTURE0, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
}

-(void)setupFrameBuffer
{
    //1.定义一个缓存区
    GLuint buffer;
    //2.申请一个缓存区标志
    glGenFramebuffers(1, &buffer);
    //3.
    self.myColorFrameBuffer = buffer;
    //4.设置当前的framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    //5.将_myColorRenderBuffer 装配到GL_COLOR_ATTACHMENT0 附着点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}

//4.设置renderBuffer
-(void)setupRenderBuffer
{
    //1.定义一个缓存区
    GLuint buffer;
    //2.申请一个缓存区标志
    glGenRenderbuffers(1, &buffer);
    //3.
    self.myColorRenderBuffer = buffer;
    //4.将标识符绑定到GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEaglLayer];
    
}

//3.清空缓存区
-(void)deletBuffer
{
    glDeleteBuffers(1, &_myColorRenderBuffer);
    _myColorRenderBuffer = 0;
    
    glDeleteBuffers(1, &_myColorFrameBuffer);
    _myColorFrameBuffer = 0;
    
}



//2.设置上下文
-(void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:api];
    if (!context) {
        NSLog(@"Create Context Failed");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Set Current Context Failed");
        return;
    }
    self.myContext = context;
    
}


-(void)setupLayer{
    self.myEaglLayer = (CAEAGLLayer *) self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.myEaglLayer.opaque = YES;
    self.myEaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

-(GLuint)loadSahder:(NSString *)vert frag:(NSString *)frag{
    GLuint verShader,fragShader;
    
    GLuint program = glCreateProgram();
    
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

-(void)compileShader:(GLuint *)shader type:(GLenum) type file:(NSString *)file{
    
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    const GLchar *source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    
    glShaderSource(*shader, 1, &source, NULL);
    
    glCompileShader(*shader);
}
- (IBAction)xDrgee:(id)sender {
    
    //开启定时器
      if (!myTimer) {
          myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
      }
      //更新的是X还是Y
      bX = !bX;
      
}

- (IBAction)yDrgee:(id)sender {
    
    
    //开启定时器
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bY = !bY;
}

- (IBAction)zDrgee:(id)sender {
    
    if (!myTimer) {
         myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
     }
     //更新的是X还是Y
     bZ = !bZ;
}

-(void)reDegree
{
    //如果停止X轴旋转，X = 0则度数就停留在暂停前的度数.
    //更新度数
    xDegree += bX * 5;
    yDegree += bY * 5;
    zDegree += bZ * 5;
    //重新渲染
    [self render];
    
}

@end
