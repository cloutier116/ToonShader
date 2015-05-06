Shader "Custom/ToonShader" 
{
	Properties 
	{
		_LitTex ("Lit (RGB)", 2D) = "white" {}
		_UnlitTex ("Unlit (RGB)", 2D) = "white" {}
		_Threshold ("Lit Threshold", Range(0,1)) = 0.1
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_LitThickness ("Lit Outline Thickness", Range(0,1)) = .1
		_UnlitThickness ("Unlit Outline Thickness", Range(0,1)) = .4
	}
	SubShader 
	{
		Pass
		{
	        Tags { "LightMode" = "ForwardBase" } 
			LOD 200
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "UnityCG.cginc"
			uniform float4 _LightColor0;
			uniform sampler2D _UnlitTex;
			uniform sampler2D _LitTex;
			uniform float _LitThickness;
			uniform float _UnlitThickness;
			uniform float4 _OutlineColor;
			
			uniform float _Threshold;
			
			struct vertexInput 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD1;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float2 uv : TEXCOORD0;
				float3 normalDir : NORMAL;
			};
			
			float4 _UnlitTex_ST;
			float4 _LitTex_ST;
			
			vertexOutput vert(appdata_base input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				output.posWorld = mul(modelMatrix, input.vertex);
				output.normalDir = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				output.uv = TRANSFORM_TEX(input.texcoord, _UnlitTex);
				//output.normalDir = 
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float3 normalDirection = normalize(input.normalDir);
				
				float3 viewDirection = normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
				float3 lightDirection;
				float attenuation;
				
				if(_WorldSpaceLightPos0.w == 0.0)
				{
					attenuation = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0/distance;
					lightDirection = normalize(vertexToLightSource);
				}
				
				float4 fragmentColor = tex2D (_UnlitTex, input.uv) * _LightColor0;;
				
				if(attenuation * max(0.0, dot(normalDirection, lightDirection)) >= _Threshold)
				{
					fragmentColor = tex2D(_LitTex, input.uv) * _LightColor0;
				}	
				
				if(dot(viewDirection, normalDirection) < lerp(_UnlitThickness, _LitThickness, max(0.0, dot(normalDirection, lightDirection))))
				{
					fragmentColor = _LightColor0 * _OutlineColor;
				}
				
				return fragmentColor;
				
			}
			ENDCG
		 }
	}
}