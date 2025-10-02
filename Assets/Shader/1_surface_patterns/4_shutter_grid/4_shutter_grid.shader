Shader "patterns/4_shutter_grid"
{
    Properties
    {
        /* NOTE: Propertiesについて
        Properties(属性 オプション):
            実行時に変更可能なパラメータを定義
            Material Inspectorに表示される設定
            例: 色、テクスチャ、数値スライダー等

        宣言の形式
            [optional: attribute] name("display text in Inspector", type name) = default value
        */

        /* Properties で使用可能なデータ型
            Float浮動小数点数
                _Value("Value", Float) = 1.0
            Range範囲指定付き浮動小数点数
                _Range("Range", Range(0.0, 1.0)) = 0.5
            Int整数
                _Count("Count", Int) = 5
            Colorカラー
                _Color("Color", Color) = (1,1,1,1)
            Vectorベクター
                _Offset("Offset", Vector) = (0,0,0,0)
            2Dテクスチャ
                _MainTex("Texture", 2D) = "white" {}
            など
        参考: https://docs.unity3d.com/ja/current/Manual/SL-Properties.html
        */
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

            // Propertiesで定義した変数を参照するための宣言
            // 内部変数宣言: シェーダー内で使用するために必須
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
                half strength = fmod(i.uv.y * _Grid, 1.0);
                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
