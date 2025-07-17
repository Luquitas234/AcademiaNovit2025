# Etapa 1: Build - Construir la aplicación .NET
# Usamos la imagen SDK de .NET 9.0 para compilar el código fuente.
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copiar el archivo de la solución (.sln) y los archivos de proyecto (.csproj)
COPY AcademiaNovit.sln ./
COPY AcademiaNovit/AcademiaNovit.csproj AcademiaNovit/
COPY AcademiaNovit.Tests/AcademiaNovit.Tests.csproj AcademiaNovit.Tests/

# Restaurar las dependencias de NuGet para todos los proyectos en la solución .sln
RUN dotnet restore AcademiaNovit.sln

# Copiar todo el código fuente de la aplicación
COPY . .

# Cambiar al directorio del proyecto de la Web API para la compilación y publicación
WORKDIR /src/AcademiaNovit

# ¡NUEVO PASO! Compilar el proyecto explícitamente.
# Esto generará los archivos necesarios, incluyendo staticwebassets.build.json.
RUN dotnet build AcademiaNovit.csproj -c Release --no-restore

# Publicar la aplicación para producción
# Quitamos --no-build y --no-restore para que el publish pueda manejar dependencias si es necesario.
RUN dotnet publish AcademiaNovit.csproj -c Release -o /app/publish

# Etapa 2: Base - Crear la imagen final de la aplicación
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app

EXPOSE 80

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "AcademiaNovit.dll"]
