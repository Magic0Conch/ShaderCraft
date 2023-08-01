Shader "Hidden/CityShader/WaveJitter"
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
        #include "../XNoiseLibrary.hlsl"
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

        sampler2D _MainTex;
        half _Strength;
        half _Speed;
        half _RGBSplit;
        half _EmitCenterUVX;
        half _EffectOutterWidth;
        half _EffectInnerWidth;
        half2 _Resolution;


        fixed4 wavePattern(half2 uv,half ratio){
            float uv_y = uv.y * _Resolution.y;            
		    float noise_wave_1 = snoise(float2(uv_y * 0.01, _Time.y * _Speed * 20)) * (_Strength * 32.0);
		    float noise_wave_2 = snoise(float2(uv_y * 0.02, _Time.y * _Speed * 10)) * (_Strength * 4.0);
            float noise_wave_x = noise_wave_1 * noise_wave_2/_Resolution.x;
            float uv_x = uv.x + noise_wave_x*ratio;

            float rgbSplit_uv_x = (_RGBSplit*50+(20.0*_Strength+1.0))*noise_wave_x/_Resolution.x;

            half4 colorG = tex2D(_MainTex,float2(uv_x,uv.y));
            half4 colorRB = tex2D(_MainTex,float2(uv_x + rgbSplit_uv_x,uv.y));

            fixed4 fragColor = fixed4(colorRB.r,colorG.g,colorRB.b,colorRB.a+colorG.a);

            return fragColor;
        }

        fixed4 fragHorizontal(v2f i): SV_Target
        {
            half2 uv = i.uv;
            
            fixed4 texColor = tex2D(_MainTex,i.uv);
            fixed waveRatio = smoothstep(_EffectOutterWidth/2.0,_EffectInnerWidth/2.0,abs(uv.x-_EmitCenterUVX));
            fixed4 waveColor = wavePattern(uv,1.); 
            fixed4 fragColor = waveColor;

            return fragColor;
        }


        ENDCG


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragHorizontal

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            ENDCG
        }
    }
}
//float angle = 20; 
//float2x2 rotationMatrix = float2x2(cos(radians(angle)), sin(radians(angle)),
//                                    -sin(radians(angle)), cos(radians(angle)));
//half2 uv = mul(rotationMatrix,float2(i.uv.x,i.uv.y));