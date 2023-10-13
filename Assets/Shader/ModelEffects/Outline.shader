// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/CityShader/Outline"
{

    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Outline ("OutlineWidth", Range(0, 1)) = 0.1
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _InnerColor ("Inner Color",COLOR) = (0,0,0,0)

        _FlashFrequency("Flash Frequency",Range(0,1)) = 0
        _PatternDensity("Pattern Density",Range(0,10)) = 1
        _PatternWidth("Pattern Width",Range(0,1)) = 1
        _PatternColor("Pattern Color",COLOR) = (1,1,1,1)
        _PatternShape("Pattern Shape",Range(0,8)) = 0
        _AnimSpeed("Animation Speed",Range(-2,2))=1

    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100
        Cull Off
        //ZWrite Off

        Blend SrcAlpha OneMinusSrcAlpha

        Pass 
        {
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
                       
            #include "UnityCG.cginc"
            #define PI 3.1415926535

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed3 localPos: POSITION1;
            };

            float _Outline;
            fixed4 _InnerColor;

            half _FlashFrequency;
            half _PatternDensity;
            half _PatternWidth;
            fixed4 _PatternColor;
            half _PatternShape;
            half _AnimSpeed;
            half brightness;
            
            v2f vert (appdata v)
            {   
                v2f o;
                float4x4 scaleMatrix = float4x4(
                    1.0-_Outline,0.0,0.0,0,
                    0.0,1.0-_Outline,0.0,0,
                    0.0,0.0,1.0-_Outline,0,
                    0.0,0.0,0.0,1.0
                );
                float4 pos = mul(scaleMatrix,v.vertex);
                o.vertex = UnityObjectToClipPos(pos);
                o.uv = v.uv;
                o.localPos = v.vertex.xyz;
                return o; 
            }

            
            fixed plotGrid(half2 uv,fixed width){
                half2 uv_anim = half2(lerp(0.0,1.0,uv.x+width/2/_PatternDensity + _Time.y * _AnimSpeed), lerp(0.0,1.0,uv.y+ width/2/_PatternDensity + _Time.y * _AnimSpeed));
                half2 f_uv = frac(uv_anim*_PatternDensity);
                fixed top = step(width,f_uv.x);
                fixed right = step(width,f_uv.y);
                return 1-step(0.5,top*right);
            }

            fixed plotCircle(half2 uv){
                half uv_anim = lerp(0.0,1.0,uv.x + _Time.y * _AnimSpeed);
                half2 f_uv = frac(uv_anim*_PatternDensity);
                return step(1-_PatternWidth,f_uv.x);
            }

            fixed plotDot(half2 uv,fixed width,half p_density){
                half2 uv_anim = half2(lerp(0.0,1.0,uv.x + _Time.y * _AnimSpeed), lerp(0.0,1.0,uv.y + _Time.y * _AnimSpeed));
                half2 f_uv = frac(uv_anim*p_density);
                f_uv.x = f_uv.x<0.5?f_uv.x:1-f_uv.x;
                f_uv.y = f_uv.y<0.5?f_uv.y:1-f_uv.y;
                float r = (width*0.5)*(width*0.5);
                return 1-step(r,f_uv.x*f_uv.x + f_uv.y*f_uv.y);

            }

            fixed plotRadialLine(half2 uv,half angle){
                half2 l = half2(cos(angle),sin(angle));
                half d = dot(uv,l)/length(l);
                half h = length(uv-l*d);
                return 1-step(_PatternWidth/2,h);
            }

            fixed plotRadar(half2 xy,half2 uv){
                //half2 uv_anim = half2(lerp(0.0,1.0,uv.x + _Time.y * _AnimSpeed), lerp(0.0,1.0,uv.y + _Time.y * _AnimSpeed));
                //half2 uv_anim = half2(uv.x + lerp(0.0,1.0, _Time.y * _AnimSpeed), uv.y + lerp(0.0,1.0,_Time.y * _AnimSpeed));
                half acc = 0.0;
                for(half i = 0;i<_PatternDensity;i++){
                    half t = i/_PatternDensity*2;
                    half angle = t*PI;
                    acc+=plotRadialLine(xy,angle);
                }
                acc+=plotCircle(uv);
                return step(0.5,acc);                
            }

            fixed plotLine(half2 uv){
                half2 uv_anim = half2(lerp(0.0,1.0,uv.x + _Time.y * _AnimSpeed), lerp(0.0,1.0,uv.y + _Time.y * _AnimSpeed));
                half2 f_uv = frac(uv_anim*_PatternDensity);                
                fixed right = step(1-_PatternWidth,f_uv.y);
                return step(0.5,right);
            }

            fixed plotGridAndDot(half2 uv){
                half acc = 0.0;
                acc+=plotGrid(uv,_PatternWidth);
                acc+=plotDot(uv,_PatternWidth*3,_PatternDensity);
                acc+=plotDot(uv,_PatternWidth*5,_PatternDensity*6);
                return step(0.5,acc);
            }

            fixed radialDistance(half2 uv){
                half angle = fmod(_Time.y,2*PI);
                //angle-=PI;
                half fragAngle = atan2(uv.y,uv.x)+PI;
                return fmod(angle - fragAngle + 2*PI,2*PI)/(2*PI);
            }

            fixed4 frag(v2f i) : SV_Target 
            { 
                
                fixed pattern;
                if(_PatternShape<0.5){
                    pattern=0;
                }
                else if(_PatternShape<1.5){
                    pattern = plotGrid(i.localPos.xz,_PatternWidth);
                }
                else if(_PatternShape<2.5){
                    pattern = plotDot(i.localPos.xz,_PatternWidth,_PatternDensity);                
                }
                else if(_PatternShape<3.5){
                    pattern = plotGrid(i.uv,_PatternWidth);                                
                }
                else if(_PatternShape<4.5){
                    pattern = plotRadar(i.localPos.xz,i.uv);

                }
                else if(_PatternShape<5.5){
                    pattern = plotLine(i.localPos.xz);
                }
                else if(_PatternWidth<6.5){
                    pattern = plotGridAndDot(i.localPos.xz);
                }



                fixed4 backColor = fixed4((1-pattern) * _InnerColor.rgb,(1-pattern)* _InnerColor.a);
                fixed4 patternColor = fixed4(pattern * _PatternColor.rgb,pattern * _PatternColor.a);
                brightness = (sin(_Time.w*_FlashFrequency*2)+1.5)/2;
                patternColor.rgb*=brightness;
                //if(pattern>0)
                    //patternColor.a=1;
                fixed4 fragColor = backColor + patternColor;
                return fragColor;
            }

            ENDCG
        }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp NotEqual
            }

            CGPROGRAM
            #pragma vertex vert

            #pragma fragment frag
           
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed3 _OutlineColor;


            v2f vert (appdata v)
            { 
                v2f o;

                o.vertex = UnityObjectToClipPos( v.vertex);
                return o; 
            }

            fixed4 frag(v2f i) : SV_Target 
            { 

                return fixed4(_OutlineColor, 1);
            }

            ENDCG
        }

    }
    //FallBack "Diffuse"
}
