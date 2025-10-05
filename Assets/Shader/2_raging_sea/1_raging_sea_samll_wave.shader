Shader "Sea/1_Raging_Sea_Small_Wave"
{
    Properties
    {
        // big wave
        _BigWaveFrequencyX("Big Wave Frequency X", Range(1.0, 10.0)) = 4.0
        _BigWaveFrequencyY("Big Wave Frequency Y", Range(1.0, 10.0)) = 1.5
        _BigWaveSpeed("Big Wave Speed", Range(0.0, 3.0)) = 0.75
        _BigWaveElevation("Big Wave Elevation", Range(0.0, 2.0)) = 0.2

        // color
        _DepthColor("Depth Color", Color) = (0.094, 0.4, 0.568, 1.0)
        _SurfaceColor("Surface Color", Color) = (0.608, 0.847, 1.0, 1.0)
        _ColorOffset("Color Offset", Range(-2.0, 2.0)) = 0.25
        _ColorMultiplier("Color Multiplier", Range(0.0, 10.0)) = 5.0

        // small wave
        _SmallWaveFrequency("Small Wave Frequency", Range(1.0, 10.0)) = 3.0
        _SmallWaveSpeed("Small Wave Speed", Range(0.0, 3.0)) = 0.2
        _SmallWaveElevation("Small Wave Elevation", Range(0.0, 2.0)) = 0.15
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
                float elevation: TEXCOORD1;
            };

            //	Classic Perlin 3D Noise
            //	by Stefan Gustavson (https://github.com/stegu/webgl-noise)
            // このc関数はClassic Perlin 3D Noiseの実装で、Stefan Gustavson氏の有名なwebgl-noiseライブラリから取られています。
            float4 permute(float4 x)
            {
                return fmod(((x * 34.0) + 1.0) * x, 289.0);
            }

            float4 taylorInvSqrt(float4 r)
            {
                return 1.79284291400159 - 0.85373472095314 * r;
            }

            float3 fade(float3 t)
            {
                return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
            }

            float cnoise(float3 P)
            {
                float3 Pi0 = floor(P);
                float3 Pi1 = Pi0 + float3(1.0, 1.0, 1.0);
                Pi0 = fmod(Pi0, 289.0);
                Pi1 = fmod(Pi1, 289.0);
                float3 Pf0 = frac(P);
                float3 Pf1 = Pf0 - float3(1.0, 1.0, 1.0);

                float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
                float4 iy = float4(Pi0.yy, Pi1.yy);
                float4 iz0 = Pi0.zzzz;
                float4 iz1 = Pi1.zzzz;

                float4 ixy = permute(permute(ix) + iy);
                float4 ixy0 = permute(ixy + iz0);
                float4 ixy1 = permute(ixy + iz1);

                float4 gx0 = ixy0 / 7.0;
                float4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
                gx0 = frac(gx0);
                float4 gz0 = float4(0.5, 0.5, 0.5, 0.5) - abs(gx0) - abs(gy0);
                float4 sz0 = step(gz0, float4(0.0, 0.0, 0.0, 0.0));
                gx0 -= sz0 * (step(0.0, gx0) - 0.5);
                gy0 -= sz0 * (step(0.0, gy0) - 0.5);

                float4 gx1 = ixy1 / 7.0;
                float4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
                gx1 = frac(gx1);
                float4 gz1 = float4(0.5, 0.5, 0.5, 0.5) - abs(gx1) - abs(gy1);
                float4 sz1 = step(gz1, float4(0.0, 0.0, 0.0, 0.0));
                gx1 -= sz1 * (step(0.0, gx1) - 0.5);
                gy1 -= sz1 * (step(0.0, gy1) - 0.5);

                float3 g000 = float3(gx0.x, gy0.x, gz0.x);
                float3 g100 = float3(gx0.y, gy0.y, gz0.y);
                float3 g010 = float3(gx0.z, gy0.z, gz0.z);
                float3 g110 = float3(gx0.w, gy0.w, gz0.w);
                float3 g001 = float3(gx1.x, gy1.x, gz1.x);
                float3 g101 = float3(gx1.y, gy1.y, gz1.y);
                float3 g011 = float3(gx1.z, gy1.z, gz1.z);
                float3 g111 = float3(gx1.w, gy1.w, gz1.w);

                float4 norm0 = taylorInvSqrt(float4(
                    dot(g000, g000), dot(g010, g010),
                    dot(g100, g100), dot(g110, g110)
                ));
                g000 *= norm0.x;
                g010 *= norm0.y;
                g100 *= norm0.z;
                g110 *= norm0.w;

                float4 norm1 = taylorInvSqrt(float4(
                    dot(g001, g001), dot(g011, g011),
                    dot(g101, g101), dot(g111, g111)
                ));
                g001 *= norm1.x;
                g011 *= norm1.y;
                g101 *= norm1.z;
                g111 *= norm1.w;

                float n000 = dot(g000, Pf0);
                float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
                float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
                float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
                float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
                float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
                float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
                float n111 = dot(g111, Pf1);

                float3 fade_xyz = fade(Pf0);
                float4 n_z = lerp(
                    float4(n000, n100, n010, n110),
                    float4(n001, n101, n011, n111),
                    fade_xyz.z
                );
                float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
                float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
                return 2.2 * n_xyz;
            }

            float _BigWaveFrequencyX;
            float _BigWaveFrequencyY;
            float _BigWaveSpeed;
            float _BigWaveElevation;

            float4 _DepthColor;
            float4 _SurfaceColor;
            float _ColorOffset;
            float _ColorMultiplier;

            float _SmallWaveFrequency;
            float _SmallWaveSpeed;
            float _SmallWaveElevation;

            v2f vert (appdata i)
            {
                v2f o;
                float time = _Time.y;

                float3 worldPos = TransformObjectToWorld(i.vertex.xyz);

                float elevation = sin(worldPos.x * _BigWaveFrequencyX + time * _BigWaveSpeed) *
                                    sin(worldPos.z * _BigWaveFrequencyY + time * _BigWaveSpeed) *
                                    _BigWaveElevation;

                // step1: なだらかな波の変化(sin波)に対して、ノイズを追加して小波を表現
                // elevation += cnoise(float3(worldPos.xz * 3.0, 0));

                // step2: 引数3つ目に時間を入れて、波をアニメーション (elevation 作成時のアニメーションとは別に小波を動かすイメージ)
                // elevation += cnoise(float3(worldPos.xz * _SmallWaveFrequency, time * _SmallWaveSpeed));

                // step3: conoiseの結果に対して、高さを調整
                elevation += cnoise(float3(worldPos.xz * _SmallWaveFrequency, time * _SmallWaveSpeed)) * _SmallWaveElevation;

                worldPos.y += elevation;

                o.vertex = TransformWorldToHClip(worldPos);
                o.elevation = elevation;
                o.uv = i.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //NOTE: 波の高さに応じて色を変える
                float mixStrength = (i.elevation + _ColorOffset) * _ColorMultiplier;

                // カラー グレースケール
                // float3 color = lerp(float3(0.1, 0.1, 0.1), float3(1.0, 1.0, 1.0), mixStrength);

                // カラー
                float3 color = lerp(_DepthColor.rgb, _SurfaceColor.rgb, mixStrength);
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}
