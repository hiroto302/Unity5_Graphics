Shader "patterns/8_grid_square"
{
    Properties
    {
        _Grid("Grid", Range(0.0, 10.0)) = 10.0
        _EdgeX("EdgeX", Range(0.0, 1.0)) = 0.2
        _EdgeY("EdgeY", Range(0.0, 1.0)) = 0.8
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
            half _EdgeX;
            half _EdgeY;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {

                half strengthX = step(_EdgeX, fmod(i.uv.x * _Grid, 1.0));
                half strengthY = step(_EdgeY, fmod(i.uv.y * _Grid, 1.0));

                half combination = strengthX * strengthY;

                half4 col = half4(combination, combination, combination, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
