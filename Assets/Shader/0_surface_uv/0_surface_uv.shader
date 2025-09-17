//Ref: https://claude.ai/share/4351ebb4-964e-4582-831f-9fdc6cbb0271
Shader "Custom/0_surface_uv"
{
    Properties
    {
        // 実行時に変更可能なパラメータ
        // Material Inspectorに表示される設定
    }
    SubShader
    {
        /* SubShader における Tags について
        Tags(属性 必須):
            Unity側への情報提供（このシェーダーはどんな種類か）
            置換シェーダーでの識別
            レンダリング順序の判定材料
        */
        Tags
        {
            "RenderType"="Opaque"                   // シェーダーの分類 (ここでは、不透明オブジェクトであることを宣言)
            "RenderPipeline"="UniversalPipeline"    // Universal Render Pipeline であることを宣言
        }
        /* NOTE: Passについて
        GPU上での1回の描画処理を表す
        (GPUの視点
            1回のフレーム描画 = 複数のPassの実行
            各Pass = 頂点シェーダー + フラグメントシェーダーの1セット
        )
        一つのシェーダーファイルで複数の役割をこなすため、Passを分けて実装
        Unlit ShaderならUniversalForwardだけでも動作するが、影を落としたい場合はShadowCasterも必要
        参考: https://docs.unity3d.com/ja/current/Manual/SL-SubShaderTags.html
        */
        Pass
        {
            /* NOTE:Pass における Name と Tagsについて

            Name(識別子 オプション):
                Passの識別子（デバッグ用、参照用）
                フレームデバッガーで表示される名前
                他のシェーダーからの参照が可能

            Tags(属性 必須):
                Unity側への指示（いつ、どのように実行するか）
                レンダリングパイプラインが判定に使用
            */
            Name "ForwardUnlit"
            // 「このPassはフォワードレンダリング時に実行してください」「カメラから見える最終画像を計算するPassです」
            Tags { "LightMode"="UniversalForward" }

            // HLSL言語で記述することを宣言
            HLSLPROGRAM

            /* NOTE: #pragma について
            #pragma 指令(オプション 必須):
                シェーダーコンパイラへの指示
                使用するシェーダーステージの指定、ターゲットプラットフォームの指定等
            */
            // Vertex Shader 指定
            // 各頂点で実行される処理をvert関数で定義 → 頂点の座標変換、UV座標の受け渡し等
            #pragma vertex vert
            // Fragment Shader 指定
            // 各ピクセルで実行される処理をfrag関数で定義 → ピクセルの色計算、テクスチャサンプリング等
            #pragma fragment frag

            /* NOTE: #include について
            #include 指令(オプション 必須):
                外部ファイルの内容をインクルード（取り込み）する
                共通関数、定数、マクロ等を再利用可能にする
            */
            /* Universal Render Pipelineのコアライブラリをインクルード
            含まれる主な内容:
            1. 座標変換関数
                TransformObjectToWorld() オブジェクト空間からワールド空間への変換
                TransformWorldToView()   ワールド空間 → ビュー空間
                TransformViewToHClip()   ビュー空間 → クリップ空間
            2. 基本的なマトリクス(行列)変数
                UNITY_MATRIX_M           Model Matrix
                UNITY_MATRIX_V           View Matrix
                UNITY_MATRIX_P           Projection Matrix
                UNITY_MATRIX_VP          View-Projection Matrix
            3. 構造体
                VertexPositionInputs     頂点位置の変換結果
                VertexNormalInputs       法線の変換結果
            など
            */
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            /* Semantics について
            ref: https://docs.unity3d.com/ja/2021.3/Manual/SL-ShaderSemantics.html
            ref: https://claude.ai/share/01420e1f-a004-4486-addf-3ee190bd3ce2
            データの意味をグラフィックスパイプラインに伝える識別子。
            HLSL言語のSemanticsの規約に則り、Unity側が適切にデータを解釈(習得)・処理できるようにする。
            頂点属性セマンティクス:
                POSITION    頂点の位置
                NORMAL      頂点の法線
                TEXCOORD0   頂点のUV座標（複数ある場合はTEXCOORD1, TEXCOORD2...）
                COLOR       頂点カラー
            シェーダーステージ間セマンティクス:
                SV_POSITION    クリップ空間での頂点位置（フラグメントシェーダーに渡される）
                SV_Target      フラグメントシェーダーの出力色
            */

            /* 構造体の命名規則
            基本何でもいけど、わかりやすい名前にすること。ここでは以下のように命名
                頂点入力構造体: Attributes
                頂点出力・フラグメント入力構造体: Varyings (Varying = "変化する"という意味)
            */

            /* :SV_Target について
            Semanticsの一つで、フラグメントシェーダーの出力色を指定するために使用
            役割:
                フラグメントシェーダーの出力をレンダーターゲットに書き込む
                通常は**カラーバッファ（画面）**への出力
            */

            // 頂点入力で使用する構造体
            struct Attributes
            {
                float4 positionOS : POSITION;   // メッシュの各頂点の3D座標(オブジェクト空間)
                float2 uv : TEXCOORD0;          // メッシュに渡されたUV座標(テクスチャ座標）)
            };

            // 頂点出力・フラグメント入力構造体
            struct Varyings
            {
                float4 positionHCS : SV_POSITION;   // クリップ空間の頂点座標
                float2 uv : TEXCOORD0;              // UV座標をフラグメントシェーダーに渡す
            };

            // 頂点シェーダー
            Varyings vert(Attributes input)
            {
                Varyings output;

                // オブジェクト空間からクリップ空間へ変換
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);

                // UV座標をそのまま渡す
                output.uv = input.uv;

                // フラグメントシェーダーへ出力 (output が frag の input に渡される)
                return output;
            }

            // フラグメントシェーダー
            half4 frag(Varyings input) : SV_Target
            {
                // UV座標をRGBとして出力（Z成分は0に設定）
                return half4(input.uv.x, input.uv.y, 0.0, 1.0);
            }

            ENDHLSL
        }
    }

    /* FallBack について
    RenderPipeline、Pipeline のものがSubShaderに無かった場合に使用されるシェーダーを指定
    ピンク/マゼンタ色を表示する専用シェーダー を指定するのが一般的
    参考: https://docs.unity3d.com/ja/current/Manual/SL-Fallback.html
    */
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}