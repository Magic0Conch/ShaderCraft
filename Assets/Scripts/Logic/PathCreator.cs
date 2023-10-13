using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

[RequireComponent(typeof(Camera))]
public class PathCreator: MonoBehaviour
{
    public Vector3 pathPlaneNormal = Vector3.up;
    public Vector3 pathPlaneOriginPoint = Vector3.zero;
    public int pathPlaneScale = 1000;
    public bool isPathPlaneVisible = true;
    public bool isEnabled = false;
    public Shader pathShader;
    public float pathWidth;

    private Camera camera;
    private GameObject pathPlaneObject;
    private List<GameObject> pathPoints = new List<GameObject>();
    private GameObject pathCreatorContainer;
    // Start is called before the first frame update
    void Start()
    {
        camera = GetComponent<Camera>();
        pathPlaneObject = GameObject.CreatePrimitive(PrimitiveType.Plane);
        pathPlaneObject.transform.localScale = Vector3.one* pathPlaneScale;
        pathCreatorContainer = new GameObject();
        pathCreatorContainer.transform.position = Vector3.zero;
        pathPlaneObject.name = "PathCreatorContainer";
        pathPlaneObject.transform.SetParent(pathCreatorContainer.transform);
    }

    public void AddPathKeyPoints()
    {
        if (isEnabled&&Input.GetMouseButtonDown(0))
        {
            bool isPointerOverUI = EventSystem.current.IsPointerOverGameObject();
            if(isPointerOverUI) { return; }

            Ray cameraRay = camera.ScreenPointToRay(Input.mousePosition);
            float plane_d = Vector3.Dot(pathPlaneNormal, pathPlaneOriginPoint);
            float rayTime = (plane_d - Vector3.Dot(cameraRay.origin, pathPlaneNormal)) / (Vector3.Dot(cameraRay.direction, pathPlaneNormal));
            Vector3 intersectPoint = cameraRay.GetPoint(rayTime);
            GameObject go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.transform.position = intersectPoint;
            pathPoints.Add(go);
            go.transform.SetParent(pathCreatorContainer.transform, false);
            //print(intersectPoint);
        }
    }

    public void EndEditPath()
    {
        GameObject pathGameObject = new GameObject();
        List<Vector3> pathKeyPointPositions = new List<Vector3>();
        //foreach(GameObject pathPoint in pathPoints)
        //{
        //    pathKeyPointPositions.Add(pathPoint.transform.position);
        //    Destroy(pathPoint);
        //}
        pathKeyPointPositions.Add(new Vector3(10,0,10));
        pathKeyPointPositions.Add(new Vector3(10,0,-10));
        pathKeyPointPositions.Add(new Vector3(20,0,-10));
        pathPoints.Clear();
        PathRenderer pathRenderer = pathGameObject.AddComponent<PathRenderer>();
        pathGameObject.AddComponent<MeshFilter>();
        pathGameObject.AddComponent<MeshRenderer>();
        pathRenderer.SetParameters(pathKeyPointPositions, pathShader, pathWidth, pathPlaneNormal);
        pathRenderer.GenerateMesh();



    }

    private void Update()
    {
        if(isPathPlaneVisible)
        {
            pathPlaneObject.transform.up = pathPlaneNormal;
            pathPlaneObject.transform.position = pathPlaneOriginPoint;
            pathPlaneObject.SetActive(true);
        }
        else
        {
            pathPlaneObject.SetActive(false);
        }
        AddPathKeyPoints();

    }
}
