Shader "CityShader/Sh_Postprocessing_BriSatAndCon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness",float)=1
        _Satutation("Satutation",float)=1
        _Contrast("Contrast",float)=1
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
            half _Brightness;
            half _Satutation;
            half _Contrast;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 renderTex = tex2D(_MainTex, i.uv);
                //Brightness
                fixed3 finalColor = renderTex.rgb * _Brightness;

                //Satutation
                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);
                finalColor = lerp(luminanceColor,finalColor,_Satutation);


                //Contrast
                fixed3 avgColor = fixed3(0.5f,0.5f,0.5f);
                finalColor = lerp(avgColor,finalColor,_Contrast);

                // just invert the colors
                
                return fixed4(finalColor,renderTex.a);
            }
            ENDCG
        //FallBack Off; 
        }
    }
}
