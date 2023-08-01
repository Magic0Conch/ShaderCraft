Shader "Unlit/ScanLineJitterGlitch"
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
        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2fBlur
        {
            half2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        struct v2f
        {
            half2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };
        half _TriggerUVX;
        half _TriggerWidth;
        half4 _MainTex_TexelSize;
        float _BlurSize;
        sampler2D _MainTex;

        int _IsVertical;

        v2fBlur vertBlurVertical (appdata v)
        {
            v2fBlur o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv;
            o.uv[1] = v.uv + half2(0.0,_MainTex_TexelSize.y*1.0)*_BlurSize;
            o.uv[2] = v.uv - half2(0.0,_MainTex_TexelSize.y*1.0)*_BlurSize;
            o.uv[3] = v.uv + half2(0.0,_MainTex_TexelSize.y*2.0)*_BlurSize;
            o.uv[4] = v.uv - half2(0.0,_MainTex_TexelSize.y*2.0)*_BlurSize;
            return o;
        }

        v2fBlur vertBlurHorizontal(appdata v)
        {
            v2fBlur o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.uv;
            o.uv[1] = v.uv + half2(_MainTex_TexelSize.x*1.0,0.0)*_BlurSize;
            o.uv[2] = v.uv - half2(_MainTex_TexelSize.x*1.0,0.0)*_BlurSize;
            o.uv[3] = v.uv + half2(_MainTex_TexelSize.x*2.0,0.0)*_BlurSize;
            o.uv[4] = v.uv - half2(_MainTex_TexelSize.x*2.0,0.0)*_BlurSize;
            return o;                
        }

        fixed4 fragBlur(v2fBlur i) : SV_Target
        {
            float weight[3] = {0.4026,0.2442,0.0545};

            fixed3 oriCol = tex2D(_MainTex,i.uv[0]).rgb;
            fixed3 sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];
            sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];
            for(int it = 1;it<3;it++){
                sum+=tex2D(_MainTex,i.uv[it]).rgb * weight[it];
                sum+=tex2D(_MainTex,i.uv[it*2]).rgb * weight[it];
            }
            fixed3 fragColor = lerp(oriCol,sum,smoothstep(_TriggerWidth/2.0f,.0f,abs(i.uv[0].x-_TriggerUVX)));
            return fixed4(fragColor,1.0);
        }        
        ENDCG

        Pass 
        {
            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            ENDCG
        }        
        
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
                float jitter = randomNoise(abs(_IsVertical?i.uv.x:i.uv.y),_Time.x)*2-1;
                jitter*=step(_ScanLineJitter.y,abs(jitter))*_ScanLineJitter.x;
                fixed4 fragColor = tex2D(_MainTex, frac(i.uv + half2(_IsVertical?0:jitter,_IsVertical?jitter:0)));
                return fragColor;
            }
            ENDCG
        }
    }
}