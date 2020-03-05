Shader "Custom/GrassSwing"
{
	Properties
	{
		[PerRendererData]_MainTex("Sprite Texture", 2D) = "white" {}
	_Color("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 0
		[HideInInspector] _RendererColor("RendererColor", Color) = (1,1,1,1)
		[HideInInspector] _Flip("Flip", Vector) = (1,1,1,1)
		[PerRendererData] _AlphaTex("External Alpha", 2D) = "white" {}
		_HSpeed("HSwingSpeed",Float) = 1
		_VSpeed("VSwingSpeed",Float) = 1
		_HForce("HSwingForce",Float) = 1
		_VForce("VSwingForce",Float) = 1
			//[Toggle]_Random("Random",Float) = 0
	[PerRendererData] _EnableExternalAlpha("Enable External Alpha", Float) = 0
	}
		SubShader
		{
			Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}
			Cull Off
			Lighting Off
			ZWrite Off
			Blend One OneMinusSrcAlpha
			Pass
		{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment MySpriteFrag
	#pragma target 2.0
	#pragma multi_compile_instancing
	#pragma multi_compile _ PIXELSNAP_ON
	#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
	#include "UnityCG.cginc"
	#include "UnitySprites.cginc"

			float _HSpeed;
			float _VSpeed;
			float _HForce;
			float _VForce;
			//float _Random;

	fixed4 MySampleSpriteTexture(float2 uv)
	{
		fixed4 color = tex2D(_MainTex, uv);
#if ETC1_EXTERNAL_ALPHA
		fixed4 alpha = tex2D(_AlphaTex, uv);
		color.a = lerp(color.a, alpha.r, _EnableExternalAlpha);
#endif
		return color;
	}

	float random(float2 uv)
	{
		return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453123);
	}

	v2f vert(appdata_t IN)
	{
		v2f OUT;
		//UNITY_SETUP_INSTANCE_ID(IN);
		//UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
//#ifdef UNITY_INSTANCING_ENABLED
//		IN.vertex.xy *= _Flip.xy;
//#endif
		float2 uv = IN.texcoord;
		float worldSwing = UnityObjectToClipPos(IN.vertex).xy;
		float hswing = sin(_Time.y*_HSpeed+ worldSwing)*uv.y*_HForce;
		float hscale = cos(hswing * (IN.vertex.x - 1)+ worldSwing*uv.y);
		float vswing = sin(_Time.y*_VSpeed + worldSwing)*uv.y*_VForce*hscale;
		OUT.vertex = UnityObjectToClipPos(IN.vertex+float4(hswing*hscale, vswing,0,0));
		OUT.texcoord = IN.texcoord;
		OUT.color = IN.color * _Color * _RendererColor;
#ifdef PIXELSNAP_ON
		OUT.vertex = UnityPixelSnap(OUT.vertex);
#endif
		return OUT;
	}

	fixed4 MySpriteFrag(v2f IN) : SV_Target
	{
		float2 uv = IN.texcoord;
		fixed4 c = MySampleSpriteTexture(uv) * IN.color;
	c.rgb *= c.a;
	return c;
	}
		ENDCG
	}
	}
}