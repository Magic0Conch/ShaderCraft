using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
public class ColorTintSurfaceShaderReplace : MonoBehaviour
{

    public Shader shader;
    public Color mainTint;
    [Range(0.0f, 5.0f)]
    public float animSpeed;

    [Range(1.0f,5.0f)]
    public float brightScale;

    private List<Material> materials = new List<Material>();
    Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
            return null;
        }
        if (shader.isSupported && material && material.shader == shader)
        {
            return material;
        }
        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        for(int i = 0; i < transform.childCount; i++) 
        {
            var child = transform.GetChild(i);
            var meshRenders = child.GetComponentsInChildren<MeshRenderer>();
            Bounds bounds = new Bounds();
            foreach (var mesh in meshRenders)
            {
                bounds.Encapsulate(mesh.localBounds);
            }
            if(child.name == "testbuilding")
            {
                print(bounds.min+":"+bounds.max);
            }
            Material material = null;
            material = CheckShaderAndCreateMaterial(shader, material);
            material.SetFloat("_YMax", bounds.max.y);
            material.SetFloat("_YMin", bounds.min.y);
            materials.Add(material);
            foreach (var mesh in meshRenders)
            {
                mesh.material=material;
                mesh.material=material;
            }
        }
    }

    private void Update()
    {
        foreach (var material in materials)
        {
            material.SetColor("_AdditiveTint",mainTint);
            material.SetFloat("_AnimSpeed", animSpeed);
            material.SetFloat("_BrightScale", brightScale);
        }
    }
}
