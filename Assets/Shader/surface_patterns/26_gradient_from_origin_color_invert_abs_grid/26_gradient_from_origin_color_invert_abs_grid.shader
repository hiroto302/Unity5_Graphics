Shader "patterns/26_gradient_from_origin_color_invert_abs_grid"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _InvertBase("InvertBase", Range(0.0, 1.0)) = 0.5
        _Grid("Grid", Range(0.0, 10.0)) = 5.0
        
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

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //NOTE:
                // 指定した原点からの距離（ユークリッド距離）を計算してグラデーション色を形成し、色を反転
                // _InvertBase の値が距離の最大値となり、distance の結果が最大値を超えた場合は 0.0(負の値は自動で0となる) となり、黒色になる
                // abs() を利用して、負の値を正の値に変換する
                // fmod() を利用して、グリッドパターンを形成
                float strength = abs(_InvertBase - distance(float2(_OriginX, _OriginY), i.uv));
                float strengthGrid = fmod(strength * _Grid, 1.0);
                half4 col = half4(strengthGrid, strengthGrid, strengthGrid, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
