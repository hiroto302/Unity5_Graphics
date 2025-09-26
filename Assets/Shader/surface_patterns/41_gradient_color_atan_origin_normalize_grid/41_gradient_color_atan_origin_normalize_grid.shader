Shader "patterns/41_gradient_color_atan_origin_normalize_grid"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _Grid("Grid", Range(1.0, 20.0)) = 10.0
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
            float _Grid;

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

                normalizedStrength = fmod(normalizedStrength * _Grid, 1.0);

                half4 col = half4(normalizedStrength, normalizedStrength, normalizedStrength, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
