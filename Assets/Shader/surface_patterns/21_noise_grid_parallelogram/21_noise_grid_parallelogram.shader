Shader "patterns/21_noise_grid_parallelogram"
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

            //ref: https://claude.ai/share/cffd4b7c-1b2a-4656-829a-035569ef3cde
            // ランダム関数
            float random(float2 st)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // 平行四辺形にするために、y方向に加算するだけ
                float2 gridUv = float2 (
                    floor(i.uv.x * _Separate) / _Separate,
                    floor((i.uv.y + i.uv.x * 0.5) * _Separate) / _Separate
                );
                float strength = random(gridUv);
                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
