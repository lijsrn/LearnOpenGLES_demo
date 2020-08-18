//
//  LongLegVertexAttribArrayBuffer.m
//  longleg
//
//  Created by JH on 2020/8/15.
//  Copyright © 2020 JH. All rights reserved.
//

#import "LongLegVertexAttribArrayBuffer.h"

@interface LongLegVertexAttribArrayBuffer()
@property(nonatomic, assign) GLuint glName;

@property(nonatomic, assign) GLsizeiptr bufferSizeBytes;
@property(nonatomic, assign) GLsizei stride;

@end

@implementation LongLegVertexAttribArrayBuffer
/// 初始化缓存区
/// @param stride 步长
/// @param count 顶点数量
/// @param data 顶点数组
/// @param usage 渲染方式
-(instancetype) initWithAttribStride:(GLsizei)stride
                    numberOfVertices:(GLsizei)count
                                data:(const GLvoid*)data
                               usage:(GLenum)usage{
    self = [super init];
    if (self) {
        _stride = stride;
        _bufferSizeBytes = stride * count;
    }
    return self;
}

/// 准备绘制
/// @param index 属性
/// @param count 坐标数量
/// @param offset 相对偏移量
/// @param shouldEnable 是否开启属性
-(void) prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;


/// 绘制
/// @param mode 图元类型
/// @param first 起始点
/// @param count 数量
-(void)drawArrayWithMode:(GLenum)mode
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count;

//更新(重新开辟缓存区)
- (void)updateDataWithAttribStride:(GLsizei)stride
                  numberOfVertices:(GLsizei)count
                              data:(const GLvoid *)data
                             usage:(GLenum)usage;
@end
