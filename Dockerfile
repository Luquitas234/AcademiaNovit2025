# Etapa 1: Build - Construir la aplicación .NET
# Usamos la imagen SDK de .NET 9.0 para compilar el código fuente.
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copiar el archivo de la solución (.sln) y los archivos de proyecto (.csproj)
# Ahora, las rutas son relativas a la raíz del repositorio (el nuevo contexto de Docker).
# Copiamos la solución y los proyectos a /src
COPY "AcademiaNovit.sln"  "./"  
COPY "AcademiaNovit/AcademiaNovit.csproj" "AcademiaNovit/"
COPY "AcademiaNovit.Tests/AcademiaNovit.Tests.csproj" "AcademiaNovit.Tests/"

# Restaurar las dependencias de NuGet para todos los proyectos en la solución
# Esto es esencial para que la compilación tenga todas las bibliotecas necesarias.
RUN dotnet restore AcademiaNovit.sln

# Copiar todo el código fuente de la aplicación
# Esto copiará el resto de los archivos de tu repositorio al contenedor.
COPY . .

# Cambiar al directorio del proyecto de la Web API
# Asegúrate de que esta ruta sea correcta dentro de /src
WORKDIR /src/AcademiaNovit

# Publicar la aplicación para producción
# -c Release: Compila en modo Release para optimización.
# -o /app/publish: Publica los archivos de salida en el directorio /app/publish dentro del contenedor.
# --no-restore: Evita restaurar dependencias nuevamente, ya lo hicimos.
# --no-build: Evita compilar nuevamente, ya lo hicimos.
RUN dotnet publish "AcademiaNovit.csproj" -c Release -o /app/publish --no-restore --no-build

# Etapa 2: Base - Crear la imagen final de la aplicación
# Usamos la imagen de runtime de ASP.NET 9.0, que es más ligera y solo contiene lo necesario para ejecutar la app.
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app

# Exponer el puerto en el que la aplicación ASP.NET Core escuchará.
EXPOSE 80

# Copiar los archivos publicados desde la etapa 'build' a la imagen final
COPY --from=build /app/publish .

# Definir el punto de entrada (entrypoint) para la aplicación.
ENTRYPOINT ["dotnet", "AcademiaNovit.dll"]
