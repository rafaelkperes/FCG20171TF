#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da cor de cada vértice, definidas em "shader_vertex.glsl" e
// "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define OTHER        0
#define MOVING_BLOCK 1
#define STATIC_BLOCK 2
#define PLANE        3
uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;
uniform sampler2D TextureImage6;

#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

void main()
{
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    vec4 p = position_world;
    vec4 n = normalize(normal);
    vec4 l = normalize(camera_position - p);
    vec4 v = normalize(camera_position - p);
    vec4 r = -l + 2*n*dot(n, l);

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == MOVING_BLOCK )
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.y - miny) / (maxy - miny);

        Kd = texture(TextureImage1, vec2(U,V)).rgb;
        //Kd = vec3(0.8, 0.4, 0.08);
        Ks = vec3(0.0,0.0,0.0);
        Ka = Kd/2;
        q = 1.0;
    }
    else if ( object_id == STATIC_BLOCK )
    {
        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.y - miny) / (maxy - miny);

        Kd = texture(TextureImage1, vec2(U,V)).rgb;

        //Kd = vec3(0.08, 0.4, 0.8);
        Ks = vec3(0.8, 0.8, 0.8);
        Ka = Kd/2;
        q = 32.0;
    }
    else if ( object_id == PLANE )
    {
        Kd = vec3(0.2, 0.2, 0.2);
        Ks = vec3(0.3, 0.3, 0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }
    else
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }

    vec3 I = vec3(1, 1, 1);

    float lambert_diffuse_term = max(0, dot(n, l));
    float phong_specular_term  = pow(max(0, dot(r, v)), q);
    vec3 light_spectrum = vec3(1.0, 1.0, 1.0);
    vec3 ambient_light_spectrum = vec3(0.2, 0.2, 0.2);

    color = Kd * light_spectrum * lambert_diffuse_term
          + Ka * ambient_light_spectrum
          + Ks * light_spectrum * phong_specular_term;

    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}
