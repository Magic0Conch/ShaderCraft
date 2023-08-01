Shader "Hidden/CityShader/Portal2D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "../StdLib.hlsl"
        #include "../XNoiseLibrary.hlsl"
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0; 
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };


        half4 _MainTex_TexelSize;
        float _BlurSize;
        sampler2D _MainTex;
        sampler2D _OriginalTexture;
        half _EmitCenterUVX;
        half _EmitCenterUVY;
        half _EffectOutterHeight;
        half _EffectOutterWidth;
        half _EffectInnerWidth;        

        fixed4 _WaveColor;
        float _Amplitude;
        float _Frequency;
        fixed _WaveWidth;
        half _WaveSpeed;

        fixed _SeamWitdh;
        fixed _IsHorizontal;

        fixed4 portal(float2 uv){

            float side = smoothstep(0.5, 0.2, abs(uv.x));
            fixed center = smoothstep(_SeamWitdh, 0.0, length(uv.x));
            float2 rd = float2(uv.x,uv.y*_Amplitude);
            float time = fmod(_Time.y+15.0f,100000.0f);
            float t = (time+1.)*(0.5-abs(uv.x));
            float n2 = snoise((rd*t+t)*_Frequency/abs(uv.x*t)+(time)*_WaveSpeed);
            float flare = smoothstep(.0,1.,_WaveWidth*.1/length(abs(uv.x)*n2))*side;
            flare = flare-center*clamp((t-1.5)*1.,0.,1.);
            fixed3 col = _WaveColor*2.;
            col *= flare;
            return fixed4(col,1.0*flare*_WaveColor.a);
        }

        fixed4 fragHorizontal(v2f i): SV_Target
        {
            half2 uv = i.uv;
            fixed4 originalColor = tex2D(_OriginalTexture,uv);
            uv = _IsHorizontal>0.5f?fixed2(uv.y,uv.x):uv;
            fixed4 blurColor = tex2D(_MainTex,uv);


            fixed effectRatio = smoothstep(_EffectOutterWidth/2.0,_EffectInnerWidth/2.0,abs(uv.x-_EmitCenterUVX));
            effectRatio*=smoothstep(_EffectOutterHeight/2.0,_EffectOutterHeight/4.0,abs(uv.y-_EmitCenterUVY));
            uv-=.5;
            uv.x = uv.x - _EmitCenterUVX+.5;
            uv.x/=_EffectOutterWidth;
            uv.y = uv.y - _EmitCenterUVY+.5;
            uv.y/=_EffectOutterHeight;
            effectRatio *= uv.y>=-0.5&&uv.y<=0.5?1.:0.;
            fixed4 waveColor = uv.y>=-0.5&&uv.y<=0.5? portal(uv):.0f;
            fixed4 additiveColor = lerp(blurColor,waveColor,waveColor.a);
            fixed4 fragColor = lerp(originalColor,additiveColor,effectRatio);

            return fragColor;
        }


        ENDCG

        UsePass "Hidden/CityShader/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"
        UsePass "Hidden/CityShader/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"  
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragHorizontal

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            ENDCG
        }
    }
}

//uv.x = (uv.x*.5 - 0.5) - _EmitCenterUVX;
//            uv.x*=_EffectOutterWidth;
//float angle = 20; 
//float2x2 rotationMatrix = float2x2(cos(radians(angle)), sin(radians(angle)),
//                                    -sin(radians(angle)), cos(radians(angle)));
//half2 uv = mul(rotationMatrix,float2(i.uv.x,i.uv.y));