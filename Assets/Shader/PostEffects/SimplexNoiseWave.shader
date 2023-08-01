Shader "Unlit/SimplexNoiseWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
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
            half2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        half4 _MainTex_TexelSize;
        float _BlurSize;
        sampler2D _MainTex;
        sampler2D _OriginalTexture;
        half _EmitCenterUVX;
        half _EffectOutterWidth;
        half _EffectInnerWidth;

        fixed4 _WaveColor;
        float _Amplitude;
        float _Frequency;
        fixed _WaveWidth;
        half _WaveSpeed;

        fixed smoothDiff(half curve,half uv_y){
            half texelSizeMin = max(_MainTex_TexelSize.x,_MainTex_TexelSize.y);
            fixed diff = smoothstep(texelSizeMin,-texelSizeMin,curve-uv_y);
            return diff;
        }

        fixed generateWave(half2 uv,half amplitudeScale){
            uv.x*=_Frequency;
            float t = _Time.w*_WaveSpeed;
            fixed edge = snoise(half3(uv+half2(0,t),1.))*_Amplitude*amplitudeScale+.5f-_WaveWidth/2;
            fixed wave = smoothDiff(edge, uv.y) - smoothDiff(edge + _WaveWidth, uv.y);
            return wave;
        }
        ENDCG

        UsePass "Hidden/CityShader/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"
        UsePass "Hidden/CityShader/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"      
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _MainTex_ST;
            half2 _ScanLineJitter;
 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
                fixed effectRatio = smoothstep(_EffectOutterWidth/2.0,_EffectInnerWidth/2.0,abs(uv.x-_EmitCenterUVX));
                fixed wavePattern = generateWave(uv,effectRatio);
                fixed4 blurColor = tex2D(_MainTex,uv);
                fixed4 additiveColor = lerp(blurColor,_WaveColor,wavePattern);
                fixed4 originalColor = tex2D(_OriginalTexture,uv);

                fixed4 fragColor = lerp(originalColor,additiveColor,effectRatio);

                return fragColor;
            }
            ENDCG
        }
    }
}
