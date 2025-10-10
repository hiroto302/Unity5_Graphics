Shader "smoke/2_smoke"
{
    Properties
    {
        _PerlinTexture ("Perlin Texture", 2D) = "white" {}
        _SmokeSpeed ("Smoke Speed", Range(0.0, 0.5)) = 0.03
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Name "ForwardUnlit"
            Tags { "LightMode"="UniversalForward" }

            Cull Off

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
                float _SmokeSpeed;
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
                float time = _Time.y;

                float2 smokeUV = i.uv * _PerlinTexture_ST.xy + _PerlinTexture_ST.zw;

                // ① animation
                smokeUV.y -= time * _SmokeSpeed;

                float4 color = SAMPLE_TEXTURE2D(
                    _PerlinTexture,
                    sampler_PerlinTexture,
                    smokeUV
                );
                float smoke = color.r;

                // ② remap
                smoke = smoothstep(0.2, 0.7, smoke);

                // ③ fade edges
                //POINT: smokeUV はTilingの影響を受けるので、元のUVでフェードさせる
                smoke *= smoothstep(0.0, 0.1, i.uv.x);
                smoke *= smoothstep(1.0, 0.9, i.uv.x);
                smoke *= smoothstep(0.0, 0.1, i.uv.y);
                smoke *= smoothstep(1.0, 0.4, i.uv.y);

                half4 col = half4(1.0, 1.0, 1.0, smoke);
                return col;
            }
            ENDHLSL
        }
    }
}
