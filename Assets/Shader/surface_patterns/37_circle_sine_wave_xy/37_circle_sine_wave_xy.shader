Shader "patterns/37_circle_sine_wave_xy"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _InvertBase("InvertBase", Range(0.0, 1.0)) = 0.25
        _WaveFrequency("WaveFrequency", Range(0.0, 200.0)) = 30.0
        _WaveHeight("WaveHeight", Range(0.0, 0.5)) = 0.1
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
            float _WaveFrequency;
            float _WaveHeight;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 wavedUv = float2(
                    i.uv.x + sin(i.uv.y * _WaveFrequency) * _WaveHeight,  // 横方向にsin波を連続で反映させる
                    i.uv.y + sin(i.uv.x * _WaveFrequency) * _WaveHeight    // 縦方向にsin波を連続で反映させる
                );
                float strength = 1.0 - step(0.01, abs(_InvertBase - distance(float2(_OriginX, _OriginY), wavedUv)));
                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
