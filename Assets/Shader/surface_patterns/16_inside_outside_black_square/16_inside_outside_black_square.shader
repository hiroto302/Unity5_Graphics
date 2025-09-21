Shader "patterns/16_inside_outside_black_square"
{
    Properties
    {
        _Offset("Offset", Range(0.0, 1.0)) = 0.5
        _insideThreshold("Inside Threshold", Range(0.0, 0.2)) = 0.2
        _outsideThreshold("Outside Threshold", Range(0.25, 1.0)) = 0.25
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

            half _Offset;
            half _insideThreshold;
            half _outsideThreshold;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            //NOTE:
            // 白いリング パターン (15とは実装の考えが全くちがうことに注意)
            // square1 = step(0.2, distance) → 距離0.2以上の時1.0、未満の時は0.0
            // square2 = 1.0 - step(0.25, distance) → 距離0.25未満の時1.0、以上の時は0.0
            // strength = square1 * square2 → 両方が1.0の範囲のみ白 (0.2 ~ 0.25 の中心からの距離のみ箇所)
            half4 frag (v2f i) : SV_Target
            {
                half insideBlackSquare = step(_insideThreshold, max(abs(i.uv.x - _Offset), abs(i.uv.y - _Offset)));
                half outsideWhiteSquare = 1.0 - step(_outsideThreshold, max(abs(i.uv.x - _Offset), abs(i.uv.y - _Offset)));
                half strength = insideBlackSquare * outsideWhiteSquare;

                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
