
float2 rotate2D(float2 uv, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    float2x2 rotMatrix = float2x2(c, -s, s, c);
    return mul(rotMatrix, uv);
}