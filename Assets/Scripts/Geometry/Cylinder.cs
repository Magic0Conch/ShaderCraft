using System;
using System.Drawing;
using UnityEngine;

[ExecuteInEditMode]
public class Cylinder : GeometryBase
{
    public Shader shWallLight;

    public bool dirtyOn = false;

    public float m_radius = 1.0f;
    public float m_height = 1.0f;


    public int segments = 32;

    private bool isDirty = true;

    private MeshFilter meshFilter;
    private Mesh mesh;
    private MeshRenderer meshRenderer;
    void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        mesh = new Mesh();
        meshFilter.mesh = mesh;
        matCylinder = GetComponent<Material>();
        matCylinder = CheckShaderAndCreateMaterial(shWallLight, matCylinder);
        if (meshRenderer.sharedMaterial != matCylinder)
            meshRenderer.sharedMaterial = matCylinder;
    }

    void Update()
    {
        if (isDirty||!dirtyOn)
        {
            GenerateMesh();
            isDirty = false;
        }
    }
    void GenerateMesh()
    {
        // Generate vertices
        Vector3[] vertices = new Vector3[(segments + 1) * 2];
        Vector2[] uvs = new Vector2[(segments + 1) * 2];
        float angleStep = 2f * Mathf.PI / segments;
        for (int i = 0; i <= segments; i++)
        {
            float angle = i * angleStep;
            float x = Mathf.Cos(angle) * m_radius;
            float z = Mathf.Sin(angle) * m_radius;
            vertices[i] = new Vector3(x, 0f, z);
            float u = (float)i / segments;
            uvs[i] = new Vector2(u,0);
            vertices[i + segments + 1] = new Vector3(x, m_height, z);
            uvs[i + segments + 1] = new Vector2(u, m_height);
        }

        // Generate triangles
        int[] triangles = new int[segments * 6];
        for (int i = 0, ti = 0; i < segments; i++, ti += 6)
        {
            triangles[ti] = i;
            triangles[ti + 1] = i + segments + 1;
            triangles[ti + 2] = i + 1;
            triangles[ti + 3] = i + 1;
            triangles[ti + 4] = i + segments + 1;
            triangles[ti + 5] = i + segments + 2;

            if (i == segments - 1)
            {
                triangles[ti + 2] = 0;
                triangles[ti + 5] = segments + 1;
            }
        }

        // Set mesh data
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }

    #region Material
    private Material matCylinder; 
    private Material material
    {
        get { 
            //matCylinder = CheckShaderAndCreateMaterial(shWallLight, matCylinder);
            //if(meshRenderer.material != matCylinder)
                //meshRenderer.material = matCylinder;
            return matCylinder;
        }
    }


    // Set shader properties

    public UnityEngine.Color MainTint
    {
        get { return material.GetColor("_Color"); }
        set {
            material.color = value;
            material.SetColor("_Color", value); }
    }

    public float AnimSpeed
    {
        get { return material.GetFloat("_AnimSpeed"); }
        set { material.SetFloat("_AnimSpeed", value); }
    }

    public float PatternDensity
    {
        get { return material.GetFloat("_PatternDensity"); }
        set { material.SetFloat("_PatternDensity", value); }
    }

    public float PatternWidth
    {
        get { return material.GetFloat("_PatternWidth"); }
        set { material.SetFloat("_PatternWidth", value); }
    }

    public UnityEngine.Color PatternColor
    {
        get { return material.GetColor("_PatternColor"); }
        set { material.SetColor("_PatternColor", value); }
    }

    public float FlashFrequency
    {
        get { return material.GetFloat("_FlashFrequency"); }
        set { material.SetFloat("_FlashFrequency", value); }
    }

    public float Fade
    {
        get { return material.GetFloat("_Fade"); }
        set { material.SetFloat("_Fade", value); }
    }

    public int BackStyle
    {
        get { return Convert.ToInt32(material.GetFloat("_BackStyle")); }
        set { material.SetFloat("_BackStyle", value); }

    }

    public float OutterWidth
    {
        get { return material.GetFloat("_OutterWidth"); }
        set { material.SetFloat("_OutterWidth", value); }

    }

    public int PatternShape
    {
        get { return Convert.ToInt32(material.GetFloat("_PatternShape")); }
        set { material.SetFloat("_PatternShape", value); }
    }

    public float Radius
    {
        get { return material.GetFloat("_Radius"); }
        set 
        { 
            m_radius = value;
            material.SetFloat("_Radius", value); 
        }
    }

    public float Height
    {
        get { return material.GetFloat("_Height"); }
        set 
        { 
            m_height = value;
            material.SetFloat("_Height", value); 
        }
    }

    #endregion

}
