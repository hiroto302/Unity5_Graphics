Shader "patterns/18_gradient_color_separate_x2"
{
    Properties
    {
        _Separate("Separate", Range(0, 10)) = 10
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

            half _Separate;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half strengthX = floor(i.uv.x * _Separate) / _Separate;
                half strengthY = floor(i.uv.y * _Separate) / _Separate;

                half combination = strengthX * strengthY;

                half4 col = half4(combination, combination, combination, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
