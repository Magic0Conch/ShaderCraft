Shader "Hidden/CityShader/Composite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            sampler2D _StencilTex;
            sampler2D _BlurTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainTexColor = tex2D(_MainTex, i.uv);
                fixed4 blurColor = tex2D(_BlurTex, i.uv);

                fixed4 fragColor = saturate(mainTexColor + blurColor);
                return fragColor;
            }
            ENDCG
        }
    }
}
