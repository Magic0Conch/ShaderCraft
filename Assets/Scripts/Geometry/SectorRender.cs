using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent (typeof(MeshFilter))]
[RequireComponent (typeof(MeshRenderer))]

public class SectorRender : GeometryBase
{
    public float radius = 1f;
    public int segments = 32;
    public bool filled = true;
    public Shader shader;


    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private Mesh mesh;
    private Material material;

    private void GenerateSector()
    {
        Vector3[] vertices = new Vector3[segments + 1];
        Vector2[] uvs = new Vector2[segments + 1];
        int[] triangles = new int[segments * 3];
        Vector3 center = Vector3.zero;
        vertices[0] = center;
        uvs[0] = center;
        float angle = 0f;
        float angleStep = 2f * Mathf.PI / segments;

        // 生成顶点和三角形索引
        float acc = 0;
        for (int i = 1; i <= segments; i++)
        {
            float x = Mathf.Sin(angle) * radius + center.x;
            float y = center.y;
            float z = Mathf.Cos(angle) * radius + center.z;

            vertices[i] = new Vector3(x, y, z);
            uvs[i] = new Vector2(1, acc);
            acc += 4;
            angle += angleStep;
        }
        for(int i = 0; i < segments-1; i++)
        {
            triangles[i * 3] = 0;
            triangles[i * 3 + 1] = i+1;
            triangles[i * 3 + 2] = i+2;
        }
        triangles[(segments - 1)*3] = 0;
        triangles[(segments - 1)*3+1] = segments;
        triangles[(segments - 1)*3+2] = 1;
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }


    // Start is called before the first frame update
    void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        mesh = new Mesh();
        meshFilter.mesh = mesh;
        material = GetComponent<Material>();
        material = CheckShaderAndCreateMaterial(shader, material);
        if (meshRenderer.sharedMaterial != material)
            meshRenderer.sharedMaterial = material;
    }

    // Update is called once per frame
    void Update()
    {
        GenerateSector();
    }


}
