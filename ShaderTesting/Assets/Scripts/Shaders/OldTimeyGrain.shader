Shader "Custom/OldTimeyGrain" {
	Properties{
		_MainTex("Base(RGB)",2D) = "white"{}

		SepiaValue("SepiaValue", Float) = 0
		NoiseValue("NoiseValue", Float) = 0
		ScratchValue("ScratchValue", Float) = 0
		InnerVignetting("InnerVignetting", Float) = 0
		OuterVignetting("OuterVignetting", Float) = 0
		RandomValue("RandomValue", Float) = 0
		Timelapse("TimeLapse", Float) = 0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma target 3.0
			#pragma surface surf Lambert

			sampler2D _MainTex;

			uniform float SepiaValue;
			uniform float NoiseValue;
			uniform float ScratchValue;
			uniform float InnerVignetting;
			uniform float OuterVignetting;
			uniform float RandomValue;
			uniform float TimeLapse;

			struct Input {
				float2 uv_MainTex;
			};

			float3 Overlay(float3 src, float3 dst)
			{
				return float3((dst.x <= 0.5) ? (2.0 *src.x * dst.x) : (1.0 - 2.0 * (1.0 - dst.x) *
					(1.0 - src.x)), (dst.y <= 0.5) ? (2.0 * src.y * dst.y) : (1.0 - 2.0 * (1.0 - dst.y) * (1.0 - src.y)),
					(dst.z <= 0.5) ? (2.0 * src.z * dst.z) : (1.0 - 2.0 * (1.0 - dst.z) * (1.0 - src.z)));
			}

			float3 mod289(float3 x) { return x - floor(x *(1.0 / 289.0)) * 289.0; }
			float2 mod289(float2 x) { return x - floor(x *(1.0 / 289.0)) * 289.0; }
			float3 permute(float3 x) { return mod289(((x*34.0) + 1.0)*x); }

			float snoise(float2 v)
			{
				const float4 C = float4(0.211324865405187,
					0.366025403784439,
					-0.577350269189626,
					0.024390243902439);

				float2 i = floor(v + dot(v, C.yy));
				float2 x0 = v - i + dot(i, C.xx);

				float2 i1;
				i1 = (x0.x > x0.y) ? float2 (1.0, 0.0) : float2(0.0, 1.0);
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;

				i = mod289(i);
				float3 p = permute(permute(i.y + float3(0.0, i1.y, 1.0))
					+ i.x + float3(0.0, i1.x, 1.0));

				float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
				m = m * m;
				m = m * m;

				float3 x = 2.0 * frac(p * C.www) - 1.0;
				float3 h = abs(x) - 0.5;
				float3 ox = floor(x + 0.5);
				float3 a0 = x - ox;

				m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h * h);

				float3 g;
				g.x = a0.x * x0.x + h.x *x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot(m, g);
			}
			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutput o) {
				float3 sepia = float3(112.0 / 255.0, 66.0 / 255.0, 20.0 / 255.0);

				float3 colour = tex2D(_MainTex, IN.uv_MainTex.xy).xyz;
				float gray = (colour.x + colour.y + colour.z) / 3.0;
				float3 grayscale = float3(gray, gray, gray);

				float3 finalColour = Overlay(sepia, grayscale);

				finalColour = grayscale + SepiaValue * (finalColour - grayscale);

				float noise = snoise(IN.uv_MainTex.xy * float2(1024.0 + RandomValue * 512.0, 1024.0
					+ RandomValue * 512.0)) * 0.5;
				finalColour += noise * NoiseValue;

				// Optionally add noise as an overlay, simulating ISO on the camera
				//vec3 noiseOverlay = Overlay(finalColour, vec3(noise));
				//finalColour = finalColour + NoiseValue * (finalColour - noiseOverlay);

				if (RandomValue < ScratchValue)
				{
					float dist = 1.0 / ScratchValue;
					//RandomValue *= _Time.y*10;
					float d = distance(IN.uv_MainTex.xy, float2(RandomValue * dist, RandomValue * dist));

					if (d < 0.4)
					{
						float xPeriod = 8.0;
						float yPeriod = 1.0;
						float pi = 3.141592;
						float phase = TimeLapse;
						//                    float phase = _Time.x*TimeLapse;
						//                    float phase = _Time.x;
						float turbulence = snoise(IN.uv_MainTex.xy * 2.5);
						float vScratch = 0.5 + (sin(((IN.uv_MainTex.x * xPeriod + IN.uv_MainTex.y
							*yPeriod + turbulence)) * pi + phase) * 0.5);
						vScratch = clamp((vScratch * 10000.0) + 0.35, 0.0, 1.0);

						finalColour.xyz *= vScratch; 
					}

				}

				float d = distance(float2(0.5, 0.5), IN.uv_MainTex) * 1.414213; 
				float vignetting = clamp((OuterVignetting - d) / (OuterVignetting - InnerVignetting), 0.0, 1.0);
				finalColour.xyz *= vignetting; 

				// Apply colour
				//gl_FragColor.xyz = finalColour;
				//gl_FragColor.w = 1.0;

				//half4 c = tex2D (_MainTex, IN.uv_MainTex);
				o.Albedo = finalColour; 
				o.Alpha = 1; 
			}
			ENDCG
		}
			FallBack "Diffuse"
}
