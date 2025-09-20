Shader "patterns/10_grid_cross"
{
    Properties
    {
        _Grid("Grid", Range(0.0, 10.0)) = 10.0
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

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half spaceX = 0.4;
                half spaceY = 0.8;

                // 横方向の線
                half strengthX = step(spaceX, fmod(i.uv.x * _Grid, 1.0));
                strengthX *= step(spaceY, fmod(i.uv.y * _Grid + spaceX * 0.5, 1.0));

                // 縦方向の線
                half strengthY = step(spaceY, fmod(i.uv.x * _Grid + spaceX * 0.5 , 1.0));
                strengthY *= step(spaceX, fmod(i.uv.y * _Grid , 1.0));

                // 組み合わせることでクロス模様にする
                half combination = strengthX + strengthY;

                half4 col = half4(combination, combination, combination, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
