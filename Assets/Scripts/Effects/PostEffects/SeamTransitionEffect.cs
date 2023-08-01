using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeamTransitionEffect : PostEffectBase
{
    [Range(0f, 1f)]
    public float scanLineJitterX;
    [Range(0f, 1.01f)]
    public float scanLineJitterY;

    [Range(0f, 1f)]
    public float triggerUVX;

    [Range(0f, 1f)]
    public float triggerWidth;

    [Range (1f, 8f)]
    public float downSample;
    [Range(0, 32)]
    public int iterations = 3;
    [Range(0.2f, 10.0f)]
    public float blurSpeed = 0.6f;

  
    public bool isVertical = false;

    public Shader shader;

    private Material _material;

    

    private Material material
    {
        get { return _material = CheckShaderAndCreateMaterial(shader, _material); }
    }

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            int rtW = (int)(source.width / downSample);
            int rtH = (int)(source.height / downSample);
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0);
            for (int i = 0; i < iterations; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpeed);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

            }

            material.SetVector("_ScanLineJitter", new Vector2(scanLineJitterX,scanLineJitterY));
            material.SetFloat("_TriggerUVX", triggerUVX);
            material.SetFloat("_TriggerWidth", triggerWidth);
            material.SetFloat("_IsVertical", isVertical?1:0);
          
            Graphics.Blit(buffer0, destination, material);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
