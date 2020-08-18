//
//  ViewController.m
//  CubeImage
//
//  Created by JH on 2020/8/2.
//  Copyright © 2020 JH. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord;   //顶点坐标
    GLKVector2 textureCoord;    //纹理坐标
    GLKVector3 normal ; //法线，光照
} LLVertex;

static NSInteger const kCoordCount = 36;

@interface ViewController ()<GLKViewDelegate>

@property(nonatomic,strong) GLKView *glkView;

@property(nonatomic,strong) GLKBaseEffect *baseEffect;// 固定着色器

@property(nonatomic,assign) LLVertex *vertices;

@property(nonatomic,strong) CADisplayLink *displayLink;

@property(nonatomic,assign) NSInteger angle;

@property (nonatomic, assign) GLuint vertexBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self addCADisplayLink];
}

-(void)commonInit{
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [EAGLContext setCurrentContext:context];
    
    //2.创建GLKView并设置代理
      CGRect frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width);
      self.glkView = [[GLKView alloc] initWithFrame:frame context:context];
      self.glkView.backgroundColor = [UIColor clearColor];
      self.glkView.delegate = self;
    
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glDepthRangef(1, 0);
    
    [self.view addSubview:self.glkView];
    
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"lufei.jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    //6.设置纹理参数
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];
    self.baseEffect = [[GLKBaseEffect alloc] init];

    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    //开启光源
    self.baseEffect.light0.enabled = YES;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);//漫反射
    self.baseEffect.light0.position = GLKVector4Make(-0.5, -0.5, 5, 1);//光源位置
    
    //开辟顶点空间
    self.vertices = malloc(sizeof(LLVertex)* kCoordCount);
    // 前面
    self.vertices[0] = (LLVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 0, 1}};
    self.vertices[1] = (LLVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.vertices[2] = (LLVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.vertices[3] = (LLVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.vertices[4] = (LLVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.vertices[5] = (LLVertex){{0.5, -0.5, 0.5}, {1, 0}, {0, 0, 1}};
    
    // 上面
    self.vertices[6] = (LLVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 1, 0}};
    self.vertices[7] = (LLVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.vertices[8] = (LLVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.vertices[9] = (LLVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.vertices[10] = (LLVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.vertices[11] = (LLVertex){{-0.5, 0.5, -0.5}, {0, 0}, {0, 1, 0}};
    
    // 下面
    self.vertices[12] = (LLVertex){{0.5, -0.5, 0.5}, {1, 1}, {0, -1, 0}};
    self.vertices[13] = (LLVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.vertices[14] = (LLVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.vertices[15] = (LLVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.vertices[16] = (LLVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.vertices[17] = (LLVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, -1, 0}};
    
    // 左面
    self.vertices[18] = (LLVertex){{-0.5, 0.5, 0.5}, {1, 1}, {-1, 0, 0}};
    self.vertices[19] = (LLVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.vertices[20] = (LLVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.vertices[21] = (LLVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.vertices[22] = (LLVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.vertices[23] = (LLVertex){{-0.5, -0.5, -0.5}, {0, 0}, {-1, 0, 0}};
    
    // 右面
    self.vertices[24] = (LLVertex){{0.5, 0.5, 0.5}, {1, 1}, {1, 0, 0}};
    self.vertices[25] = (LLVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.vertices[26] = (LLVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.vertices[27] = (LLVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.vertices[28] = (LLVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.vertices[29] = (LLVertex){{0.5, -0.5, -0.5}, {0, 0}, {1, 0, 0}};
    
    // 后面
    self.vertices[30] = (LLVertex){{-0.5, 0.5, -0.5}, {0, 1}, {0, 0, -1}};
    self.vertices[31] = (LLVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.vertices[32] = (LLVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.vertices[33] = (LLVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.vertices[34] = (LLVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.vertices[35] = (LLVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, 0, -1}};
    
    
    //顶点数据传入GPU
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(LLVertex) * kCoordCount, self.vertices, GL_STATIC_DRAW);
    
    //纹理坐标传入GPU
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(LLVertex), NULL + offsetof(LLVertex, positionCoord));
    
    //纹理传入GPU
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(LLVertex), NULL + offsetof(LLVertex, textureCoord));
    
    //法向量传入GPU
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal,3,GL_FLOAT,GL_FALSE,sizeof(LLVertex),NULL + offsetof(LLVertex, normal));

}

-(void) addCADisplayLink{
   
    self.angle = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}


-(void)update{
    self.angle = ( self.angle + 1) % 360;
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.angle), 0.3, 1, 0.7);
    [self.glkView display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glEnable(GL_DEPTH_TEST);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, kCoordCount);
}

- (void)dealloc {
    
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    
    //displayLink 失效
    [self.displayLink invalidate];
}


@end
