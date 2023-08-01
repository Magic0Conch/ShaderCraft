Shader "Hidden/CityShader/EdgeMask"
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
                fixed4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;
                o.uv.zw = o.uv.xy - fixed2(.5f,.5f);
                return o;
            }

            half _EdgeExponent;

            fixed4 frag (v2f i) : SV_Target
            {
             //   fixed2 uv = i.uv;
             //   half edgeMask = 1.0f - uv.x * (1.0f - uv.x) * uv.y * (1.0f - uv.y) * 8.0f;
	            //edgeMask = pow(edgeMask,_EdgeExponent);	            
             //   edgeMask = saturate(edgeMask);
             //   return 1-edgeMask;
                float vignetteIndensity = saturate(1.0-dot(i.uv.zw,i.uv.zw)*_EdgeExponent);
                return vignetteIndensity;
            }
            ENDCG
        }
    }
}
