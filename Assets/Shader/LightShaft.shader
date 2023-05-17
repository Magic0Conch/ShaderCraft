Shader "Hidden/LightShaft"
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

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float4 interpolatedRay:TEXCOORD1;
        };
        float4x4 _FrustumCornersRay;
        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;

            int index = 0;
            if(v.uv.x<0.5&&v.uv.y<0.5){
                index = 0;
            }
            else if(v.uv.x>0.5&&v.uv.y<0.5){
                index = 1;
            }
            else if(v.uv.x>0.5&&v.uv.y>0.5){
                index = 2;
            }
            else{
                index = 3;
            }
            o.interpolatedRay = _FrustumCornersRay[index];
            return o;
        }
        
        sampler2D _MainTex;
        sampler2D _CameraDepthTexture;

        float _OcclusionDepthRange;
        fixed3 _BloomTint;
        half _BloomThreshold;
        fixed _BloomMaxBrightness;
        half _BloomScale;
        half _AspectRatio;
        half2 _SunUV;
        int _NumSamples;
        half3 _RadialBlurParameters;

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 textureSpaceBlurOrigin = _SunUV;
                fixed2 uv = i.uv;
                //1:DownsampleLightShaftsPixelMain
                fixed4 fragColor;
                fixed3 sceneColor = tex2D(_MainTex, uv);
                fixed depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float sceneDepth = LinearEyeDepth(depth);
                float edgeMask = 1.0f - uv.x*(1.0f-uv.x)*uv.y*(1.0f-uv.y)*8.0f;
                edgeMask = edgeMask*edgeMask*edgeMask*edgeMask;

                float luminance = max(dot(sceneColor,fixed3(.3f, .59f, .11f)),6.10352e-5);
                float adjustedLuminance = clamp(luminance - _BloomThreshold,0.0f,_BloomMaxBrightness);
                float3 bloomColor = _BloomScale * sceneColor / luminance * adjustedLuminance * 2.0f;

                float invOcclusionDepthRange = 1.0/_OcclusionDepthRange;
                // Only allow bloom from pixels whose depth are in the far half of OcclusionDepthRange
	            float bloomDistanceMask = saturate((sceneDepth - .5f / invOcclusionDepthRange) * invOcclusionDepthRange);
	            // Setup a mask that is 0 at TextureSpaceBlurOrigin and increases to 1 over distance
	            float blurOriginDistanceMask = 1.0f - saturate(length(textureSpaceBlurOrigin - uv) * 2.0f);
	            // Calculate bloom color with masks applied
	            fragColor.rgb = bloomColor * _BloomTint.rgb * bloomDistanceMask * (1.0f - edgeMask) * blurOriginDistanceMask * blurOriginDistanceMask;           
                return fragColor;
            }
            ENDCG
        }

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag (v2f i) : SV_Target
            {
                float3 cameraForward = normalize(UNITY_MATRIX_V[2].xyz);

                float costheta = dot(normalize(_WorldSpaceLightPos0.xyz),cameraForward);


                fixed2 textureSpaceBlurOrigin = _SunUV;
                fixed2 uv = i.uv;
                //2:BlurLightShaftsMain
                float3 blurredValues = 0;
                //half2 aspectCorrectedUV = half2(uv.x*_AspectRatio,uv.y);
                
                // Increase the blur distance exponentially in each pass
	            float passScale = pow(.4f * _NumSamples, _RadialBlurParameters.z);
                
                //TODO: 这里的textureSpaceBlurOrigin没有按照分辨率放缩
	            float2 aspectCorrectedBlurVector = (textureSpaceBlurOrigin - uv)* _RadialBlurParameters.y;
	            float2 blurVector = float2(aspectCorrectedBlurVector.x*_AspectRatio,aspectCorrectedBlurVector.y);
                
                for (int sampleIndex = 0; sampleIndex < _NumSamples; sampleIndex++)
	            {
		            float2 sampleUVs = (uv+ aspectCorrectedBlurVector * sampleIndex / (float)_NumSamples) * fixed2(1,1);
		            // Needed because sometimes the source texture is larger than the part we are reading from
		            float2 clampedUVs = saturate(sampleUVs);
		            float3 sampleValue = tex2D(_MainTex, sampleUVs).xyz;
		            blurredValues += sampleValue;
	            }
                fixed4 fragColor;
                fragColor.a=1;
                fragColor.rgb = blurredValues/(float)_NumSamples;
                //fragColor.rgb =tex2D(_MainTex, uv);
                return fragColor;
            }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            sampler2D _LightShaftColorAndMask;
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 lightShaftColorAndMask = tex2D(_LightShaftColorAndMask,i.uv);
                return col + lightShaftColorAndMask;
            }
            ENDCG
        }
        
    }
}
