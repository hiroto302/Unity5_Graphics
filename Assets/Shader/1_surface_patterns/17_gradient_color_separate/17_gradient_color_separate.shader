Shader "patterns/17_gradient_color_separate"
{
    Properties
    {
        _Separate("Separate", Range(0, 10)) = 10
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

            half _Separate;

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            /*
            floor(x) : 切り捨て
                x が 0.8 の時は、0を返す
                x が 1.2 の時は、1.0を返す
                x が -0.2 の時は、-1.0を返す

            uv.x の値は 0.0 ~ 1.0の値を返す。それらの値を10倍にしたものをfloorすると 1 ~ 10 の第一小数点以下が無いものだけになる
            上記の値を 10 で割ることで、 0, 0.1, 0.2 ...0.9 の 10種類の値だけが取得可能となる

            例えば _Separate = 10 の場合
                uv.x の値が 0.0 ~ 0.1 の時は 0.0
                uv.x の値が 0.1 ~ 0.2 の時は 0.1
                uv.x の値が 0.2 ~ 0.3 の時は 0.2
                ...(中略)...
                uv.x の値が 0.9 ~ .99 の時は 0.9
            */

            half4 frag (v2f i) : SV_Target
            {
                half strength = floor(i.uv.x * _Separate) / _Separate;
                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
