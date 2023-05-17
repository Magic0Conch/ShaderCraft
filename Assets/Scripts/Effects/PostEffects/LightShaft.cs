using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.GlobalIllumination;

public class LightShaft : PostEffectWithDepth
{
    public Shader shLightShaft;
    private Material matLightShaft;

    [Range(0f, 1500f)] 
    public float occlusionDepthRange;

    public Color bloomTint;
    public float bloomMaxBrightness;
    public float bloomScale;
    [Range(0f, 3f)]
    public float bloomThreshold;

    public Light sunLight;

    public int numSamples;
    public Vector3 radialBlurParameters;
    private Camera camera;

    public Material material
    {
        get { return matLightShaft = CheckShaderAndCreateMaterial(shLightShaft, matLightShaft); }
    }
    private void Start()
    {
        camera = Camera.main;
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    private Vector2 getSunUV()
    {
        Vector2 sunUV = Vector2.zero;
        Vector3 lightDir = -Vector3.Normalize(sunLight.transform.forward);
        Vector3 cameraDir = Vector3.Normalize(camera.transform.forward);

        float costheta = Vector3.Dot(lightDir, cameraDir);
        float cameraToNearLightDirLength = camera.nearClipPlane / costheta;
        Vector3 intersectionWorldPosition = camera.transform.position + lightDir * cameraToNearLightDirLength;
        Vector3 viewportPosition = camera.WorldToViewportPoint(intersectionWorldPosition);
        sunUV = new Vector2(viewportPosition.x, viewportPosition.y);
        return sunUV;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            int width = source.width;
            int height = source.height;
            material.SetMatrix("_FrustumCornersRay;",getFrustumCorners());
            material.SetFloat("_OcclusionDepthRange", occlusionDepthRange);
            material.SetColor("_BloomTint", bloomTint);
            material.SetFloat("_BloomThreshold", bloomThreshold);
            material.SetFloat("_BloomMaxBrightness", bloomMaxBrightness);
            material.SetFloat("_BloomScale", bloomScale);
            material.SetFloat("_AspectRatio",Screen.width/Screen.height);

            material.SetVector("_SunUV",getSunUV());


            RenderTexture buffer0 = RenderTexture.GetTemporary(width, height, 0);
            RenderTexture buffer1 = RenderTexture.GetTemporary(width, height, 0);
            Graphics.Blit(source, buffer0, material,0); //AddDownsamplePass 
            material.SetInt("_NumSamples",numSamples);
            material.SetVector("_RadialBlurParameters", radialBlurParameters);
            Graphics.Blit(buffer0, buffer1, material,1);//AddTemporalAAPass
            RenderTexture.ReleaseTemporary(buffer0);
            Graphics.Blit(buffer1, buffer0, material, 2);//AddRadialBlurPass
            RenderTexture.ReleaseTemporary(buffer1);

            material.SetTexture("_LightShaftColorAndMask",buffer0);
            Graphics.Blit(source, destination, material, 3);//AddOcclusionTermPass
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
