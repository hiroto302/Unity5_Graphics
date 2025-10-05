Shader "Sea/0_raging_sea"
{
    Properties
    {
        // big wave
        _BigWaveFrequencyX("Big Wave Frequency X", Range(1.0, 10.0)) = 4.0
        _BigWaveFrequencyY("Big Wave Frequency Y", Range(1.0, 10.0)) = 1.5
        _BigWaveSpeed("Big Wave Speed", Range(0.0, 3.0)) = 0.75
        _BigWaveElevation("Big Wave Elevation", Range(0.0, 2.0)) = 0.2

        // color
        _DepthColor("Depth Color", Color) = (0.094, 0.4, 0.568, 1.0)
        _SurfaceColor("Surface Color", Color) = (0.608, 0.847, 1.0, 1.0)
        _ColorOffset("Color Offset", Range(-2.0, 2.0)) = 0.25
        _ColorMultiplier("Color Multiplier", Range(0.0, 10.0)) = 5.0


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
                float elevation: TEXCOORD1;
            };

            float _BigWaveFrequencyX;
            float _BigWaveFrequencyY;
            float _BigWaveSpeed;
            float _BigWaveElevation;

            float4 _DepthColor;
            float4 _SurfaceColor;
            float _ColorOffset;
            float _ColorMultiplier;

            v2f vert (appdata i)
            {
                v2f o;
                float time = _Time.y;

                float3 worldPos = TransformObjectToWorld(i.vertex.xyz);

                float elevation = sin(worldPos.x * _BigWaveFrequencyX + time * _BigWaveSpeed) *
                                    sin(worldPos.z * _BigWaveFrequencyY + time * _BigWaveSpeed) *
                                    _BigWaveElevation;

                worldPos.y += elevation;

                o.vertex = TransformWorldToHClip(worldPos);
                o.elevation = elevation;
                o.uv = i.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //NOTE: 波の高さに応じて色を変える
                float mixStrength = (i.elevation + _ColorOffset) * _ColorMultiplier;

                // カラー グレースケール
                // float3 color = lerp(float3(0.1, 0.1, 0.1), float3(1.0, 1.0, 1.0), mixStrength);

                // カラー
                float3 color = lerp(_DepthColor.rgb, _SurfaceColor.rgb, mixStrength);
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
