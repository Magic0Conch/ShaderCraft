using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
public class ColorTintSurfaceShaderReplace : ShaderReplaceBase
{

    public Color mainTint;
    [Range(0.0f, 5.0f)]
    public float animSpeed;

    [Range(1.0f,5.0f)]
    public float brightScale;    
    protected override void setupInitialShaderAttribute()
    {
        for(int i = 0; i < transform.childCount; i++)
        {   
            var child = transform.GetChild(i);
            Bounds bounds = getBoundsByTransform(child);
            materials[i].SetFloat("_YMax", bounds.max.y);
            materials[i].SetFloat("_YMin", bounds.min.y);
        }
    }

    protected void Update()
    {
        foreach (var material in materials)
        {
            material.SetColor("_AdditiveTint",mainTint);
            material.SetFloat("_AnimSpeed", animSpeed);
            material.SetFloat("_BrightScale", brightScale);
        }
    }
}
