Shader "patterns/30_gradient_color_center_point_step"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _whiteThreshold("whiteThreshold", Range(0.0, 0.1)) = 0.015
        _cutoffThreshold("cutoffThreshold", Range(0.0, 0.5)) = 0.1
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
            float _whiteThreshold;
            float _cutoffThreshold;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }
            /* NOTE: 反比例関数（逆数関数）の変化でグラデーションを作成
                y = k/x （kは定数）
                変化の特徴：
                    中心付近（distance が小さい）: 急激な変化
                    遠い場所（distance が大きい）: 緩やかな変化

                中心点(origin)から離れる程、値が小さくなる
                distance = 0.015 のとき → strength = 0.015 / 0.015 = 1.0（白色）
                distance = 0.03 のとき → strength = 0.015 / 0.03 = 0.5（グレー）
                distance = 0.15 のとき → strength = 0.015 / 0.15 = 0.1（暗いグレー）

                whiteThreshold = 0.015 としているのは、
                つまり、中心から0.015の距離にある点が白色（1.0）になるように調整しているめ。
                UV座標では画面全体が0.0〜1.0なので、0.015という距離は画面の約1.5%の位置。
                かなり中心に近い小さな範囲だけが明るく光り、そこから急激に暗くなっていく効果を作成。

                ref: https://claude.ai/share/10bf42f8-69d1-4e3d-bc1f-7f5265ed0e96
            */
            half4 frag (v2f i) : SV_Target
            {
                float2 origin = float2(_OriginX, _OriginY);
                float strength = _whiteThreshold / distance(origin, i.uv);
                // step関数で strength が 0.1 以下の値を0.0にして完全に黒にする
                // strength が 0.1 以下 → 0.0
                // strength が 0.1 以上 → 1.0
                strength = step(_cutoffThreshold, strength) * strength;

                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
