using System.Collections;
using System.Collections.Generic;
using System.Xml.Serialization;
using UnityEngine;

public class PostEffectWithDepth : PostEffectBase
{
    protected Matrix4x4 getFrustumCorners()
    {
        Camera camera = Camera.main;
        Matrix4x4 frustumCorners = Matrix4x4.identity;

        float fov = camera.fieldOfView;
        float aspect = camera.aspect;
        float near = camera.nearClipPlane;


        float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
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
        return frustumCorners;
    }
}
