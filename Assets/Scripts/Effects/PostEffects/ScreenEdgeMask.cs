using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using UnityEngine;

public class ScreenEdgeMask : PostEffectBase
{
    public Shader shader;
    private Material matScreenEdgeMask;

    public Color maskColor;
    [Range(0.0f,128.0f)]
    public float edgeExponent = 8.0f;
    public float flashFrequency = 1.0f;
    public Material material
    {
        get { return matScreenEdgeMask = CheckShaderAndCreateMaterial(shader, matScreenEdgeMask); }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetColor("_MaskColor",maskColor);
            material.SetFloat("_EdgeExponent", edgeExponent);
            material.SetFloat("_FlashFrequency", flashFrequency);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
