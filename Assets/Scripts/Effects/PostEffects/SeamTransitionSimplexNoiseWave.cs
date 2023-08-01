using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeamTransitionSimplexNoiseWave : PostEffectBase
{
    [Header("PublicProperty")]
    [Range(0f, 1f)]
    public float emitCenterUVX = 0.2f;

    [Range(0f, 1f)]
    public float effectOutterWidth = 0.2f;
    [Range(0f, 1f)]
    public float effectInnerWidth = 0.06f;

    [Header("WaveProperty")]
    public Color waveColor = Color.red;
    [Range (0f, 5f)]
    public float amplitude = .5f;
    [Range (0f, 200f)]
    public float frequency = 70.0f;
    [Range (0f, 3f)]
    public float waveWidth = .2f;
    [Range (0f, 10f)]
    public float waveSpeed = 1f;

    [Header("GaussianBlur")]
    [Range (1f, 8f)]
    public float downSample;
    [Range(0, 32)]
    public int iterations = 3;
    [Range(0.2f, 10.0f)]
    public float blurSpeed = 0.6f;

  
    

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

            material.SetFloat("_EmitCenterUVX", emitCenterUVX);
            material.SetFloat("_EffectOutterWidth", effectOutterWidth);
            material.SetFloat("_EffectInnerWidth", effectInnerWidth);
            material.SetTexture("_OriginalTexture",source);

            //wave property
            material.SetColor("_WaveColor",waveColor);
            material.SetFloat("_Amplitude", amplitude);
            material.SetFloat("_Frequency", frequency);
            material.SetFloat("_WaveWidth", waveWidth);
            material.SetFloat("_WaveSpeed", waveSpeed);
            
            Graphics.Blit(buffer0, destination, material);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
