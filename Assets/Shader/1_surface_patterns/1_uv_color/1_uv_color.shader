/* UV座標を色として表示するシェーダー

UV座標とは？
    UV座標は0.0から1.0の範囲で、テクスチャをメッシュにマッピングするための2D座標


Unity の UV 座標系
    左下が (0, 0)
    右下が (1, 0)
    左上が (0, 1)
    右上が (1, 1)
*/


Shader "patterns/1_uv_color"
{
    Properties
    {
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

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = half4(i.uv.x, i.uv.y, 1.0, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
