using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderReplaceBase : MonoBehaviour
{

    public Shader shader;    
    protected List<Material> materials = new List<Material>();
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
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

    protected Bounds getBoundsByTransform(Transform trans)
    {
        var meshRenders = trans.GetComponentsInChildren<MeshRenderer>();
        Bounds bounds = new Bounds();
        foreach (var mesh in meshRenders)
        {
            bounds.Encapsulate(mesh.localBounds);
        }
        return bounds;
    }

    protected virtual void replaceMaterials()
    {
        for (int i = 0; i < transform.childCount; i++)
        {
            var child = transform.GetChild(i);
            var meshRenders = child.GetComponentsInChildren<MeshRenderer>();
            Material material = null;
            material = CheckShaderAndCreateMaterial(shader, material);
            materials.Add(material);
            foreach (var mesh in meshRenders)
            {
                mesh.material = material;
                mesh.material = material;
            }
        }
    }

    protected virtual void setupInitialShaderAttribute()
    {
        //do nothing by default
    }

    // Start is called before the first frame update
    protected void Start()
    {
        replaceMaterials();
        setupInitialShaderAttribute();
    }


}
