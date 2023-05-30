Shader "Unlit/RotateShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Angle("Angle",float)=0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Angle;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float angle = _Angle; 
                float2x2 rotationMatrix = float2x2(cos(radians(angle)), sin(radians(angle)),
                                                   -sin(radians(angle)), cos(radians(angle)));
                float2 rotate_uv = mul(rotationMatrix,float2(i.uv.x,i.uv.y));
                float2 uv = frac(float2(i.uv.x,i.uv.y+angle));
                fixed4 col = tex2D(_MainTex, uv.yx);

                return col;
            }
            ENDCG
        }
    }
}
