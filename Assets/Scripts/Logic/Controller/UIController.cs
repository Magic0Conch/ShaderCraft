using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIController : MonoBehaviour
{
    public Button pathButton;
    private bool isEdittingPath = false;
    public PathCreator pathCreator;
    private void Start()
    {
        pathCreator.isEnabled = false;
    }
    public void startEditPath()
    {
        TextMeshProUGUI buttonText = pathButton.GetComponentInChildren<TextMeshProUGUI>();
        if(isEdittingPath)
        {
            buttonText.text = "Edit Path";
            pathCreator.isEnabled = false;
            pathCreator.EndEditPath();
            
        }
        else
        {
            buttonText.text = "End Edit";
            pathCreator.isEnabled = true;
        }
        isEdittingPath = !isEdittingPath;
    }


}
