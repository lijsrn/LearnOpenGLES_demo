precision highp float;
varying lowp vec4 varyColor;

varying lowp vec2 vTextCoord;

uniform  sampler2D colorMap;

void main(){
    
    float alpha = 0.3;
    
    gl_FragColor = varyColor*( 1.0 - alpha) + texture2D(colorMap,vTextCoord) * alpha;
}
