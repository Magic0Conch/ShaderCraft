Shader "Hidden/CityShader/ScreenEdgeMask"
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
            fixed4 _MaskColor;
            half _EdgeExponent;
            half _FlashFrequency;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed2 uv = i.uv;
                half edgeMask = 1.0f - uv.x * (1.0f - uv.x) * uv.y * (1.0f - uv.y) * 8.0f;
	            edgeMask = pow(edgeMask,_EdgeExponent);	            
                edgeMask = saturate(edgeMask);
	            // Apply the edge mask to the occlusion factor
                half brightness = sin(_Time.z*_FlashFrequency)+1.0f;
                fixed4 fragColor = col*(1-edgeMask)+fixed4(_MaskColor.rgb*edgeMask*brightness,edgeMask);

                return fragColor;
            }
            ENDCG
        }
    }
}
