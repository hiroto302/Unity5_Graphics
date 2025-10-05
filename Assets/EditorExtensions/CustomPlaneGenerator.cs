using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class CustomPlaneGenerator : MonoBehaviour
{
    [Header("Plane Settings")]
    [SerializeField] private float width = 2f;
    [SerializeField] private float height = 2f;
    [SerializeField] private int segmentsX = 128;
    [SerializeField] private int segmentsY = 128;

    void Start()
    {
        if (GetComponent<MeshFilter>().sharedMesh == null)
        {
            GeneratePlane();
        }
    }

    public void GeneratePlane()
    {
        Mesh mesh = new Mesh();
        mesh.name = "High Res Plane";

        int vertexCount = (segmentsX + 1) * (segmentsY + 1);
        Vector3[] vertices = new Vector3[vertexCount];
        Vector2[] uvs = new Vector2[vertexCount];

        for (int y = 0; y <= segmentsY; y++)
        {
            for (int x = 0; x <= segmentsX; x++)
            {
                int index = y * (segmentsX + 1) + x;
                float xPos = ((float)x / segmentsX - 0.5f) * width;
                float zPos = ((float)y / segmentsY - 0.5f) * height;
                vertices[index] = new Vector3(xPos, 0, zPos);
                uvs[index] = new Vector2((float)x / segmentsX, (float)y / segmentsY);
            }
        }

        int[] triangles = new int[segmentsX * segmentsY * 6];
        int triIndex = 0;

        for (int y = 0; y < segmentsY; y++)
        {
            for (int x = 0; x < segmentsX; x++)
            {
                int bottomLeft = y * (segmentsX + 1) + x;
                int bottomRight = bottomLeft + 1;
                int topLeft = bottomLeft + (segmentsX + 1);
                int topRight = topLeft + 1;

                triangles[triIndex++] = bottomLeft;
                triangles[triIndex++] = topLeft;
                triangles[triIndex++] = bottomRight;

                triangles[triIndex++] = bottomRight;
                triangles[triIndex++] = topLeft;
                triangles[triIndex++] = topRight;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        GetComponent<MeshFilter>().sharedMesh = mesh;

        Debug.Log($"Plane generated: {vertexCount} vertices, {triangles.Length / 3} triangles");
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(CustomPlaneGenerator))]
public class CustomPlaneGeneratorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        CustomPlaneGenerator generator = (CustomPlaneGenerator)target;

        if (GUILayout.Button("Generate Plane"))
        {
            generator.GeneratePlane();
        }
    }
}
#endif