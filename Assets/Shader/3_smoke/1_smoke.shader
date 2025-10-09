Shader "smoke/1_smoke"
{
    Properties
    {
        _PerlinTexture ("Perlin Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            /*NOTE: ① 透明オブジェクトとして扱うためのタグ設定
                "RenderType"="Transparent"  レンダリングパイプラインに透明オブジェクトとして認識させる
                "Queue"="Transparent"  透明オブジェクトを後から描画
                Background → Geometry → AlphaTest → Transparent → Overlay
                参考: https://docs.unity3d.com/ja/current/Manual/SL-SubShaderTags.html

                そもそも、Queue
                    Queue（キュー）= オブジェクトを描画する順番
                    Unity は画面に描画する際、すべてのオブジェクトを Queue の番号順に並べて描画する

                Material Inspector の "Render Queue" との関係
                    "Render Queue" は Queue の番号を直接指定できる
                    "Render Queue" を "From Shader" にすると、Shader のタグ設定に従う
                    "Render Queue" を "Transparent" にすると、Queue=3000 になる
                    Render Queue
                        ├─ From Shader    ← シェーダーの Queue 設定を使用
                        ├─ Geometry       ← 2000（不透明）
                        ├─ AlphaTest      ← 2450（切り抜き）
                        ├─ Transparent    ← 3000（透明）
                        └─ (カスタム値)    ← 手動で数値指定も可能

                参考: https://docs.unity3d.com/ja/current/Manual/MaterialsAccessingViaScript.html
            */
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode"="UniversalForward" }

            Cull Off

            /* NOTE: ② 透過用の Render State 設定
                Blend SrcAlpha OneMinusSrcAlpha
                    アルファブレンドィングを有効化 → 透明度に応じた色の合成
                ZWrite Off
                    深度バッファへの書き込みを無効化 → 奥のオブジェクトが見えるようにする
                ZTest LEqual
                    深度テストは行う（デフォルト値）

                まとめると、
                    ZTest（読む） と ZWrite（書く） は別の処理
                    透明オブジェクトは不透明オブジェクトの深度バッファを読んで比較する
                    でも自分の深度は書き込まない（ZWrite Off）ので、後ろの透明オブジェクトも見える

                参考: https://docs.unity3d.com/ja/current/Manual/SL-Blend.html
            */
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_PerlinTexture);
            SAMPLER(sampler_PerlinTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _PerlinTexture_ST;
            CBUFFER_END

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

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 smokeUV = i.uv * _PerlinTexture_ST.xy + _PerlinTexture_ST.zw;

                float4 color = SAMPLE_TEXTURE2D(
                    _PerlinTexture,
                    sampler_PerlinTexture,
                    smokeUV
                );
                float smoke = color.r;
                // ③ smoke の値をアルファ値に使う
                half4 col = half4(1.0, 1.0, 1.0, smoke);
                return col;
            }
            ENDHLSL
        }
    }
}
