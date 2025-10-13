Shader "smoke/3_smoke"
{
    Properties
    {
        _PerlinTexture ("Perlin Texture", 2D) = "white" {}

        _TwistStrength ("Twist Strength", Range(0.0, 1.0)) = 0.2
        _AngleScale ("Angle Scale", Range(1.0, 20.0)) = 10.0
        _SmokeVerticesSpeed ("Smoke Vertices Speed", Range(0.0, 0.1)) = 0.005
        _WindSpeed ("Wind Speed", Range(0.00, 1.00)) = 0.10

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
            // POINT: ZWrite Off にすること！
                // three.js の depthWrite: false に相当
                // https://threejs.org/docs/#api/en/materials/Material.depthWrite
                // 透明部分同士の重なり順を考慮しないので、煙をTwistさせた時、自身の背後に回り込んだ部分が消えてしまうを防ぐことができる
                // ただし、他のオブジェクトとの重なり順は正しく描画される
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shader/Includes/Rotate2D.hlsl"

            TEXTURE2D(_PerlinTexture);
            SAMPLER(sampler_PerlinTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _PerlinTexture_ST;
                float _SmokeFragmentSpeed;
                float _TwistStrength;
                float _AngleScale;
                float _SmokeVerticesSpeed;
                float _WindSpeed;
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

                float time = _Time.y;

                // Twist with Perlin Noise
                float3 newPosition = input.vertex.xyz;
                float twistPerlin = SAMPLE_TEXTURE2D_LOD(_PerlinTexture,
                                                        sampler_PerlinTexture,
                                                        float2(0.5, input.uv.y * _TwistStrength - time * _SmokeVerticesSpeed),
                                                        0)
                                                        .r;
                float angle = twistPerlin * _AngleScale;
                newPosition.xy = rotate2D(newPosition.xy, angle);

                // POINT: 参照するPerlinNoise Textureのo sRGBのの設定は必ずOFFにすること! → ガンマ補正を受けないようにするため
                // この設定を忘れると、Widnowの値が0~1の間でなくなり、煙が変な動きをする

                // Wind
                // ① 参照するUVを変化させていく
                float2 windOffset = float2(
                    SAMPLE_TEXTURE2D_LOD(
                        _PerlinTexture,
                        sampler_PerlinTexture,
                        float2(0.25, time * _WindSpeed),
                        0
                    ).r - 0.5,  // -0.5 ~ 0.5 の値を取得するために -0.5する
                    SAMPLE_TEXTURE2D_LOD(
                        _PerlinTexture,
                        sampler_PerlinTexture,
                        float2(0.75, time * _WindSpeed),
                        0
                    ).r - 0.5
                );
                // ② 風の影響を調整する。
                    // y座標が上がるほど風の影響を大きくする
                    // pow で y座標が上がるほど影響を大きくする
                    // さらに *10.0 で全体の影響を大きくする
                windOffset *= pow(input.uv.y, 4.0) * 10.0;

                // ③ 頂点座標に風の影響を加える
                newPosition.xy += windOffset;

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

                half4 col = half4(i.uv, 1.0, smoke);
                // half4 col = half4(1.0, 0.0, 0.0, 1.0);
                return col;
            }
            ENDHLSL
        }
    }
}
