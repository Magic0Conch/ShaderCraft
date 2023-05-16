Shader "CityShader/Sh_Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Bloom("Bloom",2D) = "black"{}
        _LuminanceThreshold("LuminanceThreshold",float) = 0.5
        _BlurSize("Blur Size",float)=1.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        sampler2D _Bloom;
        float _LuminanceThreshold;
        float _BlurSize;
        half4 _MainTex_TexelSize;

        

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

        v2f vertExtractBright(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        fixed luminance(fixed4 col){
            return col.r * 0.2125 + col.g * 0.7154 + col.b * 0.0721;
        }

        fixed4 fragExtractBright(v2f i):SV_Target{
            fixed4 col = tex2D(_MainTex, i.uv);
            fixed brightness = luminance(col);
            fixed val = clamp(brightness-_LuminanceThreshold,0.0,1.0);
            return col * val;
        }

        struct v2fBloom{
            float4 vertex: SV_POSITION;
            half4 uv: TEXCOORD0;
        };

        v2fBloom vertBloom (appdata v)
        {
            v2fBloom o;
            o.vertex = UnityObjectToClipPos(v.vertex);

            o.uv.xy = v.uv;
            o.uv.zw = v.uv;
            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y<0.0)
                o.uv.w = 1.0 - o.uv.w;
            #endif
            return o;
        }

        //sampler2D _MainTex;

        fixed4 fragBloom (v2fBloom i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv.xy);
            
            return col + tex2D(_Bloom,i.uv.zw);
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }

        UsePass "CityShader/Sh_GaussianBlur/GAUSSIAN_BLUR_VERTICAL"

        UsePass "CityShader/Sh_GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"

        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom


            ENDCG
        }
    }
    FallBack Off
}
