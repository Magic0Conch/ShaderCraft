using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeamTransitionEffectWaveJitter : PostEffectBase
{
    [Range(0f, 30f)]
    public float strength=1.0f;
    [Range(0f, 1f)]
    public float speed = 0.2f;
    [Range(0f, 50.0f)]
    public float rgbSplit = 37.0f;

    [Range(0f, 1f)]
    public float emitCenterUVX = 0.2f;

    [Range(0f, 1f)]
    public float effectOutterWidth = 0.2f;
    [Range(0f, 1f)]
    public float effectInnerWidth = 0.06f;

    [Range(1,3840)]
    public int resolutionWitdh = 1920;
    [Range(1,2160)]
    public int resolutionHeight = 1080;

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
            material.SetFloat("_Strength", strength);
            material.SetFloat("_Speed", speed);
            material.SetFloat("_RGBSplit", rgbSplit);

            material.SetFloat("_EmitCenterUVX", emitCenterUVX);
            material.SetFloat("_EffectOutterWidth", effectOutterWidth);
            material.SetFloat("_EffectInnerWidth", effectInnerWidth);
            material.SetVector("_Resolution", new Vector2(resolutionWitdh,resolutionHeight));
            Graphics.Blit(source, destination,material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
