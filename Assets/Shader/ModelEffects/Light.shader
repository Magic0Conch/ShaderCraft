// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/CityShader/Sh_Light"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Main Tint",COLOR) = (1,1,1,1)
        [Toggle(_True)]_Fade("Fade",float)=1
        _FlashFrequency("FlashFrequency",Range(0.0,5)) = 1

        _BackStyle("BackStyle",Range(0,5)) = 0

        _OutterWidth("Outter Width",Range(0,1)) = 0
        _PatternDensity("Pattern Density",Range(0,10)) = 1
        _PatternWidth("Pattern Width",Range(0,1)) = 1        
        _PatternColor("Pattern Color",COLOR) = (1,1,1,1)
        _PatternShape("Pattern Shape",Range(1,5)) = 1
        _AnimSpeed("Anim Speed",Range(-1,1)) = 1

        _Radius("radius",FLOAT) = 1
        _Height("height",FLOAT) = 1

    }
    SubShader
    {
        //TODO :true or True?
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            ZWrite On
            Cull Off

            //Normal
            Blend SrcAlpha OneMinusSrcAlpha

            //Soft Additive
            //Blend OneMinusDstColor One


            //Multiply
            //Blend DstColor Zero



            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #define PI 3.1415926535
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 localPos:POSITION1;
                fixed alpha: Alpha;
                
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _PatternColor;
            fixed _AnimSpeed;
            fixed _PatternDensity;
            fixed _PatternWidth;
            float4 _MainTex_ST;
            
            half brightness;
            half _FlashFrequency;
            half _OutterWidth;
            half _PatternShape;
            half _Radius;
            half _Height;
            bool _Fade;

            half _BackStyle;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.localPos = v.vertex.xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float a = clamp(1-v.uv.y,0.0,1.0);                
                if(_Fade)
                    o.alpha = a;
                else
                    o.alpha = 1;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed luminance(fixed4 col){
                return col.r * 0.2125 + col.g * 0.7154 + col.b * 0.0721;
            }

            fixed2 plotLine(half2 uv,half speed,float PatternDensity,float PatternWidth){
                half2 st = half2(uv.x,lerp(0.0,1.0,uv.y+_Time.y*speed));
                half2 f_st = frac(st*PatternDensity);
                fixed alpha = step(1 - PatternWidth,f_st.y)>0.5?1.0:0;
                return fixed2(step(1 - PatternWidth,f_st.y),alpha);
            }

            fixed2 plotGrid(half2 uv,fixed width){
                float angle = 45; 
                float2x2 rotationMatrix = float2x2(cos(radians(angle)), sin(radians(angle)),
                                                   -sin(radians(angle)), cos(radians(angle)));
                float2 rotate_uv = mul(rotationMatrix,float2(uv.x,uv.y));
                fixed alpha = lerp(0,_Height,uv.y)/_Height;
                half2 f_uv = frac(rotate_uv*_PatternDensity);
                fixed top = step(width,f_uv.x);
                fixed right = step(width,f_uv.y);
                alpha = 1-step(0.5,top*right)>0.5?alpha:0;
                return fixed2(1-step(0.5,top*right),alpha);
            }

            fixed2 plotVerticalLine(half2 uv){
                float angle = 20; 
                float2x2 rotationMatrix = float2x2(cos(radians(angle)), sin(radians(angle)),
                                                   -sin(radians(angle)), cos(radians(angle)));
                float2 rotate_uv = mul(rotationMatrix,float2(uv.x,uv.y));

                half2 st = half2(lerp(0.0,1.0,rotate_uv.y+_Time.y*_AnimSpeed),rotate_uv.x);
                half2 f_st = frac(st*_PatternDensity);
                fixed alpha =  1 - abs(uv.y-_Height/2)/_Height*2;
                alpha = step(1 - _PatternWidth,f_st.y)>0.5?alpha:0;
                return fixed2(step(1 - _PatternWidth,f_st.y),alpha);
            }

            fixed radialDistance(half2 uv){
                half angle = fmod(_Time.w*_AnimSpeed,2*PI);
                half fragAngle = atan2(uv.y,uv.x)+PI;
                return fmod(angle - fragAngle + 2*PI,2*PI)/(2*PI);
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 albedo = _Color;
                fixed2 pattern;

                half2 xz = half2(i.localPos.x,i.localPos.z);
                half fragAngle = atan2(xz.y,xz.x)+PI;
                half radius = length(i.localPos.xz);
                half2 uv = half2(fragAngle*_Radius,i.localPos.y);

                if(_PatternShape<1.5){
                    pattern = plotLine(i.uv,_AnimSpeed,_PatternDensity,_PatternWidth);
                }
                else if(_PatternShape<2.5){
                    pattern = plotGrid(uv,_PatternWidth);
                }
                else if(_PatternShape<3.5){
                    pattern = plotVerticalLine(uv);
                }
                else if(_PatternShape<4.5){
                    //pattern = plotRadar(i.localPos.xz,i.uv);

                }
                else if(_PatternShape<5.5){
                    //pattern = plotLine(i.localPos.xz);
                }
                else if(_PatternShape<6.5){
                    //pattern = plotGridAndDot(i.localPos.xz);
                }

                pattern = i.localPos.y/_Height>1-_OutterWidth?half2(1,1):pattern;

                fixed4 backColor = fixed4((1-pattern.x) * _Color.rgb,(1-pattern.x)* _Color.a*i.alpha);
                if(_BackStyle<0.5){
                
                }
                else if(_BackStyle<1.5){
                    backColor.a *= radialDistance(i.localPos.xz);                
                }
                fixed4 patternColor = fixed4(pattern.x * _PatternColor);
                patternColor.a = clamp(pattern.y,0,1);
                

                brightness = sin(_Time.z*_FlashFrequency)+1.5;
                patternColor.rgb *= brightness;

                fixed4 fragColor = backColor + patternColor;                
                return fragColor;
            }
            ENDCG
        }
    }
}
