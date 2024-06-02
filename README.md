# Cinemapedia

## Descripción del proyecto
Cinemapedia es un proyecto realizado en flutter utilizando clean arquitecture y domain driven design, se utilizaron las siguientes herramientas:
- Riverpod provider como gestor de cambios de estado
- Dio para la realización de solicitudes http
- Isar Database para base de datos local
- The Movie DB para la obtención de los datos

Este proyecto tiene como finalidad realizar una práctica de una aplicación real y funcional utilizando las herramientas antes mencionadas. 

Las funionalidades de la aplicación son:

- Mostrar las películas actuales
- Mostrar las películas que estan por estrenar
- Mostrar las películas que tienen mejor calificación
- El usuario puede marcar películas favoritas
- Se puede acceder al detalle de la película y ver un resumen de la misma, además de los actores que participaron en ella
- Puedes buscar películas en el buscador integrado


## Instrucciones para correr el proyecto

Para correr esta aplicación debes seguir los siguientes pasos:

1. Clona el repositorio utilizando el siguiente comando
```
git clone https://github.com/juanjmorelos/flutter_cinemapedia.git
```

2. Si no tienes API Key en The Movie DB obtén una
3. Copiar el .env.template y renombrarlo a .env
4. Toma el API Key generado por The Movie DB y agregala en la variable de entorno 

```env
THE_MOVIEDB_KEY=AQUI_VA_TU_API_KEY
```
5. Utiliza un IDE como Android Studio o un editor de texto como Visual Studio Code y compila el proyecto 
