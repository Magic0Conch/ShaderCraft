using System;
using UnityEngine;
[ExecuteInEditMode]
public class Circle : GeometryBase
{
    public float radius = 1f;
    public int segments = 32;
    public Shader shCircle;


    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private Mesh mesh;
    private Material matCircle;


    #region UnityMessage

    void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        mesh = new Mesh();
        meshFilter.mesh = mesh;
        matCircle = GetComponent<Material>();
        matCircle = CheckShaderAndCreateMaterial(shCircle, matCircle);
        if (meshRenderer.sharedMaterial != matCircle)
            meshRenderer.sharedMaterial = matCircle;
    }

    private void Update()
    {
        GenerateCircle();
    }

    #endregion
    #region GenerateGeometry
    private void GenerateCircle()
    {
        Vector3[] vertices = new Vector3[segments + 1];
        Vector2[] uvs = new Vector2[segments + 1];
        int[] triangles = new int[segments * 3];
        Vector3 center = Vector3.zero;
        vertices[0] = center;
        float angle = 0f;
        float angleStep = 2f * Mathf.PI / segments;

        // 生成顶点和三角形索引
        for (int i = 1; i <= segments; i++)
        {
            float x = Mathf.Sin(angle) * radius + center.x;
            float y = center.y;
            float z = Mathf.Cos(angle) * radius + center.z;

            vertices[i] = new Vector3(x, y, z);
            uvs[i] = new Vector2(1, 1);
            if (i < segments)
            {
                triangles[(i - 1) * 3] = 0;
                triangles[(i - 1) * 3 + 1] = i;
                triangles[(i - 1) * 3 + 2] = i + 1;
            }
            else
            {
                triangles[(i - 1) * 3] = 0;
                triangles[(i - 1) * 3 + 1] = i;
                triangles[(i - 1) * 3 + 2] = 1;
            }
            angle += angleStep;
        }

        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }
    #endregion

    #region SetupMaterial
    private Material material
    {
        get
        {
            //matCylinder = CheckShaderAndCreateMaterial(shWallLight, matCylinder);
            //if(meshRenderer.material != matCylinder)
            //meshRenderer.material = matCylinder;
            return matCircle;
        }
    }




    public float OutlineWidth
    {
        get { return material.GetFloat("_Outline"); }
        set { material.SetFloat("_Outline", value); }
    }

    public Color OutlineColor
    {
        get { return material.GetColor("_OutlineColor"); }
        set { material.SetColor("_OutlineColor", value); }
    }

    public Color InnerColor
    {
        get { return material.GetColor("_InnerColor"); }
        set { material.SetColor("_InnerColor", value); }
    }

    public float InnerAlpha
    {
        get { return material.GetFloat("_InnerAlpha"); }
        set { material.SetFloat("_InnerAlpha", value); }
    }

    // FlashFrequency
    public float FlashFrequency
    {
        get { return material.GetFloat("_FlashFrequency"); }
        set { material.SetFloat("_FlashFrequency", value); }
    }

    // PatternDensity
    public float PatternDensity
    {
        get { return material.GetFloat("_PatternDensity"); }
        set { material.SetFloat("_PatternDensity", value); }
    }

    // PatternWidth
    public float PatternWidth
    {
        get { return material.GetFloat("_PatternWidth"); }
        set { material.SetFloat("_PatternWidth", value); }
    }

    // PatternColor
    public Color PatternColor
    {
        get { return material.GetColor("_PatternColor"); }
        set { material.SetColor("_PatternColor", value); }
    }

    // PatternShape
    public int PatternShape
    {
        get { return Convert.ToInt32(material.GetFloat("_PatternShape")); }
        set { material.SetFloat("_PatternShape", value); }
    }

    // AnimSpeed
    public float AnimSpeed
    {
        get { return material.GetFloat("_AnimSpeed"); }
        set { material.SetFloat("_AnimSpeed", value); }
    }
    #endregion

}
