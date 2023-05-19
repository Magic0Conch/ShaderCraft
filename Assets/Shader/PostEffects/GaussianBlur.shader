Shader "CityShader/Sh_GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("BlurSize", Float) = 1.0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"
        
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            half2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };
        half4 _MainTex_TexelSize;
        float _BlurSize;

        v2f vertBlurVertical (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv;
            o.uv[1] = v.uv + half2(0.0,_MainTex_TexelSize.y*1.0)*_BlurSize;
            o.uv[2] = v.uv - half2(0.0,_MainTex_TexelSize.y*1.0)*_BlurSize;
            o.uv[3] = v.uv + half2(0.0,_MainTex_TexelSize.y*2.0)*_BlurSize;
            o.uv[4] = v.uv - half2(0.0,_MainTex_TexelSize.y*2.0)*_BlurSize;
            return o;
        }

        v2f vertBlurHorizontal(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv;
            o.uv[1] = v.uv + half2(_MainTex_TexelSize.x*1.0,0.0)*_BlurSize;
            o.uv[2] = v.uv - half2(_MainTex_TexelSize.x*1.0,0.0)*_BlurSize;
            o.uv[3] = v.uv + half2(_MainTex_TexelSize.x*2.0,0.0)*_BlurSize;
            o.uv[4] = v.uv - half2(_MainTex_TexelSize.x*2.0,0.0)*_BlurSize;
            return o;                
        }

        sampler2D _MainTex;

        fixed4 fragBlur(v2f i) : SV_Target
        {
            float weight[3] = {0.4026,0.2442,0.0545};

            fixed3 sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];
            for(int it = 1;it<3;it++){
                sum+=tex2D(_MainTex,i.uv[it]).rgb * weight[it];
                sum+=tex2D(_MainTex,i.uv[it*2]).rgb * weight[it];
            }
            //sum+=tex2D(_MainTex,i.uv[1]).rgb * weight[1];
            //sum+=tex2D(_MainTex,i.uv[2]).rgb * weight[1];
            //sum+=tex2D(_MainTex,i.uv[3]).rgb * weight[2];
            //sum+=tex2D(_MainTex,i.uv[4]).rgb * weight[2];
               
            return fixed4(sum,1.0);
        }
        ENDCG

        Pass
        {
            Name "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG
        }
        Pass
        {
            Name "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            ENDCG
        }
    }

    FallBack Off
}
