using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.GlobalIllumination;

[RequireComponent(typeof(Camera))]
public class Fog : PostEffectWithDepth
{

    public Shader shFog;
    private Material matFog;
    private Camera camera;

    [Range(0f, 0.1f)]
    public float fogDensity = 0.2f;
    public Color fogColor = Color.white;
    public float endY;
    public float startY;

    public bool directionalInscatteringOn;

    [Range(0.01f, 1f)]
    public float heightFallOff=1;

    [Range(0f, 1200f)]
    public float startDistance=1200;
    [Range(0f, 1200f)]
    public float directionalInscatteringStartDistance = 1200;

    [Range(0.001f, 10f)]
    public float inScatteringExponent;

    public float minFogOpacity;
    public Color inScatteringColor;
    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        camera = GetComponent<Camera>();
        
    }

    public Material material
    {
        get { return matFog = CheckShaderAndCreateMaterial(shFog, matFog); }
    }


    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {

        if(material == null)
        {
            Graphics.Blit(source, destination);
        }
        else
        {

            material.SetMatrix("_FrustumCornersRay", getFrustumCorners());

            Matrix4x4 vpMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            material.SetMatrix("_INV_VP_MATRIX", vpMatrix.inverse);
            material.SetFloat("_StartY",startY);
            material.SetFloat("_EndY", endY);
            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_HeightFallOff", heightFallOff);
            material.SetFloat("_StartDistance", startDistance);
            material.SetFloat("_Far", camera.farClipPlane);
            material.SetFloat("_InScatteringExponent", inScatteringExponent);
            material.SetColor("_InScatteringColor", inScatteringColor);
            material.SetFloat("_MinFogOpacity", minFogOpacity);
            material.SetFloat("_DirectionalInscatteringStartDistance",directionalInscatteringStartDistance);
            material.SetInt("_DirectionalInscatteringOn", Convert.ToInt16(directionalInscatteringOn));
            Graphics.Blit(source, destination,matFog);



        }
    }
}
