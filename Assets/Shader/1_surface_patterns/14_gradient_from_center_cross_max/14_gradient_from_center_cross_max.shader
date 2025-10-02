Shader "patterns/14_gradient_from_center_cross_max"
{
    Properties
    {
        _Offset("Offset", Range(0.0, 1.0)) = 0.5
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

            half _Offset;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            //ref: https://claude.ai/public/artifacts/b234980c-44b5-4220-baec-0707565c9cda
            half4 frag (v2f i) : SV_Target
            {
                half strengthX = abs(i.uv.x - _Offset);
                half strengthY = abs(i.uv.y - _Offset);

                half minStrength = max(strengthX, strengthY);

                half4 col = half4(minStrength, minStrength, minStrength, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
