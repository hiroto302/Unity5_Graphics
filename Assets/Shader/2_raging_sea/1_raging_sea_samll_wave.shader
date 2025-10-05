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

            float _BigWaveFrequencyX;
            float _BigWaveFrequencyY;
            float _BigWaveSpeed;
            float _BigWaveElevation;

            float4 _DepthColor;
            float4 _SurfaceColor;
            float _ColorOffset;
            float _ColorMultiplier;

            //	Classic Perlin 2D Noise
            //	by Stefan Gustavson (https://github.com/stegu/webgl-noise)
            float2 fade(float2 t)
            {
                return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
            }

            float4 permute(float4 x)
            {
                return fmod(((x * 34.0) + 1.0) * x, 289.0);
            }

            float cnoise(float2 P)
            {
                float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
                float4 Pf = frac(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);
                Pi = fmod(Pi, 289.0); // To avoid truncation effects in permutation
                float4 ix = Pi.xzxz;
                float4 iy = Pi.yyww;
                float4 fx = Pf.xzxz;
                float4 fy = Pf.yyww;
                float4 i = permute(permute(ix) + iy);
                float4 gx = 2.0 * frac(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
                float4 gy = abs(gx) - 0.5;
                float4 tx = floor(gx + 0.5);
                gx = gx - tx;
                float2 g00 = float2(gx.x, gy.x);
                float2 g10 = float2(gx.y, gy.y);
                float2 g01 = float2(gx.z, gy.z);
                float2 g11 = float2(gx.w, gy.w);
                float4 norm = 1.79284291400159 - 0.85373472095314 *
                    float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
                g00 *= norm.x;
                g01 *= norm.y;
                g10 *= norm.z;
                g11 *= norm.w;
                float n00 = dot(g00, float2(fx.x, fy.x));
                float n10 = dot(g10, float2(fx.y, fy.y));
                float n01 = dot(g01, float2(fx.z, fy.z));
                float n11 = dot(g11, float2(fx.w, fy.w));
                float2 fade_xy = fade(Pf.xy);
                float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
                float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
                return 2.3 * n_xy;
            }

            v2f vert (appdata i)
            {
                v2f o;
                float time = _Time.y;

                float3 worldPos = TransformObjectToWorld(i.vertex.xyz);

                float elevation = sin(worldPos.x * _BigWaveFrequencyX + time * _BigWaveSpeed) *
                                    sin(worldPos.z * _BigWaveFrequencyY + time * _BigWaveSpeed) *
                                    _BigWaveElevation;

                // step1: なだらかな波の変化(sin波)に対して、ノイズを追加して小波を表現
                elevation += cnoise(float3(worldPos.xz * 3.0, 0));

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
