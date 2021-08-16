FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

COPY WebApplication4/WebApplication4.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o -out

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app
COPY --from=build-env /app/out/ .
ENTRYPOINT [ "dotnet","WebApplication4.dll" ]