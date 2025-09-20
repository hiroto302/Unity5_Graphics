/*
    step(edge, x) :
        x < edge の場合 → 0.0 を返す
        x >= edge の場合 → 1.0 を返す
*/
Shader "patterns/5_shutter_grid_solid"
{
    Properties
    {
        _Grid("Grid", Range(0.0, 10.0)) = 10.0
        _Edge("Edge", Range(0.0, 1.0)) = 0.8
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            half _Grid;
            half _Edge;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half strength = fmod(i.uv.y * _Grid, 1.0);
                strength = step(_Edge, strength);
                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
