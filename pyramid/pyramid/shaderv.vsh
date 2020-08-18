attribute vec4 position;
attribute vec4 positionColor;
attribute vec2 textCoord;

uniform mat4 projectionMatrix;
uniform mat4 modeViewMatrix;

varying lowp vec4 varyColor;
varying lowp vec2 vTextCoord;

void main(){
    varyColor = positionColor;
    
    vTextCoord = textCoord;
    
    vec4 vPos;
    //矩阵变换后的顶点位置
    vPos = projectionMatrix * modeViewMatrix * position;
    gl_Position = vPos;
}
