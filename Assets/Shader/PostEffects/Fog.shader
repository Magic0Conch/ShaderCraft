Shader "Hidden/Sh_Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_CameraDepthTexture ("Depth Texture", 2D) = "white" {}
        _FogDensity("Fog Density",FLOAT) = 1.0
        _FogColor("Fog COLOR",COLOR) = (0,1,0,1)
        
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float _FogDensity;
            fixed4 _FogColor;
            float4x4 INV_P_MATRIX;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed depthNDC = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float4 H = float4(i.uv.x*2-1,i.uv.y*2-1,depthNDC*2-1,1);
                float4 D = mul(INV_P_MATRIX,H);
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed f = exp(-_FogDensity*LinearEyeDepth(depthNDC));
                col.rgb = col*f + (1-f)*_FogColor;
                
                return col;
            }
            ENDCG
        }
    }
}
