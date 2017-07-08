#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da cor de cada vértice, definidas em "shader_vertex.glsl" e
// "main.cpp".
in vec4 position_world;
in vec4 normal;

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

     if ( object_id == MOVING_BLOCK )
    {
        Kd = vec3(0.8, 0.4, 0.08);
        Ks = vec3(0.0,0.0,0.0);
        Ka = Kd/2;
        q = 1.0;
    }
    else if ( object_id == STATIC_BLOCK )
    {
        Kd = vec3(0.08, 0.4, 0.8);
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
