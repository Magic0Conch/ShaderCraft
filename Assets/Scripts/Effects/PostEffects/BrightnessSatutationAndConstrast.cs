using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSatutationAndConstrast : PostEffectBase
{
    public Shader shBrightnessSaturationAndContrast;
    private Material matBrightnessSaturationAndContrast;

    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    public Material material
    {
        get { return matBrightnessSaturationAndContrast = CheckShaderAndCreateMaterial(shBrightnessSaturationAndContrast,matBrightnessSaturationAndContrast); }        
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Satutation", saturation);
            material.SetFloat("_Contrast", contrast);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
