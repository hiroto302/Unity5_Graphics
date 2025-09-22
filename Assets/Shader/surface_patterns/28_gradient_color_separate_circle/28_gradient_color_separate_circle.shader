Shader "patterns/27_gradient_from_origin_color_invert_abs_grid_solid"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _InvertBase("InvertBase", Range(0.0, 1.0)) = 1.0
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

            float _OriginX;
            float _OriginY;
            float _InvertBase;
            float _Grid;
            float _Edge;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float strength = abs(_InvertBase - distance(float2(_OriginX, _OriginY), i.uv));
                float strengthSeparate = floor(strength * _Grid) / _Grid;
                half4 col = half4(strengthSeparate, strengthSeparate, strengthSeparate, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
