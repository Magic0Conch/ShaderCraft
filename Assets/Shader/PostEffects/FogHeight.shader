Shader "Hidden/Sh_FogHeight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_CameraDepthTexture ("Depth Texture", 2D) = "white" {}
        _FogDensity("Fog Density",FLOAT) = 1.0
        _FogColor("Fog COLOR",COLOR) = (0,1,0,1)
        _StartY("Start Y", Float) = 0
		_EndY("End Y", Float) = 10
        
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
            #include "UnityLightingCommon.cginc"

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
                //float4 screenPos = ComputeScreenPos()
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float _FogDensity;
            fixed4 _FogColor;
            float4x4 _INV_VP_MATRIX;
            float _StartY;
			float _EndY;
            float _HeightFallOff;
            float _StartDistance;
            float _Far;
            half _InScatteringExponent;
            fixed3 _InScatteringColor;
            half _MinFogOpacity;

            float _DirectionalInscatteringStartDistance;
            int _DirectionalInscatteringOn;

            float3 getWorldPositionFromDepth(fixed depth,float3 rayDir){
                float linearDepth = LinearEyeDepth(depth);
                return _WorldSpaceCameraPos + linearDepth * rayDir;
            
            }

            float calcLineIntergralShared(float fogHeightFalloff,float rayDirectionY,float rayOriginalTerms){
                //intergrate along the fog (distanceIntersection to receiver)
                float falloff = max(-127.0f,fogHeightFalloff * rayDirectionY);
                float lineIntegeral = (1.0-exp2(-falloff))/falloff;
                //float lineIntegeralTaylor = log(2.0) - (0.5*pow(2,log(2.0))*falloff;
                return rayOriginalTerms*lineIntegeral;
            }



            fixed4 getExponentialHeightFog(float3 worldPositionRelativeToCamera,float excludeDistance){
                const float3 worldObserverOrigin = float3(_WorldSpaceCameraPos.x,min(_WorldSpaceCameraPos.y,_EndY),_WorldSpaceCameraPos.z);
                float3 cameraToReceiver = worldPositionRelativeToCamera;
                cameraToReceiver.y += _WorldSpaceCameraPos.y-_EndY;
                float cameraToReceiverLength = length(cameraToReceiver);
                float excludeIntersectionTime = _StartDistance/cameraToReceiverLength;
                float rayLength = (1.0-excludeIntersectionTime)*cameraToReceiverLength;

                float cameraToExclusionIntersecionY = excludeIntersectionTime  * cameraToReceiver.y;
                float exclusionIntersectionY = cameraToExclusionIntersecionY+worldObserverOrigin.y;
                float exclusionIntersectionToReceiverY = cameraToReceiver.y - cameraToExclusionIntersecionY;

                float exclusionIntersectionToReceiverLengh = (1 - excludeIntersectionTime) * cameraToReceiverLength;
                float rayDirectionY = cameraToReceiver.y-cameraToExclusionIntersecionY;
                
                //cam to startDistanceIntersection 
                float exponent = max(-127.0f,_HeightFallOff*(exclusionIntersectionY-_StartY));
                float rayOriginalTerms = _FogDensity * exp2(-exponent);

                float exponentialHeightLineIntegralShared = calcLineIntergralShared(_HeightFallOff,rayDirectionY,rayOriginalTerms);
                float exponentialHeightLineIntegral = exponentialHeightLineIntegralShared * rayLength;
               

                half expFogFactor = max(saturate(exp2(-exponentialHeightLineIntegral)), _MinFogOpacity);

                //calc directionalInscattering
		        half3 directionalLightInscattering = _LightColor0.rgb * pow(saturate(dot(normalize(cameraToReceiver),_WorldSpaceLightPos0.xyz)), _InScatteringExponent);
		        float directionalInscatteringStartDistance = rayLength;
		        float dirExponentialHeightLineIntegral = exponentialHeightLineIntegralShared * max(rayLength-_DirectionalInscatteringStartDistance,0.0f);
		        half directionalInscatteringFogFactor = saturate(exp2(-dirExponentialHeightLineIntegral));
		        half3 directionalInscattering = directionalLightInscattering * (1 - directionalInscatteringFogFactor);

                //calc finalColor 
                if(!_DirectionalInscatteringOn)
                    directionalInscattering = 0;
                fixed3 fogColor = _FogColor.rgb*(1-expFogFactor) + directionalInscattering;
                return fixed4(fogColor,expFogFactor);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float3 worldPos = getWorldPositionFromDepth(depth,i.interpolatedRay.xyz);
                float linearDepth = LinearEyeDepth(depth);

                float4 fogInscatteringAndOpacity = getExponentialHeightFog(i.interpolatedRay.xyz*linearDepth,0);


                //fixed distanceRatio = saturate((linearDepth-_StartDistance)/_Far);

                //float effectZ = (worldPos.y - _StartY) / (_EndY - _StartY);
                //float falloff = effectZ*_HeightFallOff;
                //float fogFactor = (1-exp2(-falloff))/falloff;
                //fixed fogDensity = exp2(-falloff) * _FogDensity;

                ////fixed f = exp2(-_FogDensity*worldPos.y);
                //half3 frag2sun = normalize(_WorldSpaceLightPos0 - worldPos);
                //half3 eye2sun = normalize(_WorldSpaceCameraPos - worldPos);
                //half inscatterFog = pow(saturate(dot(frag2sun,eye2sun)),_InScatteringExponent);                
                //inscatterFog = inscatterFog*fogFactor;
                //fixed3 inScatterColor =  _InScatteringColor * inscatterFog;
                //fixed3 fogColor = _FogColor.rgb + inScatterColor.rgb;

                //fixed fogCoefficient = fogDensity*fogFactor*distanceRatio;
                

                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = col.rgb*fogInscatteringAndOpacity.a + fogInscatteringAndOpacity.rgb;
                //col.rgb = inscatterFog;
                return col;
            }
            ENDCG
        }

    }
        FallBack Off
}
