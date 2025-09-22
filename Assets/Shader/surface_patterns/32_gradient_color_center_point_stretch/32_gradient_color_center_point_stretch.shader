Shader "patterns/32_gradient_color_center_point_stretch"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _WhiteThreshold("WhiteThreshold", Range(0.0, 0.1)) = 0.015
        _StretchX("StretchX", Range(0.0, 1.0)) = 0.1
        _StretchY("StretchY", Range(0.0, 1.0)) = 0.5
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


            float _StretchX;
            float _StretchY;
            float _OriginX;
            float _OriginY;
            float _WhiteThreshold;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                /* NOTE: uv座標をストレッチさせる
                    元のUV座標 (0.0～1.0の範囲)
                    stretchX 0.1, stretchY 0.5 の場合
                    UV座標のX成分を1/10に縮める
                    UV座標のY成分を1/2に縮める
                    distance(origin, lightUv) で圧縮されたUV座標との距離を測る

                offsetを加えることで、中心点をずらすことができる
                元のUV座標→ 圧縮されたUV座標
                    (0.0, 0.5) → (0.0, 0.25)  // 左端
                    (0.5, 0.5) → (0.05, 0.25) // 中央 ← ズレてる！
                    (1.0, 0.5) → (0.1, 0.25)  // 右端
                */

                float2 origin = float2(_OriginX, _OriginY);

                float offsetX = origin.x - _StretchX * _OriginX;
                float offsetY = origin.y - _StretchY * _OriginY;

                float2 lightUv = float2(
                    i.uv.x * _StretchX + offsetX,
                    i.uv.y * _StretchY + offsetY
                );

                float strength = _WhiteThreshold / distance(origin, lightUv);

                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
