cbuffer TransformConstantBuffer : register(b0)
{
	float4x4 VertexModel;
	float4x4 NormalModel;
};

cbuffer CubeArrayConstantBuffer : register(b1)
{
	float4x4 ViewProjection[6];
};

cbuffer CameraConstantBuffer : register(b2)
{
	float4x4 CameraViewProjection;
};

struct VertexShaderInput
{
	float3 Position : POSITION;
	float3 Normal : NORMAL;
	uint InstanceId : SV_InstanceID;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float4 Normal : NORMAL;
	float2 UV : TEXCOORD;
	uint RenderTargetId : SV_RenderTargetArrayIndex;
};

VertexShaderOutput main(VertexShaderInput input)
{
	VertexShaderOutput output;
	float4 position = float4(input.Position, 1.0f);
	float4 worldPosition = mul(position, VertexModel);
	position = mul(worldPosition, ViewProjection[input.InstanceId % 6]);
	output.Position = (float4)position;
	float4 normal = float4(input.Normal, 0.0f);
	normal = mul(normal, NormalModel);
	output.Normal = (float4)normal;
	output.RenderTargetId = input.InstanceId % 6;
	float4 cameraPosition = mul(worldPosition, CameraViewProjection);
	float w = cameraPosition.w;
	cameraPosition /= w;
	float2 cameraUV = cameraPosition.xy;
	cameraUV = (cameraUV + 1.0f) / 2.0f;
	output.UV = w > 0 ? (float2)cameraUV : float2(-1.0, -1.0);
	return output;
}