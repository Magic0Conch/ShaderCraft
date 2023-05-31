Shader "Unlit/PathFXShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BackColor("Back Tint",COLOR) = (1,1,1,1)
        _FlashFrequency("FlashFrequency",Range(0.0,5)) = 1
        _OutterWidth("Outter Width",Range(0,1)) = 0
        _OutterColor("Outter Color",COLOR) = (1,1,1,1)
        _OutterGradientLowerBound("Outter Gradient Lower Bound",Range(0,1))=1
        _PatternDensity("Pattern Density",Range(0,10)) = 1
        _PatternWidth("Pattern Width",Range(0,1)) = 1        
        _PatternColor("Pattern Color",COLOR) = (1,1,1,1)
        _PatternShape("Pattern Shape",Range(1,5)) = 1
        _AnimSpeed("Anim Speed",Range(-1,1)) = 1
        _PathWidth("Path Width",FLOAT) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull OFF

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _BackColor;
            half _FlashFrequency;
            half _OutterWidth;
            half _PatternDensity;
            half _PatternWidth;
            fixed4 _PatternColor;
            half _PatternShape;
            half _AnimSpeed;
            half _PathWidth;
            fixed _OutterGradientLowerBound;
            fixed4 _OutterColor;

            fixed2 plotTexture(half2 uv){
                uv.y = (uv.y+_Time.y*_AnimSpeed)*_PatternDensity;
                half2 f_uv = uv;
                fixed4 texColor = tex2D(_MainTex,f_uv.yx);
                fixed2 pattern = fixed2(texColor.a,1-texColor.a);
                return pattern;
            }

            fixed2 plotLine(half2 uv){
                uv.y = uv.y+_Time.y*_AnimSpeed;
                half2 f_uv = frac(uv*_PatternDensity);
                fixed2 pattern = fixed2(step(1-_PatternWidth,f_uv.y),1);
                return pattern;
            }

            fixed2 plotArrow(half2 uv){
                float angle = _Time.z*5; 
                float2x2 rotationMatrix = float2x2(cos(radians(angle)), sin(radians(angle)),
                                                   -sin(radians(angle)), cos(radians(angle)));
                uv.y = (uv.y+_Time.y*_AnimSpeed)*_PatternDensity;
                //uv = mul(rotationMatrix,uv);
                half2 f_uv = frac(uv);
                half dist = uv.x>0.5? abs(f_uv.y-f_uv.x*2+0.75):abs(f_uv.y+f_uv.x*2-1.25);
                fixed2 pattern = fixed2(step(1-_PatternWidth,1-dist),1);
                return pattern;            
            }

            fixed2 plotPattern(half2 uv){
                fixed2 pattern=fixed2(1.0,1.0);
                if(_PatternShape<1.0){
                    pattern = plotTexture(uv);
                }
                else if(_PatternShape<2.0){
                    pattern = plotLine(uv);
                }
                else if(_PatternShape<3.0){
                    pattern = plotArrow(uv);
                }
                return pattern;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 uv = half2((i.uv.x-_OutterWidth*0.5f)/(1-_OutterWidth),i.uv.y);
                fixed2 pattern=uv.x>=0&&uv.x<=1?plotPattern(uv):fixed2(0.0f,0.0f);

                fixed4 backColor = fixed4((1 - pattern.x)*_BackColor.rgb,(1-pattern.x)*_BackColor.a);
                fixed4 patternColor = fixed4(pattern.x*_PatternColor.rgb,pattern.y*_PatternColor.a);
                fixed4 outterColor = fixed4(.0f,.0f,.0f,.0f);
                fixed t = i.uv.x/_OutterWidth*2.0f;
                outterColor = uv.x<0?fixed4(lerp(_OutterColor.rgb*_OutterColor.a,_OutterColor.rgb*_OutterColor.a*_OutterGradientLowerBound,t).rgb,lerp(_OutterColor.a,_OutterGradientLowerBound,t)):outterColor;
                t = (1.0f-i.uv.x)/_OutterWidth*2.0f;
                outterColor = uv.x>1?fixed4(lerp(_OutterColor.rgb*_OutterColor.a,_OutterColor.rgb*_OutterColor.a*_OutterGradientLowerBound,t).rgb,lerp(_OutterColor.a,_OutterGradientLowerBound,t)):outterColor;

                half brightness = sin(_Time.z*_FlashFrequency)+1.5;
                patternColor.rgb*=brightness;

                fixed4 fragColor = saturate(backColor + patternColor+outterColor);
                return fragColor;
            }
            ENDCG
        }
    }
}
