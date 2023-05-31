using System;
using System.Collections;
using System.Collections.Generic;
//using System.Drawing;
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
    [Range(0,1)]
    public float outterWidth;
    public Color outterColor;
    [Range(0,1)]
    public float outterGradientLowerBound;


    public float patternDensity;
    public float patternWidth;
    public Color patternColor;
    public int patternShape;
    public float animSpeed;
    public float pathWidth;
    public float innerRadius;
    public Texture2D mainTex;
    GameObject centerObj;
    List<GameObject> pathNormalPoints;


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
        centerObj = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        centerObj.transform.localScale = Vector3.one*0.1f;

    }

    private bool IsInferiorAngle(Vector3 point0,Vector3 point1,Vector3 point2)
    {
        Vector3 lastToCurrentDirection = (point1 - point0).normalized;
        Vector3 currentToNextDirection = (point2 - point1).normalized;

        bool isInferiorAngle = Vector3.Dot(Vector3.Cross(-lastToCurrentDirection, currentToNextDirection), planeNormal) > 0;
        return isInferiorAngle;
    }

    private bool isLeftSide(Vector3 origin, Vector3 target, Vector3 checkPoint)
    {
        Vector3 direction = target - origin;
        Vector3 checkDirection = checkPoint - origin;
        return Vector3.Dot( Vector3.Cross(checkDirection, direction),planeNormal)>0;
    }



    public void GenerateMesh()
    {
        if(pathKeyPoints.Count < 2) return;
        int vertexCountPerCorner = 2+segment*2;
        int vertexSize = 4 + (pathKeyPoints.Count-2)*vertexCountPerCorner;
        Vector3[] vertices = new Vector3[vertexSize];
        Vector2[] uvs = new Vector2[vertexSize];
        float accumulatePathLength = 0;


        Vector3 normal = Vector3.Cross(planeNormal, pathKeyPoints[1] - pathKeyPoints[0]).normalized;
        bool isInferiorAngle = isLeftSide(pathKeyPoints[0], pathKeyPoints[1], pathKeyPoints[0] + normal * pathWidth);
        normal = isInferiorAngle? normal : -normal;
        vertices[0] = pathKeyPoints[0] + normal * pathWidth;
        vertices[1] = pathKeyPoints[0] - normal * pathWidth;
        uvs[0] = new Vector2(0,0);
        uvs[1] = new Vector2(1,0);
        for (int i = 1; i < pathKeyPoints.Count - 1; i++)
        {
            
            //accumulatePathLength += Vector3.Distance(pathKeyPoints[i], pathKeyPoints[i - 1]);
            Vector3 lastToCurrentDirection = (pathKeyPoints[i] - pathKeyPoints[i - 1]).normalized;
            Vector3 currentToNextDirection = (pathKeyPoints[i + 1] - pathKeyPoints[i]).normalized;

            isInferiorAngle = IsInferiorAngle(pathKeyPoints[i-1], pathKeyPoints[i], pathKeyPoints[i+1]);
            

            Vector3 normalBeforeInner = isInferiorAngle? -Vector3.Cross(planeNormal, lastToCurrentDirection).normalized: Vector3.Cross(planeNormal, lastToCurrentDirection).normalized;
            Vector3 normalBeforeOutter = isInferiorAngle? Vector3.Cross(planeNormal, lastToCurrentDirection).normalized: -Vector3.Cross(planeNormal, lastToCurrentDirection).normalized;
            Vector3 normalAfterInner = isInferiorAngle? -Vector3.Cross(planeNormal, currentToNextDirection).normalized: Vector3.Cross(planeNormal, currentToNextDirection).normalized;
            Vector3 normalAfterOutter = isInferiorAngle? Vector3.Cross(planeNormal, currentToNextDirection).normalized: -Vector3.Cross(planeNormal, currentToNextDirection).normalized;

            Vector3 innerBeforePoint = pathKeyPoints[i] + normalBeforeInner * pathWidth;
            Vector3 innerAfterPoint = pathKeyPoints[i] + normalAfterInner * pathWidth;
            
            //ray1:innerBeforePoint - lastToCurrentDirection*t1;ray2: innerAfterPoint + currentToNextDirection*t2; 
            Vector3 crossProductd1d2 = Vector3.Cross(-lastToCurrentDirection, currentToNextDirection);
            float t1 = Vector3.Dot(Vector3.Cross(innerAfterPoint - innerBeforePoint, currentToNextDirection), crossProductd1d2) / (crossProductd1d2.magnitude * crossProductd1d2.magnitude);

            Vector3 innerIntersection = innerBeforePoint - lastToCurrentDirection * t1;
            Vector3 h = ((-lastToCurrentDirection + currentToNextDirection)/2).normalized;
            float theta = Mathf.Acos(Vector3.Dot(-lastToCurrentDirection,currentToNextDirection));
            Vector3 cornerCenter = innerIntersection + h * innerRadius / Mathf.Sin(theta/2);
            float cornerAngle = Mathf.PI - theta;


            Quaternion q = Quaternion.Euler(0, (isInferiorAngle?1:-1) * Mathf.Rad2Deg * cornerAngle / 2, 0); 
            //Matrix4x4 rotateMatrix = Matrix4x4.Rotate(q);
            Vector3 leftBorderRadialDirection = q*-h;
            centerObj.transform.position = cornerCenter;
            Debug.DrawRay(cornerCenter, leftBorderRadialDirection,Color.red);
            for(int j = 0; j <= segment; j++)
            {
                q = Quaternion.Euler(0, (isInferiorAngle ? -1 : 1) * Mathf.Rad2Deg * cornerAngle / segment * j, 0);
                //q = Quaternion.AngleAxis(-cornerAngle/segment*j, planeNormal);
                //rotateMatrix = Matrix4x4.Rotate(q);
                Vector3 currentRadialDirection = q * leftBorderRadialDirection;
                Debug.DrawRay(cornerCenter, currentRadialDirection, Color.blue);
                Vector3 innerPoint = cornerCenter + currentRadialDirection * innerRadius;
                Vector3 outterPoint = cornerCenter + currentRadialDirection * (innerRadius + pathWidth * 2);

                int vertexIndex = (i - 1) * vertexCountPerCorner + 2 + 2 * j;

                vertices[vertexIndex] = isInferiorAngle?innerPoint:outterPoint;
                vertices[vertexIndex+1] = isInferiorAngle?outterPoint:innerPoint;
                
                accumulatePathLength += Vector3.Distance(vertices[vertexIndex+1], vertices[vertexIndex-1])*0.5f+ Vector3.Distance(vertices[vertexIndex], vertices[vertexIndex - 2])*0.5f;
                
                uvs[vertexIndex] = new Vector2(0, accumulatePathLength);
                uvs[vertexIndex+1] = new Vector2(1,accumulatePathLength);
            }
            ////剪掉多加的一段
            //accumulatePathLength -= (innerRadius + pathWidth) * cornerAngle / segment;
        }
        normal = Vector3.Cross(planeNormal, pathKeyPoints[pathKeyPoints.Count - 1] - pathKeyPoints[pathKeyPoints.Count - 2]).normalized;
        isInferiorAngle = isLeftSide(pathKeyPoints[pathKeyPoints.Count - 2], pathKeyPoints[pathKeyPoints.Count - 1], pathKeyPoints[pathKeyPoints.Count - 1] + normal * pathWidth);
        normal = isInferiorAngle? normal : -normal;

        vertices[(pathKeyPoints.Count - 2) * vertexCountPerCorner + 2] = pathKeyPoints[pathKeyPoints.Count - 1] + normal * pathWidth;
        vertices[(pathKeyPoints.Count - 2) * vertexCountPerCorner + 3] = pathKeyPoints[pathKeyPoints.Count - 1] - normal * pathWidth;
        
        accumulatePathLength += Vector3.Distance(vertices[vertexSize - 1], vertices[vertexSize - 3]) * 0.5f + Vector3.Distance(vertices[vertexSize - 2], vertices[vertexSize - 4])*0.5f;
        uvs[(pathKeyPoints.Count - 2) * vertexCountPerCorner + 2] = new Vector2(0, accumulatePathLength);
        uvs[(pathKeyPoints.Count - 2) * vertexCountPerCorner + 3] = new Vector2(1, accumulatePathLength);

        //路径上的2个 + 拐弯处的segment
        int trianglesCountPerCycle = (2 + segment*2);
        //总三角形数需要加上开头的2个
        int trianglesCountTotal = 2 + trianglesCountPerCycle*(pathKeyPoints.Count-2);
        int[] triangles = new int[trianglesCountTotal*3];
        int curIndex = 0;
        for (int i = 0; i < trianglesCountTotal/2; i++)
        {
            triangles[i * 6] = curIndex;
            triangles[i * 6 + 1] = curIndex + 1;
            triangles[i * 6 + 2] = curIndex + 3;
            triangles[i * 6 + 3] = curIndex;
            triangles[i * 6 + 4] = curIndex + 2;
            triangles[i * 6 + 5] = curIndex + 3;
            curIndex += 2;
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
        material.SetColor("_OutterColor",outterColor);
        material.SetFloat("_OutterGradientLowerBound",outterGradientLowerBound);
        material.SetTexture("_MainTex", mainTex);
    }
}
