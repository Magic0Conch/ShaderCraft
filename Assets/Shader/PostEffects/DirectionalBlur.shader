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
        #include "../StdLib.hlsl"
        sampler2D _MainTex;
        sampler2D _EdgeMaskTexture;
        half _Iterations;
        half2 _Direction;
        fixed4 _BlurColor;
        half _BrightnessMagnification;
        half _VerticalOffset = 0.0f;

        half _EdgeExponent;
        
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
                half4 fragColor = half4(.0,.0,.0,.0);
                fixed4 texCol = tex2D(_MainTex,i.uv);
                //if(dot(texCol.rgb,fixed3(.3f, .59f, .11f))>0.2f){
                //    fragColor = texCol;
                //}
                //else{
                fixed mask = tex2D(_EdgeMaskTexture,i.uv).r;
                for(int k = 0.0f;k<_Iterations;k++){
                    half2 sampleUVs = i.uv - _Direction*k + half2(0.0f,_VerticalOffset);
                    fragColor+=tex2Dlod(_MainTex,half4(sampleUVs.xy,.0f,.0f));
                }
                fragColor/=(_Iterations);
                //}
                float luminance = calculateBrightness(fragColor.rgb);
                fragColor = saturate(luminance * _BlurColor*_BrightnessMagnification*mask);
                return fragColor;
            }

            ENDCG
        }
    }
}
