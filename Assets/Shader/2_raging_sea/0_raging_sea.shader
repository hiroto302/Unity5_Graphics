Shader "Sea/0_raging_sea"
{
    Properties
    {
        _BigWaveFrequencyX("Big Wave Frequency X", Range(1.0, 10.0)) = 4.0
        _BigWaveFrequencyZ("Big Wave Frequency Z", Range(1.0, 10.0)) = 1.5
        _BigWaveElevation("Big Wave Elevation", Range(1.0, 5.0)) = 2.0
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

            float _BigWaveFrequencyX;
            float _BigWaveFrequencyZ;

            v2f vert (appdata i)
            {
                v2f o;
                float3 worldPos = TransformObjectToWorld(i.vertex.xyz);
                float elevation = sin(worldPos.x * _BigWaveFrequencyX) *
                                    sin(worldPos.z * _BigWaveFrequencyZ) *
                                    1.0;

                worldPos.y += elevation;

                o.vertex = TransformWorldToHClip(worldPos);
                o.uv = i.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = half4(i.uv.x, i.uv.y, 1.0, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
