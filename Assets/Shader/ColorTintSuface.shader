Shader "Unlit/ColorTintSuface"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_AdditiveTint("Additive Tint",COLOR)=(0,0,0.5,0.5)
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha
            Blend OneMinusDstColor One
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
                float4 worldPos: POSITION1;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _AdditiveTint;
            half _YMax;
            half _YMin;
            half _AnimSpeed;
            half _BrightScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                half brightestHeightRatio = frac(_Time.y*_AnimSpeed);
                half brightestHeight = (_YMax-_YMin)*brightestHeightRatio+_YMin;
                half fragY = i.worldPos.y;
                half frag2brightestHeightDistance = fragY>brightestHeight?min(fragY-brightestHeight,brightestHeight-_YMin+_YMax-fragY):min(brightestHeight-fragY,fragY-_YMin+_YMax-brightestHeight);
                half brightness = (1-frag2brightestHeightDistance/(_YMax-_YMin)+1)/2*_BrightScale;
                //brightness = frag2brightestHeightDistance>20?1:brightness;

                col=fixed4(_AdditiveTint.rgb*brightness,_AdditiveTint.a);
                return col;
            }
            ENDCG
        }
    }
}
