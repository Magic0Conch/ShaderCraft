Shader "Hidden/CityShader/DirectionalBlur"
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
        
        sampler2D _MainTex;
        half _Iterations;
        half2 _Direction;
        fixed4 _BlurColor;
        half _BrightnessMagnification;

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

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                col.rgb = col.rgb;
                return col;
            }
            ENDCG
        }

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlur

            fixed4 fragBlur(v2f i):SV_Target
            {
                fixed4 texCol = tex2D(_MainTex,i.uv);
                half4 fragColor = half4(.0,.0,.0,.0);
                for(int k = -_Iterations;k<_Iterations;k++){
                    half2 sampleUVs = i.uv - _Direction*k;
                    fragColor+=tex2D(_MainTex,sampleUVs);
                }
                fragColor/=_Iterations*2.0f;
                float luminance = max(dot(fragColor.rgb,fixed3(.3f, .59f, .11f)),6.10352e-5);
                fragColor = saturate(luminance * _BlurColor*_BrightnessMagnification);
                return fragColor;
            }

            ENDCG
        }
    }
}
