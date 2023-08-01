using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureSurfaceShaderReplace :ShaderReplaceBase
{
    public Texture surfaceTexture;


    protected override void setupInitialShaderAttribute()
    {
        for (int i = 0; i < transform.childCount; i++)
        {
            var child = transform.GetChild(i);
            Bounds bounds = getBoundsByTransform(child);
            materials[i].SetFloat("_YMax", bounds.max.y);
            materials[i].SetFloat("_YMin", bounds.min.y);
            materials[i].SetTexture("_MainTex", surfaceTexture);
        }
    }


    

    // Update is called once per frame
    void Update()
    {
        
    }
}
