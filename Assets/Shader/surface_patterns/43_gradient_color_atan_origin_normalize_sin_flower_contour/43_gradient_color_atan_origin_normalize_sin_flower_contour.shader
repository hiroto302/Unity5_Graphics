Shader "patterns/43_gradient_color_atan_origin_normalize_sin_flower"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _WaveFrequency("WaveFrequency", Range(10.0, 200.0)) = 100.0
        _WaveAmplitude("WaveAmplitude", Range(0.0, 1.0)) = 0.2
        _BaseRadius("BaseRadius", Range(0.0, 1.0)) = 0.25
        _LineThreshold("LineThreshold", Range(0.01, 0.2)) = 0.01
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
            float _WaveFrequency;
            float _WaveAmplitude;
            float _BaseRadius;
            float _LineThreshold;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // uv は 0 ~ 1 値しか返さない
                // つまり、下記は 0 ~ 180 度の範囲しか陰影の結果を出さない
                // (-0.5しているので、中心点から真下が0スタートで、そこから180度進んだ真上まで反映させている)
                // 結果 -π ~ π の範囲
                float strength = atan2(i.uv.x - _OriginX, i.uv.y - _OriginY);
                // 2π で割って、0-1範囲への正規化。中心点ズレしているのので結果は -0.5 ~ 0.5 となってしまっている
                float normalizedStrength = strength / (PI * 2.0);
                // 正の値へ変換 0~1の範囲 (色の値への適用 0 ~ 1が欲しいから! 負だと黒色になるだけ)
                normalizedStrength += 0.5;

                // 正弦波による半径変化の計算
                float sinusoid = sin(normalizedStrength * _WaveFrequency);
                // 花弁を表現する点の位置(輪郭距離)の計算
                float radius = _BaseRadius + sinusoid * _WaveAmplitude;

                // === finalStrength の段階的分解 ===
                // Step 1: 中心からの距離を計算
                float pixelDistance = distance(i.uv, float2(_OriginX, _OriginY));
                // Step 2: 実際の距離と理想的な半径の差を計算
                float distanceDifference = pixelDistance - radius;

                // 半径との差を可視化（グレーが境界線、白黒が内外）
                half4 col = half4(distanceDifference + 0.5, distanceDifference + 0.5, distanceDifference + 0.5, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
