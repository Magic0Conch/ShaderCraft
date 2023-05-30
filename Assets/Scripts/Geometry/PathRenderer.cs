using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathRenderer : GeometryBase
{
    private List<Vector3> pathKeyPoints;
    private MeshFilter meshFilter;
    private Mesh mesh;
    private MeshRenderer meshRenderer;
    private Material material;
    private Shader shader;    
    private Vector3 planeNormal;
    public int segment = 1;

    public Color backColor;
    public float flashFrequency;
    public float outterWidth;
    public float patternDensity;
    public float patternWidth;
    public Color patternColor;
    public int patternShape;
    public float animSpeed;
    public float pathWidth;



    public void SetParameters(List<Vector3> p_pathKeyPoints, Shader p_shader, float p_pathWidth, Vector3 p_planeNormal)
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        mesh = new Mesh();
        meshFilter.mesh = mesh;

        pathKeyPoints = p_pathKeyPoints;
        shader = p_shader;
        pathWidth = p_pathWidth;
        planeNormal = p_planeNormal;

        material = CheckShaderAndCreateMaterial(shader,material);
        meshRenderer.sharedMaterial = material;
    }

    public void GenerateMesh()
    {
        if(pathKeyPoints.Count < 2) return;
        int vertexCountPerCorner = 2+segment+1;
        int vertexSize = 4 + (pathKeyPoints.Count-2)*vertexCountPerCorner;
        Vector3[] vertices = new Vector3[vertexSize];
        Vector2[] uvs = new Vector2[vertexSize];
        float accumulatePathLength = 0;

        Vector3 normal = Vector3.Cross(planeNormal, pathKeyPoints[1] - pathKeyPoints[0]);
        normal.Normalize();
        vertices[0] = pathKeyPoints[0];
        vertices[1] = pathKeyPoints[0] + normal * pathWidth;
        uvs[0] = new Vector2(0,0);
        uvs[1] = new Vector2(1,0);
        for (int i = 1; i < pathKeyPoints.Count - 1; i++)
        {
            accumulatePathLength += Vector3.Distance(pathKeyPoints[i], pathKeyPoints[i - 1]);
            Vector3 normalBefore = Vector3.Cross(planeNormal, pathKeyPoints[i] - pathKeyPoints[i - 1]);
            Vector3 normalAfter = Vector3.Cross(planeNormal, pathKeyPoints[i + 1] - pathKeyPoints[i]);

            normalBefore.Normalize();
            normalAfter.Normalize();

            //pathKeyPoints[i] + normal * pathWidth;
            Vector3 sectorOrigin = pathKeyPoints[i];
            Vector3 sectorBeginPoint = pathKeyPoints[i] + normalBefore * pathWidth;
            Vector3 sectorEndPoint = pathKeyPoints[i] + normalAfter * pathWidth;
            vertices[(i-1) * vertexCountPerCorner + 2] = sectorOrigin;
            uvs[(i-1) * vertexCountPerCorner + 2] = new Vector2(0, accumulatePathLength);

            vertices[(i-1) * vertexCountPerCorner + 3] = sectorBeginPoint;
            uvs[(i - 1) * vertexCountPerCorner + 3] = new Vector2(1, accumulatePathLength);
            float radius = Vector3.Distance(sectorBeginPoint, sectorOrigin);
            for (int j = 1; j <= segment; j++)
            {
                Vector3 targetPoint = Vector3.Lerp(sectorBeginPoint, sectorEndPoint, j*1.0f / segment);
                Vector3 dir = (targetPoint - sectorOrigin).normalized;
                vertices[(i - 1) * vertexCountPerCorner + 3 + j] = sectorOrigin + dir * radius;
                uvs[(i - 1) * vertexCountPerCorner + 3 + j] = new Vector2(1, accumulatePathLength+j*1.0f/segment);
            }
            vertices[(i - 1) * vertexCountPerCorner + 4 + segment] = sectorEndPoint;
            uvs[(i - 1) * vertexCountPerCorner + 4 + segment] = new Vector2(1, accumulatePathLength);
        }
        accumulatePathLength += Vector3.Distance(pathKeyPoints[pathKeyPoints.Count - 1] , pathKeyPoints[pathKeyPoints.Count - 2]);
        normal = Vector3.Cross(planeNormal, pathKeyPoints[pathKeyPoints.Count-1] - pathKeyPoints[pathKeyPoints.Count - 2]);
        normal.Normalize();
        vertices[vertexSize - 2] = pathKeyPoints[pathKeyPoints.Count - 1];
        vertices[vertexSize - 1] = pathKeyPoints[pathKeyPoints.Count - 1] + normal * pathWidth;
        uvs[vertexSize - 2] = new Vector2(0, accumulatePathLength);
        uvs[vertexSize - 1] = new Vector2(1, accumulatePathLength);


        //路径上的2个 + 拐弯处的segment
        int trianglesCountPerCycle = (2 + segment);
        //总三角形数需要加上开头的2个
        int trianglesCountTotal = 2 + trianglesCountPerCycle*(pathKeyPoints.Count-2);
        int[] triangles = new int[trianglesCountTotal*3];

        triangles[0] = 0;
        triangles[1] = 1;
        triangles[2] = 3;
        triangles[3] = 0;
        triangles[4] = 3;
        triangles[5] = 2;
        //从拐弯处开始
        int startIndex = 2;
        for (int i = 0; i < pathKeyPoints.Count - 2; i++)
        {
            for(int j = 0; j < segment; j++)
            {
                triangles[6 + i * trianglesCountPerCycle*3+j*3] = startIndex;
                triangles[6 + i * trianglesCountPerCycle * 3 + j * 3+1] = startIndex+j+1;
                triangles[6 + i * trianglesCountPerCycle * 3 + j * 3+2] = startIndex+j+2;
            }
            triangles[6 + i * trianglesCountPerCycle * 3 + segment * 3] = startIndex;
            triangles[6 + i * trianglesCountPerCycle * 3 + segment * 3 + 1] = startIndex + segment + 2;
            triangles[6 + i * trianglesCountPerCycle * 3 + segment * 3 + 2] = startIndex + segment + 3;

            triangles[6 + i * trianglesCountPerCycle * 3 + (segment + 1) * 3] = startIndex + segment + 2;
            triangles[6 + i * trianglesCountPerCycle * 3 + (segment + 1) * 3 + 1] = startIndex + segment + 4;
            triangles[6 + i * trianglesCountPerCycle * 3 + (segment + 1) * 3 + 2] = startIndex + segment + 3;
            startIndex += 2+segment+1;
        }
        mesh.Clear();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }

    // Update is called once per frame
    void Update()
    {
        GenerateMesh();
        material.SetColor("_BackColor",backColor);
        material.SetFloat("_FlashFrequency",flashFrequency);
        material.SetFloat("_OutterWidth",outterWidth);
        material.SetFloat("_PatternDensity",patternDensity);
        material.SetFloat("_PatternWidth", patternWidth);
        material.SetColor("_PatternColor",patternColor);
        material.SetFloat("_PatternShape",patternShape);
        material.SetFloat("_AnimSpeed",animSpeed);
        material.SetFloat("_PathWidth",pathWidth);
    }
}
