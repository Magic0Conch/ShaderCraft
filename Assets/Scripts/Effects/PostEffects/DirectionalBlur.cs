using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirectionalBlur : PostEffectBase
{
    [Range(0.0f, 6.0f)]
    public float angle;
    
    [Range(0.0f, 5.0f)]
    public float blurRadius;

    [Range(1,30)]
    public int iterations;

    [Range(1.0f,10.0f)]
    public float downSample;

    public Shader shader;
    private Material _material;
    
    private Material material
    {
        get { return _material = CheckShaderAndCreateMaterial(shader, _material); }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            int rtW = (int)(source.width/downSample);
            int rtH = (int)(source.height/downSample);
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
            buffer0.filterMode = FilterMode.Bilinear;
            //pass 0
            Graphics.Blit(source,buffer0,material,0);
            float sinVal = (Mathf.Sin(angle)*blurRadius*0.05f)/iterations;
            float cosVal = (Mathf.Cos(angle)*blurRadius*0.05f)/iterations;
            material.SetFloat("_Iterations", iterations);
            material.SetVector("_Direction", new Vector2(sinVal, cosVal));
            //pass 1
            Graphics.Blit(buffer0,destination , material, 1);

            RenderTexture.ReleaseTemporary(buffer0);


        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
