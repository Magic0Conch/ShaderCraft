using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Fog : PostEffectBase
{

    public Shader shFog;
    private Material matFog;
    private Camera camera;

    [Range(0f, 0.1f)]
    public float fogDensity = 0.2f;
    public Color fogColor = Color.white;
    public float endY;
    public float startY;
    [Range(0.01f, 1f)]
    public float heightFallOff=1;

    [Range(0f, 1200f)]
    public float startDistance=1200;

    [Range(0.1f, 10f)]
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
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = camera.fieldOfView;
            float aspect = camera.aspect;
            float near = camera.nearClipPlane;


            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            float halfWidth = halfHeight * aspect;
            Vector3 toRight = camera.transform.right * halfHeight * aspect;
            Vector3 toTop = camera.transform.up * halfHeight;


            Vector3 topLeft = camera.transform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = toTop + toRight + camera.transform.forward * near;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = -toRight - toTop + camera.transform.forward * near;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = -toTop + toRight + camera.transform.forward * near;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);

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
            Graphics.Blit(source, destination,matFog);



        }
    }
}
