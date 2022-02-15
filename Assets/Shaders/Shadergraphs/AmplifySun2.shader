// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifySun2"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_ParallaxPanner("Parallax Panner", Vector) = (-0.04,-0.15,0,0)
		_Organic2("Organic2", 2D) = "white" {}
		_ParallaxHeightmulti("Parallax Height multi", Float) = 1.02
		_ParallaxHeight("Parallax Height", Float) = 0.7
		_Parallaxnormalscale("Parallax normal scale", Range( 0 , 1)) = 0.754001
		_splatterNormal("splatterNormal", 2D) = "white" {}
		_ColorSmoothstepFresnelValue("Color Smoothstep Fresnel Value", Float) = 16
		_FresnelPower("Fresnel Power", Float) = 1.85
		_FresnelColor("Fresnel Color", Color) = (1,0.7334148,0,1)
		_FresnelValue("Fresnel Value", Float) = 2
		_FresnelBorderPower("Fresnel Border Power", Range( 0 , 25)) = 8
		_FresnelBorderValue("Fresnel Border Value", Float) = 2
		_FresnelBorderColor("Fresnel Border Color", Color) = (1,0.5157232,0.5645639,0)
		_MainTexPanner("Main TexPanner", Vector) = (-0.15,-0.65,0,0)
		_NoiseSPEEEEED("Noise SPEEEEED", Vector) = (-0.08,-0.15,-0.18,-0.45)
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_Splatter("Splatter", 2D) = "white" {}
		_NoisePower(" Noise Power", Vector) = (0.35,0.22,0,0)
		_EarlyPowerValue("Early Power Value", Float) = 0.63
		_OpacitySmoothstepPower("Opacity Smoothstep Power", Float) = 1
		_VertexSmoothness("Vertex Smoothness", Float) = 0.15
		_MinColorSmoothstep("Min Color Smoothstep", Float) = 10
		_SmoothStepNoiseAmount("SmoothStep Noise Amount", Vector) = (0.01,1,0,0)
		_ColorSmoothstep("Color Smoothstep", Float) = 10
		_ColorSmoothstepFresnelLerp("Color Smoothstep Fresnel Lerp", Float) = 0.9
		_Cold("Cold", Color) = (1,0.7647059,0.4117647,1)
		_Color0("Color 0", Color) = (1,0.4039216,0.1098039,1)
		_EmissivePower("Emissive Power", Float) = 1.03
		_Saturation("Saturation", Float) = 1.1
		_VertexOffsetStrength("VertexOffsetStrength", Float) = 0.01
		[ASEEnd]_EmissionAmount("Emission Amount", Float) = 1

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		Cull Back
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 2.0

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define TESSELLATION_ON 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_FIXED_TESSELLATION
			#define _EMISSION
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FresnelBorderColor;
			float4 _NoiseSPEEEEED;
			float4 _Cold;
			float4 _Color0;
			float4 _FresnelColor;
			float2 _MainTexPanner;
			float2 _ParallaxPanner;
			float2 _NoisePower;
			float2 _SmoothStepNoiseAmount;
			float _EmissivePower;
			float _FresnelBorderValue;
			float _FresnelBorderPower;
			float _FresnelValue;
			float _FresnelPower;
			float _ColorSmoothstepFresnelLerp;
			float _ColorSmoothstepFresnelValue;
			float _OpacitySmoothstepPower;
			float _MinColorSmoothstep;
			float _Saturation;
			float _VertexOffsetStrength;
			float _VertexSmoothness;
			float _EarlyPowerValue;
			float _Parallaxnormalscale;
			float _ParallaxHeight;
			float _ParallaxHeightmulti;
			float _ColorSmoothstep;
			float _EmissionAmount;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Organic2;
			sampler2D _splatterNormal;
			sampler2D _TextureSample2;
			sampler2D _Splatter;


					float2 voronoihash58( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi58( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash58( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			inline float2 ParallaxOffset( half h, half height, half3 viewDir )
			{
				h = h * height - height/2.0;
				float3 v = normalize( viewDir );
				v.z += 0.42;
				return h* (v.xy / v.z);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float time58 = 2.16;
				float2 texCoord16 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_1 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2Dlod( _splatterNormal, float4( temp_cast_1, 0, 0.0) );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2Dlod( _Organic2, float4( panner10, 0, 0.0) ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_5 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_7 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2Dlod( _TextureSample2, float4( panner152, 0, 0.0) ) ) , temp_cast_5 ) * pow( abs( tex2Dlod( _Splatter, float4( panner72, 0, 0.0) ) ) , temp_cast_7 ) * 2.0 ) );
				float4 temp_cast_8 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_8 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 lerpResult100 = lerp( temp_output_90_0 , temp_output_92_0 , ( 1.0 - (0.0 + (_VertexSmoothness - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float4 TextoVertex101 = lerpResult100;
				float4 temp_output_146_0 = saturate( ( TextoVertex101 * _VertexOffsetStrength ) );
				
				o.ase_texcoord7.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_146_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag ( VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 temp_cast_0 = (_SmoothStepNoiseAmount.x).xxxx;
				float4 temp_cast_1 = (_SmoothStepNoiseAmount.y).xxxx;
				float time58 = 2.16;
				float2 texCoord16 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float4 appendResult32 = (float4(WorldViewDirection.x , WorldViewDirection.y , 0.0 , 0.0));
				float2 temp_cast_3 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2D( _splatterNormal, temp_cast_3 );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , WorldViewDirection.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2D( _Organic2, panner10 ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_7 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_9 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2D( _TextureSample2, panner152 ) ) , temp_cast_7 ) * pow( abs( tex2D( _Splatter, panner72 ) ) , temp_cast_9 ) * 2.0 ) );
				float4 temp_cast_10 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_10 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 temp_cast_11 = (_OpacitySmoothstepPower).xxxx;
				float2 _Vector0 = float2(0,1);
				float4 temp_cast_12 = (_Vector0.x).xxxx;
				float4 temp_cast_13 = (_Vector0.y).xxxx;
				float4 clampResult102 = clamp( ( pow( abs( temp_output_92_0 ) , temp_cast_11 ) * 0.6 ) , temp_cast_12 , temp_cast_13 );
				float4 smoothstepResult104 = smoothstep( temp_cast_0 , temp_cast_1 , clampResult102);
				float4 temp_cast_14 = (1.0).xxxx;
				float4 temp_cast_15 = (_MinColorSmoothstep).xxxx;
				float4 temp_cast_16 = (1.0).xxxx;
				float4 temp_cast_17 = (_ColorSmoothstep).xxxx;
				float2 _Vector2 = float2(0,1);
				float4 temp_cast_18 = (_Vector2.x).xxxx;
				float4 temp_cast_19 = (_Vector2.y).xxxx;
				float4 clampResult112 = clamp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_17 - float4( 0,0,0,0 )) / (temp_cast_16 - float4( 0,0,0,0 ))) , temp_cast_18 , temp_cast_19 );
				float fresnelNdotV37 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode37 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV37, 2.95 ) );
				float ColorSmoothstepFresnel40 = ( fresnelNode37 * _ColorSmoothstepFresnelValue );
				float4 lerpResult116 = lerp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_15 - float4( 0,0,0,0 )) / (temp_cast_14 - float4( 0,0,0,0 ))) , clampResult112 , ColorSmoothstepFresnel40);
				float2 _Vector3 = float2(0,1);
				float4 temp_cast_20 = (_Vector3.x).xxxx;
				float4 temp_cast_21 = (_Vector3.y).xxxx;
				float4 clampResult118 = clamp( lerpResult116 , temp_cast_20 , temp_cast_21 );
				float4 lerpResult119 = lerp( clampResult118 , clampResult112 , ( 1.0 - _ColorSmoothstepFresnelLerp ));
				float4 lerpResult123 = lerp( _Cold , _Color0 , lerpResult119);
				float fresnelNdotV42 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode42 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV42, _FresnelPower ) );
				float4 Fresnel46 = ( _FresnelColor * fresnelNode42 * _FresnelValue );
				float fresnelNdotV48 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode48 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV48, _FresnelBorderPower ) );
				float4 FresnelBorder52 = ( _FresnelBorderColor * fresnelNode48 * _FresnelBorderValue );
				float4 temp_cast_22 = (_EmissivePower).xxxx;
				float3 desaturateInitialColor140 = pow( abs( ( ( float4( 0,0,0,0 ) + ( lerpResult123 * 1.4 ) ) + Fresnel46 + FresnelBorder52 ) ) , temp_cast_22 ).rgb;
				float desaturateDot140 = dot( desaturateInitialColor140, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar140 = lerp( desaturateInitialColor140, desaturateDot140.xxx, ( 1.0 - _Saturation ) );
				
				float3 Albedo = abs( desaturateVar140 );
				float3 Normal = float3(0, 0, 1);
				float3 Emission = ( desaturateVar140 * _EmissionAmount );
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 0.0;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif

				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif

				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define TESSELLATION_ON 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_FIXED_TESSELLATION
			#define _EMISSION
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FresnelBorderColor;
			float4 _NoiseSPEEEEED;
			float4 _Cold;
			float4 _Color0;
			float4 _FresnelColor;
			float2 _MainTexPanner;
			float2 _ParallaxPanner;
			float2 _NoisePower;
			float2 _SmoothStepNoiseAmount;
			float _EmissivePower;
			float _FresnelBorderValue;
			float _FresnelBorderPower;
			float _FresnelValue;
			float _FresnelPower;
			float _ColorSmoothstepFresnelLerp;
			float _ColorSmoothstepFresnelValue;
			float _OpacitySmoothstepPower;
			float _MinColorSmoothstep;
			float _Saturation;
			float _VertexOffsetStrength;
			float _VertexSmoothness;
			float _EarlyPowerValue;
			float _Parallaxnormalscale;
			float _ParallaxHeight;
			float _ParallaxHeightmulti;
			float _ColorSmoothstep;
			float _EmissionAmount;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Organic2;
			sampler2D _splatterNormal;
			sampler2D _TextureSample2;
			sampler2D _Splatter;


					float2 voronoihash58( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi58( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash58( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			inline float2 ParallaxOffset( half h, half height, half3 viewDir )
			{
				h = h * height - height/2.0;
				float3 v = normalize( viewDir );
				v.z += 0.42;
				return h* (v.xy / v.z);
			}
			

			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float time58 = 2.16;
				float2 texCoord16 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_1 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2Dlod( _splatterNormal, float4( temp_cast_1, 0, 0.0) );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2Dlod( _Organic2, float4( panner10, 0, 0.0) ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_5 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_7 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2Dlod( _TextureSample2, float4( panner152, 0, 0.0) ) ) , temp_cast_5 ) * pow( abs( tex2Dlod( _Splatter, float4( panner72, 0, 0.0) ) ) , temp_cast_7 ) * 2.0 ) );
				float4 temp_cast_8 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_8 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 lerpResult100 = lerp( temp_output_90_0 , temp_output_92_0 , ( 1.0 - (0.0 + (_VertexSmoothness - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float4 TextoVertex101 = lerpResult100;
				float4 temp_output_146_0 = saturate( ( TextoVertex101 * _VertexOffsetStrength ) );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_146_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define TESSELLATION_ON 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_FIXED_TESSELLATION
			#define _EMISSION
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FresnelBorderColor;
			float4 _NoiseSPEEEEED;
			float4 _Cold;
			float4 _Color0;
			float4 _FresnelColor;
			float2 _MainTexPanner;
			float2 _ParallaxPanner;
			float2 _NoisePower;
			float2 _SmoothStepNoiseAmount;
			float _EmissivePower;
			float _FresnelBorderValue;
			float _FresnelBorderPower;
			float _FresnelValue;
			float _FresnelPower;
			float _ColorSmoothstepFresnelLerp;
			float _ColorSmoothstepFresnelValue;
			float _OpacitySmoothstepPower;
			float _MinColorSmoothstep;
			float _Saturation;
			float _VertexOffsetStrength;
			float _VertexSmoothness;
			float _EarlyPowerValue;
			float _Parallaxnormalscale;
			float _ParallaxHeight;
			float _ParallaxHeightmulti;
			float _ColorSmoothstep;
			float _EmissionAmount;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Organic2;
			sampler2D _splatterNormal;
			sampler2D _TextureSample2;
			sampler2D _Splatter;


					float2 voronoihash58( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi58( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash58( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			inline float2 ParallaxOffset( half h, half height, half3 viewDir )
			{
				h = h * height - height/2.0;
				float3 v = normalize( viewDir );
				v.z += 0.42;
				return h* (v.xy / v.z);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float time58 = 2.16;
				float2 texCoord16 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_1 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2Dlod( _splatterNormal, float4( temp_cast_1, 0, 0.0) );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2Dlod( _Organic2, float4( panner10, 0, 0.0) ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_5 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_7 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2Dlod( _TextureSample2, float4( panner152, 0, 0.0) ) ) , temp_cast_5 ) * pow( abs( tex2Dlod( _Splatter, float4( panner72, 0, 0.0) ) ) , temp_cast_7 ) * 2.0 ) );
				float4 temp_cast_8 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_8 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 lerpResult100 = lerp( temp_output_90_0 , temp_output_92_0 , ( 1.0 - (0.0 + (_VertexSmoothness - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float4 TextoVertex101 = lerpResult100;
				float4 temp_output_146_0 = saturate( ( TextoVertex101 * _VertexOffsetStrength ) );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_146_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}
		
		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define TESSELLATION_ON 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_FIXED_TESSELLATION
			#define _EMISSION
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FresnelBorderColor;
			float4 _NoiseSPEEEEED;
			float4 _Cold;
			float4 _Color0;
			float4 _FresnelColor;
			float2 _MainTexPanner;
			float2 _ParallaxPanner;
			float2 _NoisePower;
			float2 _SmoothStepNoiseAmount;
			float _EmissivePower;
			float _FresnelBorderValue;
			float _FresnelBorderPower;
			float _FresnelValue;
			float _FresnelPower;
			float _ColorSmoothstepFresnelLerp;
			float _ColorSmoothstepFresnelValue;
			float _OpacitySmoothstepPower;
			float _MinColorSmoothstep;
			float _Saturation;
			float _VertexOffsetStrength;
			float _VertexSmoothness;
			float _EarlyPowerValue;
			float _Parallaxnormalscale;
			float _ParallaxHeight;
			float _ParallaxHeightmulti;
			float _ColorSmoothstep;
			float _EmissionAmount;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Organic2;
			sampler2D _splatterNormal;
			sampler2D _TextureSample2;
			sampler2D _Splatter;


					float2 voronoihash58( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi58( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash58( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			inline float2 ParallaxOffset( half h, half height, half3 viewDir )
			{
				h = h * height - height/2.0;
				float3 v = normalize( viewDir );
				v.z += 0.42;
				return h* (v.xy / v.z);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float time58 = 2.16;
				float2 texCoord16 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_1 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2Dlod( _splatterNormal, float4( temp_cast_1, 0, 0.0) );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2Dlod( _Organic2, float4( panner10, 0, 0.0) ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_5 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_7 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2Dlod( _TextureSample2, float4( panner152, 0, 0.0) ) ) , temp_cast_5 ) * pow( abs( tex2Dlod( _Splatter, float4( panner72, 0, 0.0) ) ) , temp_cast_7 ) * 2.0 ) );
				float4 temp_cast_8 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_8 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 lerpResult100 = lerp( temp_output_90_0 , temp_output_92_0 , ( 1.0 - (0.0 + (_VertexSmoothness - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float4 TextoVertex101 = lerpResult100;
				float4 temp_output_146_0 = saturate( ( TextoVertex101 * _VertexOffsetStrength ) );
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_146_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 temp_cast_0 = (_SmoothStepNoiseAmount.x).xxxx;
				float4 temp_cast_1 = (_SmoothStepNoiseAmount.y).xxxx;
				float time58 = 2.16;
				float2 texCoord16 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_3 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2D( _splatterNormal, temp_cast_3 );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2D( _Organic2, panner10 ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_7 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_9 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2D( _TextureSample2, panner152 ) ) , temp_cast_7 ) * pow( abs( tex2D( _Splatter, panner72 ) ) , temp_cast_9 ) * 2.0 ) );
				float4 temp_cast_10 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_10 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 temp_cast_11 = (_OpacitySmoothstepPower).xxxx;
				float2 _Vector0 = float2(0,1);
				float4 temp_cast_12 = (_Vector0.x).xxxx;
				float4 temp_cast_13 = (_Vector0.y).xxxx;
				float4 clampResult102 = clamp( ( pow( abs( temp_output_92_0 ) , temp_cast_11 ) * 0.6 ) , temp_cast_12 , temp_cast_13 );
				float4 smoothstepResult104 = smoothstep( temp_cast_0 , temp_cast_1 , clampResult102);
				float4 temp_cast_14 = (1.0).xxxx;
				float4 temp_cast_15 = (_MinColorSmoothstep).xxxx;
				float4 temp_cast_16 = (1.0).xxxx;
				float4 temp_cast_17 = (_ColorSmoothstep).xxxx;
				float2 _Vector2 = float2(0,1);
				float4 temp_cast_18 = (_Vector2.x).xxxx;
				float4 temp_cast_19 = (_Vector2.y).xxxx;
				float4 clampResult112 = clamp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_17 - float4( 0,0,0,0 )) / (temp_cast_16 - float4( 0,0,0,0 ))) , temp_cast_18 , temp_cast_19 );
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV37 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode37 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV37, 2.95 ) );
				float ColorSmoothstepFresnel40 = ( fresnelNode37 * _ColorSmoothstepFresnelValue );
				float4 lerpResult116 = lerp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_15 - float4( 0,0,0,0 )) / (temp_cast_14 - float4( 0,0,0,0 ))) , clampResult112 , ColorSmoothstepFresnel40);
				float2 _Vector3 = float2(0,1);
				float4 temp_cast_20 = (_Vector3.x).xxxx;
				float4 temp_cast_21 = (_Vector3.y).xxxx;
				float4 clampResult118 = clamp( lerpResult116 , temp_cast_20 , temp_cast_21 );
				float4 lerpResult119 = lerp( clampResult118 , clampResult112 , ( 1.0 - _ColorSmoothstepFresnelLerp ));
				float4 lerpResult123 = lerp( _Cold , _Color0 , lerpResult119);
				float fresnelNdotV42 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode42 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV42, _FresnelPower ) );
				float4 Fresnel46 = ( _FresnelColor * fresnelNode42 * _FresnelValue );
				float fresnelNdotV48 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode48 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV48, _FresnelBorderPower ) );
				float4 FresnelBorder52 = ( _FresnelBorderColor * fresnelNode48 * _FresnelBorderValue );
				float4 temp_cast_22 = (_EmissivePower).xxxx;
				float3 desaturateInitialColor140 = pow( abs( ( ( float4( 0,0,0,0 ) + ( lerpResult123 * 1.4 ) ) + Fresnel46 + FresnelBorder52 ) ) , temp_cast_22 ).rgb;
				float desaturateDot140 = dot( desaturateInitialColor140, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar140 = lerp( desaturateInitialColor140, desaturateDot140.xxx, ( 1.0 - _Saturation ) );
				
				
				float3 Albedo = abs( desaturateVar140 );
				float3 Emission = ( desaturateVar140 * _EmissionAmount );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define TESSELLATION_ON 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_FIXED_TESSELLATION
			#define _EMISSION
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FresnelBorderColor;
			float4 _NoiseSPEEEEED;
			float4 _Cold;
			float4 _Color0;
			float4 _FresnelColor;
			float2 _MainTexPanner;
			float2 _ParallaxPanner;
			float2 _NoisePower;
			float2 _SmoothStepNoiseAmount;
			float _EmissivePower;
			float _FresnelBorderValue;
			float _FresnelBorderPower;
			float _FresnelValue;
			float _FresnelPower;
			float _ColorSmoothstepFresnelLerp;
			float _ColorSmoothstepFresnelValue;
			float _OpacitySmoothstepPower;
			float _MinColorSmoothstep;
			float _Saturation;
			float _VertexOffsetStrength;
			float _VertexSmoothness;
			float _EarlyPowerValue;
			float _Parallaxnormalscale;
			float _ParallaxHeight;
			float _ParallaxHeightmulti;
			float _ColorSmoothstep;
			float _EmissionAmount;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Organic2;
			sampler2D _splatterNormal;
			sampler2D _TextureSample2;
			sampler2D _Splatter;


					float2 voronoihash58( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi58( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash58( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			inline float2 ParallaxOffset( half h, half height, half3 viewDir )
			{
				h = h * height - height/2.0;
				float3 v = normalize( viewDir );
				v.z += 0.42;
				return h* (v.xy / v.z);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float time58 = 2.16;
				float2 texCoord16 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_1 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2Dlod( _splatterNormal, float4( temp_cast_1, 0, 0.0) );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2Dlod( _Organic2, float4( panner10, 0, 0.0) ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_5 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_7 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2Dlod( _TextureSample2, float4( panner152, 0, 0.0) ) ) , temp_cast_5 ) * pow( abs( tex2Dlod( _Splatter, float4( panner72, 0, 0.0) ) ) , temp_cast_7 ) * 2.0 ) );
				float4 temp_cast_8 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_8 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 lerpResult100 = lerp( temp_output_90_0 , temp_output_92_0 , ( 1.0 - (0.0 + (_VertexSmoothness - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float4 TextoVertex101 = lerpResult100;
				float4 temp_output_146_0 = saturate( ( TextoVertex101 * _VertexOffsetStrength ) );
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_146_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 temp_cast_0 = (_SmoothStepNoiseAmount.x).xxxx;
				float4 temp_cast_1 = (_SmoothStepNoiseAmount.y).xxxx;
				float time58 = 2.16;
				float2 texCoord16 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_3 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2D( _splatterNormal, temp_cast_3 );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2D( _Organic2, panner10 ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_7 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_9 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2D( _TextureSample2, panner152 ) ) , temp_cast_7 ) * pow( abs( tex2D( _Splatter, panner72 ) ) , temp_cast_9 ) * 2.0 ) );
				float4 temp_cast_10 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_10 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 temp_cast_11 = (_OpacitySmoothstepPower).xxxx;
				float2 _Vector0 = float2(0,1);
				float4 temp_cast_12 = (_Vector0.x).xxxx;
				float4 temp_cast_13 = (_Vector0.y).xxxx;
				float4 clampResult102 = clamp( ( pow( abs( temp_output_92_0 ) , temp_cast_11 ) * 0.6 ) , temp_cast_12 , temp_cast_13 );
				float4 smoothstepResult104 = smoothstep( temp_cast_0 , temp_cast_1 , clampResult102);
				float4 temp_cast_14 = (1.0).xxxx;
				float4 temp_cast_15 = (_MinColorSmoothstep).xxxx;
				float4 temp_cast_16 = (1.0).xxxx;
				float4 temp_cast_17 = (_ColorSmoothstep).xxxx;
				float2 _Vector2 = float2(0,1);
				float4 temp_cast_18 = (_Vector2.x).xxxx;
				float4 temp_cast_19 = (_Vector2.y).xxxx;
				float4 clampResult112 = clamp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_17 - float4( 0,0,0,0 )) / (temp_cast_16 - float4( 0,0,0,0 ))) , temp_cast_18 , temp_cast_19 );
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV37 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode37 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV37, 2.95 ) );
				float ColorSmoothstepFresnel40 = ( fresnelNode37 * _ColorSmoothstepFresnelValue );
				float4 lerpResult116 = lerp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_15 - float4( 0,0,0,0 )) / (temp_cast_14 - float4( 0,0,0,0 ))) , clampResult112 , ColorSmoothstepFresnel40);
				float2 _Vector3 = float2(0,1);
				float4 temp_cast_20 = (_Vector3.x).xxxx;
				float4 temp_cast_21 = (_Vector3.y).xxxx;
				float4 clampResult118 = clamp( lerpResult116 , temp_cast_20 , temp_cast_21 );
				float4 lerpResult119 = lerp( clampResult118 , clampResult112 , ( 1.0 - _ColorSmoothstepFresnelLerp ));
				float4 lerpResult123 = lerp( _Cold , _Color0 , lerpResult119);
				float fresnelNdotV42 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode42 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV42, _FresnelPower ) );
				float4 Fresnel46 = ( _FresnelColor * fresnelNode42 * _FresnelValue );
				float fresnelNdotV48 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode48 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV48, _FresnelBorderPower ) );
				float4 FresnelBorder52 = ( _FresnelBorderColor * fresnelNode48 * _FresnelBorderValue );
				float4 temp_cast_22 = (_EmissivePower).xxxx;
				float3 desaturateInitialColor140 = pow( abs( ( ( float4( 0,0,0,0 ) + ( lerpResult123 * 1.4 ) ) + Fresnel46 + FresnelBorder52 ) ) , temp_cast_22 ).rgb;
				float desaturateDot140 = dot( desaturateInitialColor140, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar140 = lerp( desaturateInitialColor140, desaturateDot140.xxx, ( 1.0 - _Saturation ) );
				
				
				float3 Albedo = abs( desaturateVar140 );
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
            ZTest LEqual
            ZWrite On

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define TESSELLATION_ON 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_FIXED_TESSELLATION
			#define _EMISSION
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float3 worldNormal : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FresnelBorderColor;
			float4 _NoiseSPEEEEED;
			float4 _Cold;
			float4 _Color0;
			float4 _FresnelColor;
			float2 _MainTexPanner;
			float2 _ParallaxPanner;
			float2 _NoisePower;
			float2 _SmoothStepNoiseAmount;
			float _EmissivePower;
			float _FresnelBorderValue;
			float _FresnelBorderPower;
			float _FresnelValue;
			float _FresnelPower;
			float _ColorSmoothstepFresnelLerp;
			float _ColorSmoothstepFresnelValue;
			float _OpacitySmoothstepPower;
			float _MinColorSmoothstep;
			float _Saturation;
			float _VertexOffsetStrength;
			float _VertexSmoothness;
			float _EarlyPowerValue;
			float _Parallaxnormalscale;
			float _ParallaxHeight;
			float _ParallaxHeightmulti;
			float _ColorSmoothstep;
			float _EmissionAmount;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Organic2;
			sampler2D _splatterNormal;
			sampler2D _TextureSample2;
			sampler2D _Splatter;


					float2 voronoihash58( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi58( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash58( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			inline float2 ParallaxOffset( half h, half height, half3 viewDir )
			{
				h = h * height - height/2.0;
				float3 v = normalize( viewDir );
				v.z += 0.42;
				return h* (v.xy / v.z);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float time58 = 2.16;
				float2 texCoord16 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_1 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2Dlod( _splatterNormal, float4( temp_cast_1, 0, 0.0) );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2Dlod( _Organic2, float4( panner10, 0, 0.0) ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_5 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_7 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2Dlod( _TextureSample2, float4( panner152, 0, 0.0) ) ) , temp_cast_5 ) * pow( abs( tex2Dlod( _Splatter, float4( panner72, 0, 0.0) ) ) , temp_cast_7 ) * 2.0 ) );
				float4 temp_cast_8 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_8 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 lerpResult100 = lerp( temp_output_90_0 , temp_output_92_0 , ( 1.0 - (0.0 + (_VertexSmoothness - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float4 TextoVertex101 = lerpResult100;
				float4 temp_output_146_0 = saturate( ( TextoVertex101 * _VertexOffsetStrength ) );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_146_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif
				
				return float4(PackNormalOctRectEncode(TransformWorldToViewDir(IN.worldNormal, true)), 0.0, 0.0);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define TESSELLATION_ON 1
			#pragma require tessellation tessHW
			#pragma hull HullFunction
			#pragma domain DomainFunction
			#define ASE_FIXED_TESSELLATION
			#define _EMISSION
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _GBUFFER_NORMALS_OCT
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _FresnelBorderColor;
			float4 _NoiseSPEEEEED;
			float4 _Cold;
			float4 _Color0;
			float4 _FresnelColor;
			float2 _MainTexPanner;
			float2 _ParallaxPanner;
			float2 _NoisePower;
			float2 _SmoothStepNoiseAmount;
			float _EmissivePower;
			float _FresnelBorderValue;
			float _FresnelBorderPower;
			float _FresnelValue;
			float _FresnelPower;
			float _ColorSmoothstepFresnelLerp;
			float _ColorSmoothstepFresnelValue;
			float _OpacitySmoothstepPower;
			float _MinColorSmoothstep;
			float _Saturation;
			float _VertexOffsetStrength;
			float _VertexSmoothness;
			float _EarlyPowerValue;
			float _Parallaxnormalscale;
			float _ParallaxHeight;
			float _ParallaxHeightmulti;
			float _ColorSmoothstep;
			float _EmissionAmount;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Organic2;
			sampler2D _splatterNormal;
			sampler2D _TextureSample2;
			sampler2D _Splatter;


					float2 voronoihash58( float2 p )
					{
						
						p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
						return frac( sin( p ) *43758.5453);
					}
			
					float voronoi58( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
					{
						float2 n = floor( v );
						float2 f = frac( v );
						float F1 = 8.0;
						float F2 = 8.0; float2 mg = 0;
						for ( int j = -1; j <= 1; j++ )
						{
							for ( int i = -1; i <= 1; i++ )
						 	{
						 		float2 g = float2( i, j );
						 		float2 o = voronoihash58( n + g );
								o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
								float d = 0.5 * dot( r, r );
						 		if( d<F1 ) {
						 			F2 = F1;
						 			F1 = d; mg = g; mr = r; id = o;
						 		} else if( d<F2 ) {
						 			F2 = d;
						 		}
						 	}
						}
						return F1;
					}
			
			inline float2 ParallaxOffset( half h, half height, half3 viewDir )
			{
				h = h * height - height/2.0;
				float3 v = normalize( viewDir );
				v.z += 0.42;
				return h* (v.xy / v.z);
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float time58 = 2.16;
				float2 texCoord16 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float4 appendResult32 = (float4(ase_worldViewDir.x , ase_worldViewDir.y , 0.0 , 0.0));
				float2 temp_cast_1 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2Dlod( _splatterNormal, float4( temp_cast_1, 0, 0.0) );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , ase_worldViewDir.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2Dlod( _Organic2, float4( panner10, 0, 0.0) ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_5 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_7 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2Dlod( _TextureSample2, float4( panner152, 0, 0.0) ) ) , temp_cast_5 ) * pow( abs( tex2Dlod( _Splatter, float4( panner72, 0, 0.0) ) ) , temp_cast_7 ) * 2.0 ) );
				float4 temp_cast_8 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_8 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 lerpResult100 = lerp( temp_output_90_0 , temp_output_92_0 , ( 1.0 - (0.0 + (_VertexSmoothness - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ));
				float4 TextoVertex101 = lerpResult100;
				float4 temp_output_146_0 = saturate( ( TextoVertex101 * _VertexOffsetStrength ) );
				
				o.ase_texcoord7.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_146_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			FragmentOutput frag ( VertexOutput IN 
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float4 temp_cast_0 = (_SmoothStepNoiseAmount.x).xxxx;
				float4 temp_cast_1 = (_SmoothStepNoiseAmount.y).xxxx;
				float time58 = 2.16;
				float2 texCoord16 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord8 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner10 = ( 1.0 * _Time.y * _ParallaxPanner + texCoord8);
				float4 appendResult32 = (float4(WorldViewDirection.x , WorldViewDirection.y , 0.0 , 0.0));
				float2 temp_cast_3 = (_Parallaxnormalscale).xx;
				float4 tex2DNode29 = tex2D( _splatterNormal, temp_cast_3 );
				float4 appendResult30 = (float4(tex2DNode29.r , tex2DNode29.g , 0.0 , 0.0));
				float4 appendResult34 = (float4(( appendResult32 + appendResult30 ).xy , WorldViewDirection.z , 0.0));
				float4 normalizeResult35 = normalize( appendResult34 );
				float2 paralaxOffset15 = ParallaxOffset( ( _ParallaxHeightmulti * tex2D( _Organic2, panner10 ) ).r , _ParallaxHeight , normalizeResult35.xyz );
				float2 ParallaxMapping19 = ( texCoord16 + paralaxOffset15 );
				float2 panner55 = ( 1.0 * _Time.y * _MainTexPanner + ParallaxMapping19);
				float2 coords58 = panner55 * 5.3;
				float2 id58 = 0;
				float2 uv58 = 0;
				float fade58 = 0.5;
				float voroi58 = 0;
				float rest58 = 0;
				for( int it58 = 0; it58 <2; it58++ ){
				voroi58 += fade58 * voronoi58( coords58, time58, id58, uv58, 0 );
				rest58 += fade58;
				coords58 *= 2;
				fade58 *= 0.5;
				}//Voronoi58
				voroi58 /= rest58;
				float temp_output_63_0 = pow( abs( voroi58 ) , 0.73 );
				float temp_output_65_0 = ( 1.0 - temp_output_63_0 );
				float4 appendResult67 = (float4(_NoiseSPEEEEED.x , _NoiseSPEEEEED.y , 0.0 , 0.0));
				float2 texCoord69 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner152 = ( 1.0 * _Time.y * appendResult67.xy + texCoord69);
				float4 temp_cast_7 = (_NoisePower.x).xxxx;
				float4 appendResult68 = (float4(_NoiseSPEEEEED.z , _NoiseSPEEEEED.w , 0.0 , 0.0));
				float2 texCoord70 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner72 = ( 1.0 * _Time.y * appendResult68.xy + texCoord70);
				float4 temp_cast_9 = (_NoisePower.y).xxxx;
				float4 temp_output_81_0 = ( 1.0 - ( pow( abs( tex2D( _TextureSample2, panner152 ) ) , temp_cast_7 ) * pow( abs( tex2D( _Splatter, panner72 ) ) , temp_cast_9 ) * 2.0 ) );
				float4 temp_cast_10 = (_EarlyPowerValue).xxxx;
				float4 temp_output_90_0 = ( pow( abs( temp_output_65_0 ) , _EarlyPowerValue ) * pow( abs( temp_output_81_0 ) , temp_cast_10 ) );
				float4 smoothstepResult91 = smoothstep( float4( 0.6886792,0.6886792,0.6886792,0 ) , float4( 1,1,1,1 ) , ( temp_output_65_0 * temp_output_81_0 ));
				float4 temp_output_92_0 = ( temp_output_90_0 - smoothstepResult91 );
				float4 temp_cast_11 = (_OpacitySmoothstepPower).xxxx;
				float2 _Vector0 = float2(0,1);
				float4 temp_cast_12 = (_Vector0.x).xxxx;
				float4 temp_cast_13 = (_Vector0.y).xxxx;
				float4 clampResult102 = clamp( ( pow( abs( temp_output_92_0 ) , temp_cast_11 ) * 0.6 ) , temp_cast_12 , temp_cast_13 );
				float4 smoothstepResult104 = smoothstep( temp_cast_0 , temp_cast_1 , clampResult102);
				float4 temp_cast_14 = (1.0).xxxx;
				float4 temp_cast_15 = (_MinColorSmoothstep).xxxx;
				float4 temp_cast_16 = (1.0).xxxx;
				float4 temp_cast_17 = (_ColorSmoothstep).xxxx;
				float2 _Vector2 = float2(0,1);
				float4 temp_cast_18 = (_Vector2.x).xxxx;
				float4 temp_cast_19 = (_Vector2.y).xxxx;
				float4 clampResult112 = clamp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_17 - float4( 0,0,0,0 )) / (temp_cast_16 - float4( 0,0,0,0 ))) , temp_cast_18 , temp_cast_19 );
				float fresnelNdotV37 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode37 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV37, 2.95 ) );
				float ColorSmoothstepFresnel40 = ( fresnelNode37 * _ColorSmoothstepFresnelValue );
				float4 lerpResult116 = lerp( (float4( 0,0,0,0 ) + (smoothstepResult104 - float4( 0,0,0,0 )) * (temp_cast_15 - float4( 0,0,0,0 )) / (temp_cast_14 - float4( 0,0,0,0 ))) , clampResult112 , ColorSmoothstepFresnel40);
				float2 _Vector3 = float2(0,1);
				float4 temp_cast_20 = (_Vector3.x).xxxx;
				float4 temp_cast_21 = (_Vector3.y).xxxx;
				float4 clampResult118 = clamp( lerpResult116 , temp_cast_20 , temp_cast_21 );
				float4 lerpResult119 = lerp( clampResult118 , clampResult112 , ( 1.0 - _ColorSmoothstepFresnelLerp ));
				float4 lerpResult123 = lerp( _Cold , _Color0 , lerpResult119);
				float fresnelNdotV42 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode42 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV42, _FresnelPower ) );
				float4 Fresnel46 = ( _FresnelColor * fresnelNode42 * _FresnelValue );
				float fresnelNdotV48 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode48 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV48, _FresnelBorderPower ) );
				float4 FresnelBorder52 = ( _FresnelBorderColor * fresnelNode48 * _FresnelBorderValue );
				float4 temp_cast_22 = (_EmissivePower).xxxx;
				float3 desaturateInitialColor140 = pow( abs( ( ( float4( 0,0,0,0 ) + ( lerpResult123 * 1.4 ) ) + Fresnel46 + FresnelBorder52 ) ) , temp_cast_22 ).rgb;
				float desaturateDot140 = dot( desaturateInitialColor140, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar140 = lerp( desaturateInitialColor140, desaturateDot140.xxx, ( 1.0 - _Saturation ) );
				
				float3 Albedo = abs( desaturateVar140 );
				float3 Normal = float3(0, 0, 1);
				float3 Emission = ( desaturateVar140 * _EmissionAmount );
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				BRDFData brdfData;
				InitializeBRDFData( Albedo, Metallic, Specular, Smoothness, Alpha, brdfData);
				half4 color;
				color.rgb = GlobalIllumination( brdfData, inputData.bakedGI, Occlusion, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;
				
					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;
				
					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );
				
							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif
				
				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;
				
					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
				
					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;
				
					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );
				
							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif
				
				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif
				
				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif
				
				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				
				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb);
			}

			ENDHLSL
		}
		
	}
	/*ase_lod*/
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18900
-38;501.3333;1693.333;879;-4363.846;221.6238;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;20;-5913.32,247.0749;Inherit;False;Property;_Parallaxnormalscale;Parallax normal scale;4;0;Create;True;0;0;0;False;0;False;0.754001;0.72;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;31;-5528.026,-128.228;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;29;-5561.827,38.17189;Inherit;True;Property;_splatterNormal;splatterNormal;5;0;Create;True;0;0;0;False;0;False;-1;b4ee5684bce29744ebfe591659399869;b4ee5684bce29744ebfe591659399869;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;9;-5331.008,-346.623;Inherit;False;Property;_ParallaxPanner;Parallax Panner;0;0;Create;True;0;0;0;False;0;False;-0.04,-0.15;-0.04,-0.15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;30;-5114.626,83.67188;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-5307.026,-145.1282;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-5352.269,-465.0584;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-4906.627,-82.72803;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;10;-4986.435,-385.6313;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-4595.453,-483.8248;Inherit;False;Property;_ParallaxHeightmulti;Parallax Height multi;2;0;Create;True;0;0;0;False;0;False;1.02;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-4722.027,-13.82787;Inherit;True;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;11;-4713.873,-371.8049;Inherit;True;Property;_Organic2;Organic2;1;0;Create;True;0;0;0;False;0;False;-1;bf7f26ea1cd24ac4190154da4425433c;50e2c46c29efb2e43a443bcec1c2e03a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-4592.252,-144.5652;Inherit;False;Property;_ParallaxHeight;Parallax Height;3;0;Create;True;0;0;0;False;0;False;0.7;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-4260.994,-397.4094;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;35;-4413.852,41.99074;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;15;-4100.167,-110.9592;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-4060.159,-338.199;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-3708.099,-269.3872;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;66;-2805.354,201.8671;Inherit;False;Property;_NoiseSPEEEEED;Noise SPEEEEED;14;0;Create;True;0;0;0;False;0;False;-0.08,-0.15,-0.18,-0.45;-0.08,-0.18,-0.15,-0.45;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-2477.364,121.6111;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;67;-2382.364,240.6111;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;-2390.364,534.6111;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;70;-2483.364,397.6111;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-3546.47,-282.1892;Inherit;False;ParallaxMapping;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;54;-2682.265,-66.68482;Inherit;False;Property;_MainTexPanner;Main TexPanner;13;0;Create;True;0;0;0;False;0;False;-0.15,-0.65;-0.15,-0.65;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;53;-2694.961,-209.3856;Inherit;False;19;ParallaxMapping;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;72;-2131.451,424.6111;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;152;-2054.752,208.6451;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;74;-1859.739,231.8611;Inherit;True;Property;_TextureSample2;Texture Sample 2;15;0;Create;True;0;0;0;False;0;False;-1;bf7f26ea1cd24ac4190154da4425433c;bf7f26ea1cd24ac4190154da4425433c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;75;-1948.093,702.5948;Inherit;True;Property;_Splatter;Splatter;16;0;Create;True;0;0;0;False;0;False;-1;1f13082d0eff1024795d02cbff952b7a;1f13082d0eff1024795d02cbff952b7a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;55;-2429.597,-149.8675;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;58;-2249.541,-152.316;Inherit;True;0;0;1;0;2;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;2.16;False;2;FLOAT;5.3;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.Vector2Node;76;-1775.489,478.2361;Inherit;False;Property;_NoisePower; Noise Power;17;0;Create;True;0;0;0;False;0;False;0.35,0.22;0.35,0.22;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.AbsOpNode;195;-1582.233,126.7897;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;196;-1584.027,657.2373;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1447.989,525.8611;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;201;-2020.29,-215.8915;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;153;-1435.067,241.8021;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;78;-1426.507,685.5616;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;63;-1992.459,-116.6283;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0.73;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1240.989,384.8611;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;81;-986.489,388.6111;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;65;-1242.359,23.89673;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;197;-783.5714,-62.65781;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;200;-724.1388,261.2322;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-877.0524,164.5361;Inherit;False;Property;_EarlyPowerValue;Early Power Value;18;0;Create;True;0;0;0;False;0;False;0.63;0.63;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-646.4379,337.0111;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;89;-557.0521,-40.2639;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;83;-525.2891,177.2112;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-249.6449,80.82716;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;91;-236.2419,367.0015;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.6886792,0.6886792,0.6886792,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;92;83.55719,161.6017;Inherit;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;93;77.05786,433.3016;Inherit;False;Property;_OpacitySmoothstepPower;Opacity Smoothstep Power;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;199;368.2599,136.1705;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;94;507.1933,188.0735;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;96;435.857,316.3016;Inherit;False;Constant;_OpacitySmoothstepValue;Opacity Smoothstep Value;21;0;Create;True;0;0;0;False;0;False;0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;103;832.5411,453.8412;Inherit;False;Constant;_Vector0;Vector 0;22;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;737.4572,196.7016;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-5664.708,441.078;Inherit;False;Constant;_ColorSmoothstepFresnelPower;Color Smoothstep Fresnel Power;6;0;Create;True;0;0;0;False;0;False;2.95;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;37;-5318.798,402.0394;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;102;1098.122,215.9247;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;105;1162.541,353.8412;Inherit;False;Property;_SmoothStepNoiseAmount;SmoothStep Noise Amount;22;0;Create;True;0;0;0;False;0;False;0.01,1;0.16,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;39;-5355.798,612.0396;Inherit;False;Property;_ColorSmoothstepFresnelValue;Color Smoothstep Fresnel Value;6;0;Create;True;0;0;0;False;0;False;16;2.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;1305.541,586.8412;Inherit;False;Property;_ColorSmoothstep;Color Smoothstep;23;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;1446.541,485.8412;Inherit;False;Constant;_Float2;Float 2;23;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;104;1378.541,222.8412;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-4945.799,424.0394;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;111;1843.541,520.8412;Inherit;False;Constant;_Vector2;Vector 2;24;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;107;1446.541,128.8412;Inherit;False;Property;_MinColorSmoothstep;Min Color Smoothstep;21;0;Create;True;0;0;0;False;0;False;10;3.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;110;1819.841,302.5412;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-4735.799,441.0394;Inherit;False;ColorSmoothstepFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;1426.541,14.84116;Inherit;False;Constant;_Float1;Float 1;22;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;1907.541,680.8412;Inherit;False;40;ColorSmoothstepFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;114;1851.541,97.84116;Inherit;True;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0,0,0,0;False;4;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;112;2024.741,355.4414;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;117;2361.168,455.7928;Inherit;False;Constant;_Vector3;Vector 3;24;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;116;2158.078,101.1045;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;120;2426.042,676.7856;Inherit;False;Property;_ColorSmoothstepFresnelLerp;Color Smoothstep Fresnel Lerp;24;0;Create;True;0;0;0;False;0;False;0.9;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-4160.535,331.4116;Inherit;False;Property;_FresnelPower;Fresnel Power;7;0;Create;True;0;0;0;False;0;False;1.85;1.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;118;2599.065,320.2458;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;121;2794.042,692.7856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-4272.877,846.7975;Inherit;False;Property;_FresnelBorderPower;Fresnel Border Power;10;0;Create;True;0;0;0;False;0;False;8;1.8;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;124;2948.096,110.9403;Inherit;False;Property;_Color0;Color 0;26;0;Create;True;0;0;0;False;0;False;1,0.4039216,0.1098039,1;1,0.2668308,0.1098039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;48;-3935.663,819.0715;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;43;-3906.77,132.0503;Inherit;False;Property;_FresnelColor;Fresnel Color;8;0;Create;True;0;0;0;False;0;False;1,0.7334148,0,1;1,0.7205223,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;119;2866.344,316.3765;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;50;-3934.663,635.0717;Inherit;False;Property;_FresnelBorderColor;Fresnel Border Color;12;0;Create;True;0;0;0;False;0;False;1,0.5157232,0.5645639,0;1,0.4874213,0.4874213,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;125;2941.096,-117.1269;Inherit;False;Property;_Cold;Cold;25;0;Create;True;0;0;0;False;0;False;1,0.7647059,0.4117647,1;1,0.7081761,0.2704401,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;49;-3943.663,1002.071;Inherit;False;Property;_FresnelBorderValue;Fresnel Border Value;11;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-3863.77,503.0504;Inherit;False;Property;_FresnelValue;Fresnel Value;9;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;42;-3918.77,304.0502;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;123;3299.096,185.8731;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-3583.77,299.0502;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;127;3237.185,423.7729;Inherit;False;Constant;_Emission;Emission;27;0;Create;True;0;0;0;False;0;False;1.4;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-3558.663,770.0715;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-258.3427,-271.2986;Inherit;False;Property;_VertexSmoothness;Vertex Smoothness;20;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-3329.447,298.9269;Inherit;False;Fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-3334.663,790.0715;Inherit;False;FresnelBorder;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;3549.096,269.8731;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;98;35.45726,-260.8985;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;99;279.8572,-162.0984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;3717.127,170.2761;Inherit;False;52;FresnelBorder;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;3710.127,93.27606;Inherit;False;46;Fresnel;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;130;3766.127,-4.723938;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;3968.127,50.27606;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;100;490.4574,-134.7983;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;138;4110.127,431.2761;Inherit;False;Property;_Saturation;Saturation;28;0;Create;True;0;0;0;False;0;False;1.1;1.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;198;4241.981,7.61853;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;137;4008.127,301.2761;Inherit;False;Property;_EmissivePower;Emissive Power;27;0;Create;True;0;0;0;False;0;False;1.03;1.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;788.1574,-129.5984;Inherit;False;TextoVertex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;145;4279.793,748.7529;Inherit;False;Property;_VertexOffsetStrength;VertexOffsetStrength;29;0;Create;True;0;0;0;False;0;False;0.01;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;141;4147.281,595.3198;Inherit;False;101;TextoVertex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;139;4297.583,430.2761;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;136;4232.127,112.2761;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.16;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;151;4655.886,286.8951;Inherit;False;Property;_EmissionAmount;Emission Amount;30;0;Create;True;0;0;0;False;0;False;1;0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;4533.781,548.4132;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DesaturateOpNode;140;4538.503,74.836;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;146;4795.144,585.896;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1280.61,-115.2783;Inherit;False;MainTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;216;5252.626,561.558;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;149;4859.529,381.7315;Inherit;False;Constant;_Float3;Float 3;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;202;4874.175,36.11353;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BillboardNode;214;4793.343,488.5275;Inherit;False;Cylindrical;False;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;4903.154,222.3089;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;220;4981.158,-99.24647;Inherit;False;Property;_Float4;Float 4;31;0;Create;True;0;0;0;False;0;False;1.74;91.71;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;218;5133.085,686.8787;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;185;5733.232,76.2087;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;AmplifySun2;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;18;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;38;Workflow;1;Surface;0;  Refraction Model;0;  Blend;0;Two Sided;1;Fragment Normal Space,InvertActionOnDeselection;0;Transmission;0;  Transmission Shadow;1,False,-1;Translucency;0;  Translucency Strength;0,False,-1;  Normal Distortion;0.5,False,-1;  Scattering;1,False,-1;  Direct;0.9,False,-1;  Ambient;0.1,False,-1;  Shadow;0.5,False,-1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;1;Built-in Fog;1;_FinalColorxAlpha;0;Meta Pass;1;Override Baked GI;0;Extra Pre Pass;0;DOTS Instancing;0;Tessellation;1;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Write Depth;0;  Early Z;0;Vertex Position,InvertActionOnDeselection;1;0;8;False;True;True;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;191;5111.936,68.10484;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalGBuffer;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;186;5111.936,68.10484;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;187;5111.936,68.10484;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;184;5111.936,68.10484;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;189;5111.936,68.10484;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;190;5111.936,68.10484;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormals;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;188;5111.936,68.10484;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;29;1;20;0
WireConnection;30;0;29;1
WireConnection;30;1;29;2
WireConnection;32;0;31;1
WireConnection;32;1;31;2
WireConnection;33;0;32;0
WireConnection;33;1;30;0
WireConnection;10;0;8;0
WireConnection;10;2;9;0
WireConnection;34;0;33;0
WireConnection;34;2;31;3
WireConnection;11;1;10;0
WireConnection;12;0;13;0
WireConnection;12;1;11;0
WireConnection;35;0;34;0
WireConnection;15;0;12;0
WireConnection;15;1;14;0
WireConnection;15;2;35;0
WireConnection;18;0;16;0
WireConnection;18;1;15;0
WireConnection;67;0;66;1
WireConnection;67;1;66;2
WireConnection;68;0;66;3
WireConnection;68;1;66;4
WireConnection;19;0;18;0
WireConnection;72;0;70;0
WireConnection;72;2;68;0
WireConnection;152;0;69;0
WireConnection;152;2;67;0
WireConnection;74;1;152;0
WireConnection;75;1;72;0
WireConnection;55;0;53;0
WireConnection;55;2;54;0
WireConnection;58;0;55;0
WireConnection;195;0;74;0
WireConnection;196;0;75;0
WireConnection;201;0;58;0
WireConnection;153;0;195;0
WireConnection;153;1;76;1
WireConnection;78;0;196;0
WireConnection;78;1;76;2
WireConnection;63;0;201;0
WireConnection;79;0;153;0
WireConnection;79;1;78;0
WireConnection;79;2;80;0
WireConnection;81;0;79;0
WireConnection;65;0;63;0
WireConnection;197;0;65;0
WireConnection;200;0;81;0
WireConnection;82;0;65;0
WireConnection;82;1;81;0
WireConnection;89;0;197;0
WireConnection;89;1;88;0
WireConnection;83;0;200;0
WireConnection;83;1;88;0
WireConnection;90;0;89;0
WireConnection;90;1;83;0
WireConnection;91;0;82;0
WireConnection;92;0;90;0
WireConnection;92;1;91;0
WireConnection;199;0;92;0
WireConnection;94;0;199;0
WireConnection;94;1;93;0
WireConnection;95;0;94;0
WireConnection;95;1;96;0
WireConnection;37;3;36;0
WireConnection;102;0;95;0
WireConnection;102;1;103;1
WireConnection;102;2;103;2
WireConnection;104;0;102;0
WireConnection;104;1;105;1
WireConnection;104;2;105;2
WireConnection;38;0;37;0
WireConnection;38;1;39;0
WireConnection;110;0;104;0
WireConnection;110;2;108;0
WireConnection;110;4;109;0
WireConnection;40;0;38;0
WireConnection;114;0;104;0
WireConnection;114;2;106;0
WireConnection;114;4;107;0
WireConnection;112;0;110;0
WireConnection;112;1;111;1
WireConnection;112;2;111;2
WireConnection;116;0;114;0
WireConnection;116;1;112;0
WireConnection;116;2;113;0
WireConnection;118;0;116;0
WireConnection;118;1;117;1
WireConnection;118;2;117;2
WireConnection;121;0;120;0
WireConnection;48;3;47;0
WireConnection;119;0;118;0
WireConnection;119;1;112;0
WireConnection;119;2;121;0
WireConnection;42;3;41;0
WireConnection;123;0;125;0
WireConnection;123;1;124;0
WireConnection;123;2;119;0
WireConnection;45;0;43;0
WireConnection;45;1;42;0
WireConnection;45;2;44;0
WireConnection;51;0;50;0
WireConnection;51;1;48;0
WireConnection;51;2;49;0
WireConnection;46;0;45;0
WireConnection;52;0;51;0
WireConnection;126;0;123;0
WireConnection;126;1;127;0
WireConnection;98;0;97;0
WireConnection;99;0;98;0
WireConnection;130;1;126;0
WireConnection;135;0;130;0
WireConnection;135;1;133;0
WireConnection;135;2;134;0
WireConnection;100;0;90;0
WireConnection;100;1;92;0
WireConnection;100;2;99;0
WireConnection;198;0;135;0
WireConnection;101;0;100;0
WireConnection;139;0;138;0
WireConnection;136;0;198;0
WireConnection;136;1;137;0
WireConnection;144;0;141;0
WireConnection;144;1;145;0
WireConnection;140;0;136;0
WireConnection;140;1;139;0
WireConnection;146;0;144;0
WireConnection;64;0;63;0
WireConnection;216;0;214;0
WireConnection;216;1;218;3
WireConnection;202;0;140;0
WireConnection;150;0;140;0
WireConnection;150;1;151;0
WireConnection;218;0;146;0
WireConnection;185;0;202;0
WireConnection;185;2;150;0
WireConnection;185;4;149;0
WireConnection;185;8;146;0
ASEEND*/
//CHKSM=90A6C9856EF1EAEB8986A334A5722E0D903BA722