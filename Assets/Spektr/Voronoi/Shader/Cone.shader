﻿Shader "Hidden/Spektr/Voronoi/Cone"
{
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "SimplexNoise2D.cginc"

    sampler2D _Source;
    float _Aspect;
    float _RandomSeed;

    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float3 normal : NORMAL;
        half4 color : COLOR;
    };

    struct FragOutput
    {
        half4 color : COLOR0;
        half4 normal : COLOR1;
    };

    float Random01(float seed, float salt)
    {
        float2 uv = float2(seed, salt + _RandomSeed);
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    float2 SamplingPoint(float2 uv)
    {
        float rx = Random01(uv.y, 0);
        float ry = Random01(uv.y, 1);
        float nx = snoise(float2(uv.y, _Time.x)) * 0.2;
        float ny = snoise(float2(_Time.x, uv.y)) * 0.2;
        return float2(rx + nx, ry + ny);
    }

    v2f vert(appdata v)
    {
        float2 uv = SamplingPoint(v.uv);

        float4 vc = v.vertex * float4(1, _Aspect, 1, 1);

        float4 offs = float4(uv * 2 - 1, 0, 0);

        half4 sc = tex2D(_Source, uv);
        float level = Luminance(sc.rgb);
        offs += (pow(level + 0.1, 2) < Random01(v.uv.y, 2)) * 1000;

        v2f o;
        o.vertex = vc + offs;
        o.normal = v.normal;
        o.color = sc;
        return o;
    }

    FragOutput frag(v2f i) : SV_Target
    {
        FragOutput o;
        o.color = i.color;
        o.normal = float4((i.normal + 1) * 0.5, 1);
        return o;
    }

    ENDCG
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            ENDCG
        }
    }
}
