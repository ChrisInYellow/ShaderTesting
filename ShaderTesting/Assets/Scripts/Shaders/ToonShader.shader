Shader "Custom/ToonShader" {
	Properties{
	_MainTex("Texture", 2D) = "white" {}
	_RampTex("Ramp", 2D) = "white"
	}
		SubShader{
			Tags { "RenderType" = "Transparent" }

		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#pragma surface surf Toon
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
		}
		sampler2D _RampTex;
		fixed4 LightingToon(SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			half NdotL = dot(s.Normal, lightDir);
			NdotL = tex2D(_RampTex, fixed2(NdotL, 0.5));


		fixed4 c;
		c.rgb = s.Albedo *_LightColor0.rgb * NdotL * atten * 2;
		c.a = s.Alpha;
		return c;
		}
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		ENDCG
	}
		FallBack "Diffuse"
}
