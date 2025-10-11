Shader "smoke/3_smoke"
{
    Properties
    {
        _PerlinTexture ("Perlin Texture", 2D) = "white" {}

        _TwistStrength ("Twist Strength", Range(0.0, 1.0)) = 0.2
        _AngleScale ("Angle Scale", Range(1.0, 20.0)) = 10.0
        _SmokeVerticesSpeed ("Smoke Vertices Speed", Range(0.0, 0.1)) = 0.001

        _SmokeFragmentSpeed ("Smoke Fragment Speed", Range(0.0, 0.5)) = 0.03
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
                float _SmokeFragmentSpeed;
                float _TwistStrength;
                float _AngleScale;
                float _SmokeVerticesSpeed;
            CBUFFER_END

            float2 rotate2D(float2 uv, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float2x2 rotMatrix = float2x2(c, -s, s, c);
                return mul(rotMatrix, uv);
            }

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

                float time = _Time.y;

                // ① シンプルなZ軸回転
                    // Three.jsとは、生成したPlane のローカル座標が異なることに注意
                    // Unity の場合、Plane をZ軸を中心に回転させる必要がある
                // float3 newPosition = input.vertex.xyz;
                // float angle = newPosition.z;
                // newPosition.xy = rotate2D(newPosition.xy, angle);

                // ② Twist with Perlin Noise
                float3 newPosition = input.vertex.xyz;
                float twistPerlin = SAMPLE_TEXTURE2D_LOD(_PerlinTexture,
                                                        sampler_PerlinTexture,
                                                        float2(0.5, input.uv.y * _TwistStrength - time * _SmokeVerticesSpeed),
                                                        0)
                                                        .r;
                float angle = twistPerlin * _AngleScale;
                newPosition.xy = rotate2D(newPosition.xy, angle);


                o.vertex = TransformObjectToHClip(newPosition);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float time = _Time.y;

                float2 smokeUV = i.uv * _PerlinTexture_ST.xy + _PerlinTexture_ST.zw;

                smokeUV.y -= time * _SmokeFragmentSpeed;

                float4 color = SAMPLE_TEXTURE2D(
                    _PerlinTexture,
                    sampler_PerlinTexture,
                    smokeUV
                );
                float smoke = color.r;

                smoke = smoothstep(0.2, 0.7, smoke);

                smoke *= smoothstep(0.0, 0.1, i.uv.x);
                smoke *= smoothstep(1.0, 0.9, i.uv.x);
                smoke *= smoothstep(0.0, 0.1, i.uv.y);
                smoke *= smoothstep(1.0, 0.4, i.uv.y);

                // half4 col = half4(1.0, 1.0, 1.0, smoke);
                half4 col = half4(1.0, 0.0, 0.0, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
