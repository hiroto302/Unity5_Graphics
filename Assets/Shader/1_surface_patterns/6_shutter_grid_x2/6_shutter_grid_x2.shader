Shader "patterns/6_shutter_grid_x2"
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

                half strengthX = step(_Edge, fmod(i.uv.x * _Grid, 1.0));
                half strengthY = step(_Edge, fmod(i.uv.y * _Grid, 1.0));

                half combination = strengthX + strengthY;

                half4 col = half4(combination, combination, combination, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
