Shader "smoke/0_smoke"
{
    //TODO: Perlin Texture を読み込んで使用する。それを、UV 座標と合わせて使用する
    Properties
    {
        /* NOTE: ① Propertiesブロックでテクスチャを宣言
            _PerlinTexture      変数名（内部で使用）
            "Perlin Texture"    Inspector上での表示名
            2D                  テクスチャの種類（2D画像）
            = "white"           デフォルト値 → 白色テクスチャ (1, 1, 1, 1)
            {}                  追加オプション（通常は空）
        */
        _PerlinTexture ("Perlin Texture", 2D) = "white" {}
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
            // Pass Commands（パスコマンド）
            // 1. Pass Metadata（メタデータ) → Pass自体の識別情報
            Name "ForwardUnlit"
            Tags { "LightMode"="UniversalForward" }
            // 2. Render State Commands（レンダーステートコマンド）→ レンダリングの動作を制御する設定
            Cull Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            /*NOTE: SAMPLER(sampler_PerlinTexture)
                「テクスチャの読み取り方法」を宣言 しています。
                サンプラーが持つ設定：
                    設定説明例Filter Modeピクセル間の補間方法Point（補間なし）/
                    Bilinear（線形補間）/
                    TrilinearWrap ModeUV座標が0〜1の範囲外の時の動作Repeat（繰り返し）/
                    Clamp（端を延長）/
                    MirrorAnisotropic斜めから見た時の品質1〜16

                Unity の便利機能:
                    sampler_ + テクスチャ名 とすることで、Unity が 自動的にテクスチャの
                    Import Settings を適用してくれる
                例）_PerlinTexture → sampler_PerlinTexture

                Three.js では、uniform sampler2D uPerlinTexture → テクスチャ + サンプリング設定が一体
            */
            // ② テクスチャとサンプラーの宣言（Three.jsのuniform sampler2Dに相当）
            TEXTURE2D(_PerlinTexture);          // テクスチャの宣言 → 画像のピクセルデータ（色情報）を保持
            SAMPLER(sampler_PerlinTexture);     // サンプラーの宣言 → テクスチャのサンプリング方法（フィルタリング、ラッピングなど）を保持

            /*NOTE: ③ _ST : テクスチャのUV変換行列
                ST = Scale & Translation（拡大縮小と移動）の略
                _PerlinTexture_ST
                _PerlinTexture というテクスチャの
                S(=U) T(=V) 軸の Scale(拡大縮小)、Offset(平行移動) 情報を持つ

                Unity が自動的に用意してくれる
                    例）_MainTex → _MainTex_ST
                .xy = Tiling（スケール）
                .zw = Offset（オフセット）

                Three.js では、uniform vec4 uPerlinTexture_ST; として自分で用意する必要がある
            */
            /*NOTE: CBUFFER_START / CBUFFER_END
                CBUFFER = Constant Buffer（定数バッファ）
                GPUに効率的にデータを送るための「データのまとまり」です。
                🤔 なぜ CBUFFER が必要？
            理由1: SRP Batcher との互換性
                Unity の SRP Batcher（Scriptable Render Pipeline Batcher）は描画を高速化する仕組み。
                SRP Batcher が有効に働く条件:
                    マテリアルのプロパティが CBUFFER_START(UnityPerMaterial) 内に宣言されている
                    すべてのマテリアルで同じ CBUFFER 構造を持つ
            理由2: GPU メモリ転送の最適化
                CBUFFERでまとめると、GPUへのデータ転送が1回で済むため、パフォーマンスが向上する

            何を CBUFFER に入れるか？
                値型プロパティ（Value-type Properties）
                    float, int, bool, vector, matrix などの値型プロパティは CBUFFER に入れる
            含まないもの
                リソース型プロパティ（Resource-type）→ CBUFFER に入れない
                    テクスチャ、サンプラー、キューブマップなどのリソース型プロパティは CBUFFER に入れない
            */
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
                // UV変換行列を使って、UV座標を変換する tile と offset を適用する
                float2 smokeUV = i.uv * _PerlinTexture_ST.xy + _PerlinTexture_ST.zw;

                // ④ SAMPLE_TEXTURE2D → SAMPLE_TEXTURE2D は その座標のピクセルのRGBA色 を返す
                float4 color = SAMPLE_TEXTURE2D(
                    _PerlinTexture,         // 第1引数: どのテクスチャを読むか
                    sampler_PerlinTexture,  // 第2引数: どうやって読むか（Filter, Wrap等）
                    smokeUV                 // 第3引数: どのUV座標で読むか
                );
                float smoke = color.r;
                half4 col = half4(smoke, smoke, smoke, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
