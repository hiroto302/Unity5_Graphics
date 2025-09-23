Shader "patterns/33_gradient_color_center_point_stretch_diamond_rotation"
{
    Properties
    {
        _OriginX("OriginX", Range(0.0, 1.0)) = 0.5
        _OriginY("OriginY", Range(0.0, 1.0)) = 0.5
        _WhiteThreshold("WhiteThreshold", Range(0.0, 0.1)) = 0.015
        _StretchX("StretchX", Range(0.0, 1.0)) = 0.1
        _StretchY("StretchY", Range(0.0, 1.0)) = 0.5
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


            float _StretchX;
            float _StretchY;
            float _OriginX;
            float _OriginY;
            float _WhiteThreshold;

            // 回転関数を定義
            float2 rotate(float2 uv, float angle, float2 center)
            {
                float cosAngle = cos(angle);
                float sinAngle = sin(angle);

                float2 offset = uv - center;
                float2 rotated = float2(
                    cosAngle * offset.x - sinAngle * offset.y,
                    sinAngle * offset.x + cosAngle * offset.y
                );

                return rotated + center;
            }

            v2f vert (appdata input)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(input.vertex.xyz);
                o.uv = input.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 rotatedUv = rotate(i.uv, PI * 0.25, float2(0.5, 0.5));

                float2 origin = float2(_OriginX, _OriginY);

                float offsetX = origin.x - _StretchX * _OriginX;
                float offsetY = origin.y - _StretchY * _OriginY;

                float2 lightUvX = float2(
                    rotatedUv.x * _StretchX + offsetX,
                    rotatedUv.y * _StretchY + offsetY
                );

                float lightX = _WhiteThreshold / distance(origin, lightUvX);

                float2 lightUvY = float2(
                    rotatedUv.x * _StretchY + offsetY,
                    rotatedUv.y * _StretchX + offsetX
                );

                float lightY = _WhiteThreshold / distance(origin, lightUvY);

                float strength = lightX * lightY;

                half4 col = half4(strength, strength, strength, 1.0);
                return col;
            }

            ENDHLSL
        }
    }
}
