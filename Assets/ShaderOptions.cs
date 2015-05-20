using UnityEngine;
using System.Collections;

public class ShaderOptions : MonoBehaviour {
	
	public Material[] materials;

	public bool useNormals;
	[Range(0.0f, 1.0f)] public float threshold;
	[Range(0.0f, .05f)] public float outlineThickness;
	public Color outlineColor;
	[Range(0.0f, 1.0f)] public float outlineBrightness;
	public bool solidOutline;
	public Color rimColor;
	[Range(.5f,8.0f)] public float rimPower;
	public float specularity;
	[Range(1f, 2f)] public float specularBrightness;

	// Use this for initialization
	void Start () {
		useNormals = (materials [0].GetFloat ("_UseNormal") != 0);
		threshold = materials [0].GetFloat ("_Threshold");
		outlineThickness = materials [0].GetFloat ("_OutlineThickness");
		outlineColor = materials [0].GetColor ("_OutlineColor");
		outlineBrightness = materials [0].GetFloat ("_OutlineBrightness");
		solidOutline = (materials [0].GetFloat ("_SolidOutline") != 0);
		rimColor = materials [0].GetColor ("_RimColor");
		rimPower = materials [0].GetFloat ("_RimPower");
		specularity = materials [0].GetFloat ("_Shininess");
		specularBrightness = materials [0].GetFloat ("_SpecBrightness");
	}
	
	// Update is called once per frame
	void Update () {
		foreach(Material mat in materials)
		{
			mat.SetFloat("_UseNormal", useNormals ? 1 : 0);
			mat.SetFloat("_Threshold", threshold);
			mat.SetFloat("_OutlineThickness", outlineThickness);
			mat.SetColor("_OutlineColor", outlineColor);
			mat.SetFloat("_OutlineBrightness", outlineBrightness);
			mat.SetFloat("_SolidOutline", solidOutline ? 1 : 0);
			mat.SetColor("_RimColor", rimColor);
			mat.SetFloat("_RimPower", rimPower);
			mat.SetFloat("_Shininess", specularity);
			mat.SetFloat("_SpecBrightness", specularBrightness);
		}
	}
}



