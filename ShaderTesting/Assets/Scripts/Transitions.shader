// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Transitions"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_TransitionTex("Transition Texture",2D) = "white"{}
		_CutOff("Cutoff", Range(0,1)) = 0
		_Fade("Fade", Range(0,1)) = 0
		_Color("Screen Color", Color) = (1,1,1,1)
		[MaterialToggle]_Distort("Distort",Float) = 0
	}
		SubShader
		{
			// No culling or depth
			Cull Off ZWrite Off ZTest Always

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				v2f simplevert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}
				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;

					#if UNITY_UV_STARTS_AT_TOP
						#endif

					return o;
				}
				sampler2D _MainTex;
				sampler2D _TransitionTex;
				float _CutOff;
				float _Fade; 
				fixed4 _Color;
				int _Distort;

				fixed4 simplefrag(v2f i) : SV_Target
				{
					if (i.uv.x < _CutOff)
					{
						return _Color;
					}

					return tex2D(_MainTex, i.uv);
				}

				fixed4 simplefragOpen(v2f i) : SV_Target
				{
					if (0.5 - abs(i.uv.y - 0.5) < abs(_CutOff)*0.5)
					{
						return _Color;
					}
					return tex2D(_MainTex, i.uv);
				}

				fixed4 simpleTexture(v2f i) : SV_Target
				{
					fixed4 transit = tex2D(_TransitionTex, i.uv);

				if (transit.b < _CutOff)
					return _Color;

				return tex2D(_MainTex, i.uv);
				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 transit = tex2D(_TransitionTex, i.uv);

				fixed2 direction = float2(0, 0);

				if (_Distort)
				{
					direction = normalize(float2((transit.r - 0.5) * 2, (transit.g - 0.5) * 2));
				}

				fixed4 col = tex2D(_MainTex, i.uv + _CutOff * direction);
				if (transit.b < _CutOff)
				{
					return col = lerp(col, _Color, _Fade);

				}
				return col;
				}
				ENDCG
			}
		}
}
