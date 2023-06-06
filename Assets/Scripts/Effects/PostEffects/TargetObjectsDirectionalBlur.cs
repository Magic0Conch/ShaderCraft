using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using static Unity.VisualScripting.Member;

public class TargetObjectsDirectionalBlur : PostEffectBase
{


    [SerializeField]
    RawImage rawImage;
    public Camera refCam;
    
    private Camera shaderCamera;
    [SerializeField]
    private RenderTexture stencilBuffer = null;

    [Range(0.0f, 6.0f)]
    public float angle;

    [Range(0.0f, 5.0f)]
    public float blurRadius;

    [Range(1, 30)]
    public int iterations=15;
    [Range(1, 10)]
    public int blurTimes=2;

    [Range(1.0f, 10.0f)]
    public float downSample;
    public int stencilZBufferDepth = 0;
    public Shader blurShader;

    public Color blurColor;
    
    [Range(0.0f,10.0f)]
    public float brightnessMagnification;

    private Material _blurMaterial;
    private Material blurMaterial
    {
        get { return _blurMaterial = CheckShaderAndCreateMaterial(blurShader, _blurMaterial); }
    }

    #region compisitingShader
    private static Shader _compShader;
    private static Shader compShader
    {
        get
        {
            if (_compShader == null)
            {
                _compShader = Shader.Find("Hidden/CityShader/Composite");
            }
            return _compShader;
        }
    }
    // Compositing Material
    private static Material _compMaterial = null;
    private static Material compMaterial
    {
        get
        {
            if (_compMaterial == null)
            {
                _compMaterial = new Material(compShader);
                _compMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return _compMaterial;
        }
    }
    #endregion
    
    private GameObject shaderCameraGO = null;
    
    void ResetStencilBufferAndSetTarget()
    {
        if (stencilBuffer != null)
        {
            RenderTexture.ReleaseTemporary(stencilBuffer);
            stencilBuffer = null;
        }
        stencilBuffer = RenderTexture.GetTemporary((int)GetComponent<Camera>().pixelWidth, (int)GetComponent<Camera>().pixelHeight, stencilZBufferDepth, RenderTextureFormat.ARGB32);

        shaderCamera.targetTexture = stencilBuffer;
        if (rawImage != null)
        {
            rawImage.texture = stencilBuffer;
        }
    }

    void Start()
    {
        //shaderCamera = GetComponent<Camera>();
        if (!shaderCameraGO)
        {
            shaderCameraGO = new GameObject("stencilCamera", typeof(Camera));
            shaderCameraGO.GetComponent<Camera>().enabled = false;
            shaderCameraGO.hideFlags = HideFlags.HideAndDontSave;
        }
        if (!shaderCamera)
        {
            shaderCamera = shaderCameraGO.GetComponent<Camera>();
        }

        if (shaderCamera != null)
        {
            shaderCamera.CopyFrom(refCam);
            //shaderCamera.projectionMatrix = refCam.projectionMatrix;		// Uncomment this line if you have problems using Highlighting System with custom projection matrix on your camera
            shaderCamera.cullingMask = 0;
            shaderCamera.cullingMask = (1 << LayerMask.NameToLayer("Building"));
            //shaderCamera.rect = new Rect(0f, 0f, 1f, 1f);
            //shaderCamera.renderingPath = RenderingPath.VertexLit;
            //shaderCamera.allowHDR = false;
            //shaderCamera.useOcclusionCulling = false;
            shaderCamera.backgroundColor = new Color(0f, 0f, 0f, 0f);
            shaderCamera.clearFlags = CameraClearFlags.SolidColor;


            ResetStencilBufferAndSetTarget();
        }
    }

    void OnPreRender()
    {
        shaderCamera.transform.position= refCam.transform.position;
        shaderCamera.transform.rotation= refCam.transform.rotation;
        ResetStencilBufferAndSetTarget();
        shaderCamera.Render();
    }

    void DirectionalBlur(RenderTexture source, RenderTexture destination)
    {
        int rtW = (int)(source.width / downSample);
        int rtH = (int)(source.height / downSample);
        
        float sinVal = (Mathf.Sin(angle) * blurRadius * 0.05f) / iterations;
        float cosVal = (Mathf.Cos(angle) * blurRadius * 0.05f) / iterations;
        blurMaterial.SetFloat("_Iterations", iterations);
        blurMaterial.SetVector("_Direction", new Vector2(sinVal, cosVal));
        blurMaterial.SetColor("_BlurColor", blurColor);
        blurMaterial.SetFloat("_BrightnessMagnification", brightnessMagnification);
        
        //pass 0
        RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
        buffer0.filterMode = FilterMode.Bilinear;
        Graphics.Blit(source, buffer0, blurMaterial, 0);

        //pass 1
        RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
        buffer1.filterMode = FilterMode.Bilinear;
        for(int i = 0; i < blurTimes; i++)
        {
            if((i&1)==0)
            {
                //buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
                Graphics.Blit(buffer0, buffer1, blurMaterial, 1);
                //RenderTexture.ReleaseTemporary(buffer0);
            }
            else
            {
                //buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0, source.format);
                //buffer0.filterMode = FilterMode.Bilinear;
                Graphics.Blit(buffer1, buffer0, blurMaterial, 1);
            }
        }

        Graphics.Blit(buffer0, destination, blurMaterial, 1);
        RenderTexture.ReleaseTemporary(buffer1);



        RenderTexture.ReleaseTemporary(buffer0);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (stencilBuffer == null||blurMaterial==null)
        {
            // Simply transfer framebuffer to destination
            Graphics.Blit(source, destination);
            return;
        }
        else
        {
            RenderTexture blurTexture = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);
            DirectionalBlur(stencilBuffer, blurTexture);
            // Compose
            compMaterial.SetTexture("_StencilTex", stencilBuffer);
            compMaterial.SetTexture("_BlurTex", blurTexture);
            Graphics.Blit(source, destination, compMaterial);

            //Graphics.Blit(source, destination, compMaterial);

            // Cleanup
            RenderTexture.ReleaseTemporary(blurTexture);
            if (stencilBuffer != null)
            {
                RenderTexture.ReleaseTemporary(stencilBuffer);
                stencilBuffer = null;
            }

        }

    }
}
