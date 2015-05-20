

Shader "Custom/Toon Shader" 
{
	Properties 
	{
		_LitTex ("Lit (RGB)", 2D) = "white" {}
		_UnlitTex ("Unlit (RGB)", 2D) = "white" {}
		_NormalTex ("Normal (RGB)", 2D) = "white" {}
		[MaterialToggle] _UseNormal("Use Normal", Float) = 0
		_Threshold ("Lit Threshold", Range(0,1)) = 0.1
		_OutlineThickness ("Outline Thickness", Range(0,.05)) = .01
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_OutlineBrightness ("Outline Brightness", Range(0,1)) = .4
		[MaterialToggle] _SolidOutline("Solid Outline", Float) = 0
		_RimColor ("Rim Light Color", Color) = (0.26,0.19,0.16,0.0)
      	_RimPower ("Rim Light Power", Range(0.5,8.0)) = 3.0
      	_Shininess ("Specularity", Float) = 10
      	_SpecBrightness("Specular Brightness", Range(1,2)) = 1.7
	}
	SubShader 
	{
		Pass
		{
			Cull Front
			
			Blend SrcAlpha OneMinusSrcAlpha
	        Tags { "LightMode" = "ForwardBase" } 
			LOD 200
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			
			#include "UnityCG.cginc"
			uniform sampler2D _UnlitTex;
			uniform float _OutlineThickness;
			uniform float4 _OutlineColor;
			uniform float _OutlineBrightness;
			uniform float _SolidOutline;
			
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
				
				float3 norm = mul ((float3x3)UNITY_MATRIX_MV, input.normal);
    			norm.x *= UNITY_MATRIX_P[0][0];
    			norm.y *= UNITY_MATRIX_P[1][1];
    			output.pos.xy += norm.xy * _OutlineThickness;
				   
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{	
				if(_SolidOutline)
				{
					return _OutlineColor;	
				}
				else
				{
					float4 fragmentcolor = tex2D (_UnlitTex, input.uv);
					fragmentcolor.rgb *= _OutlineBrightness;
					return fragmentcolor;
				}
			}
			ENDCG
		 }
		 
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
			uniform sampler2D _NormalTex;
			uniform float _UseNormal;
			uniform float4 _OutlineColor;
			uniform float _Shininess;
			uniform float _SpecBrightness;
			uniform float4 _RimColor;
			uniform float _RimPower;
			
			uniform float _Threshold;
			
			struct vertexInput 
			{	
				float4 vertex : POSITION;
           		float4 texcoord : TEXCOORD0;
            	float3 normal : NORMAL;
            	float4 tangent : TANGENT;
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD1;
				float2 uv : TEXCOORD0;
				float3 normalDir : NORMAL;
				
				float3 tangentWorld : TEXCOORD2;
				float3 normalWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
			};
			
			float4 _UnlitTex_ST;
			float4 _LitTex_ST;
			float4 _NormalTex_ST;
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				output.tangentWorld = normalize(
               		mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
            	output.normalWorld = normalize(
               		mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            	output.binormalWorld = normalize(
               		cross(output.normalWorld, output.tangentWorld) 
               		* input.tangent.w);
				
				output.posWorld = mul(modelMatrix, input.vertex);
				output.normalDir = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				output.uv = TRANSFORM_TEX(input.texcoord, _UnlitTex);
				   
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float4 encodedNormal = tex2D(_NormalTex, 
               		_NormalTex_ST.xy * input.uv.xy + _NormalTex_ST.zw);
            	float3 localCoords = float3(2.0 * encodedNormal.a - 1.0, 
                	2.0 * encodedNormal.g - 1.0, 0.0);
            	localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
 
 
            	float3x3 local2WorldTranspose = float3x3(
               		input.tangentWorld, 
               		input.binormalWorld, 
               		input.normalWorld);
               	float3 normalDirection;
            	if(_UseNormal)
        		{
            		normalDirection = 
               			normalize(mul(localCoords, local2WorldTranspose));
               	}
				else {
					normalDirection = normalize(input.normalDir);
				}
				
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
				
				float4 fragmentColor;
				if(dot(normalDirection, lightDirection) > 0.0 
					&& attenuation * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess) > .5)
				{
					fragmentColor = tex2D(_LitTex, input.uv) * _SpecBrightness;	
				}
				else if(attenuation * max(0.0, dot(normalDirection, lightDirection)) >= _Threshold)
				{
					fragmentColor = tex2D(_LitTex, input.uv) * _LightColor0;
				}
				else
				{
					fragmentColor = tex2D (_UnlitTex, input.uv);
				}
				
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float rimLighting = attenuation * _LightColor0 * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
				
				return fragmentColor + rimLighting;
				
			}
			ENDCG
		 }
	}
}