using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AreaOutline : MonoBehaviour
{
    private Cylinder cylinder;
    private Circle circle;
    [Range(0.0f,20.0f)]
    public float radius;

    [Range(0.0f,20.0f)]
    public float height;




    public Color wallTintColor;
    

    [Range(0.0f,10.0f)]
    public float wallTextureDensity;

    [Range(-10.0f,10.0f)]
    public float wallAnimSpeed;

    [Range(0.0f,1.0f)]
    public float wallPatternWidth;


    public Color wallPatternColor;

    [Range(0.0f,20.0f)]
    public float wallFlashFrequency;
    [Range(0,2)]
    public int wallBackStyle;
    [Range(0,5)]
    public int wallPatternShape;

    [Range(0.0f,1.0f)]
    public float wallOutterWidth;

    [Range(0.0f,1.0f)]
    public float bottomOutterWidth;

    public Color bottomOutterTintColor;
    public Color bottomInnerTintColor;

    public bool wallFade;


    [Range(0.0f, 1.0f)]
    public float bottomInnerAlphaScale;

    [Range(0.0f,20.0f)]
    public float bottomFlashFrequency;
    [Range(-10.0f,10.0f)]
    public float bottomAnimSpeed;
    [Range(0,10.0f)]
    public float bottomPatternDensity;

    [Range(0.0f,1.0f)]
    public float bottomPatternWidth;

    public Color bottomPatternColor;

    [Range(0,7)]
    public int bottomPatternShape;

    private void Awake()
    {
        cylinder = GetComponentInChildren<Cylinder>();
        circle = GetComponentInChildren<Circle>();

    }


    private void Update()
    {

        cylinder.Radius = radius;
        cylinder.Height = height;
        cylinder.MainTint = wallTintColor;
        cylinder.AnimSpeed = wallAnimSpeed;
        cylinder.PatternDensity = wallTextureDensity;
        cylinder.PatternWidth = wallPatternWidth;
        cylinder.PatternColor = wallPatternColor;
        cylinder.PatternShape = wallPatternShape;
        cylinder.FlashFrequency = wallFlashFrequency;
        cylinder.Fade = wallFade ? 1.0f : 0.0f;
        cylinder.BackStyle = wallBackStyle;
        cylinder.OutterWidth = wallOutterWidth;

        circle.radius = radius;
        circle.OutlineWidth = bottomOutterWidth;
        circle.OutlineColor = bottomOutterTintColor;
        circle.InnerColor = bottomInnerTintColor;
        circle.InnerAlpha = bottomInnerAlphaScale;
        circle.AnimSpeed = bottomAnimSpeed;
        circle.FlashFrequency = bottomFlashFrequency;
        circle.PatternDensity = bottomPatternDensity;
        circle.PatternWidth = bottomPatternWidth;
        circle.PatternColor = bottomPatternColor;
        circle.PatternShape = bottomPatternShape;
    }




}
