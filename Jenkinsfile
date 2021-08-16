pipeline {
    agent any

    environment {
        scannerHome = tool name: 'sonar_scanner_dotnet'
        username = 'aakashgarg'
        registry = 'iaakashgarg/app-aakashgarg-devops'
        docker_port = '7400'
        container_id = null
    }

    tools {
        msbuild 'MSBuild'
    }

    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '10', numToKeepStr: '20')
    }

    stages {

        stage('Code Checkout') {
            steps {
                checkout([$class: 'GitSCM', extensions: [], userRemoteConfigs: [[url: 'https://github.com/Iaakashgarg/app-aakashgarg-devops.git']]])
            }
        }

        stage('Unit Test') {
            steps {
                bat "dotnet test WebApplication4-Tests\\WebApplication4-Tests.csproj"
            }
        }
        stage('Start Sonarqube analysis') {
            steps {
                withSonarQubeEnv('Test_Sonar') {
                    bat "${scannerHome}\\SonarScanner.MSBuild.exe begin /k:sonar-aakashgarg-devops /n:sonar-aakashgarg-devops /v:1.0"
                }
            }
        }
        stage('Code Build') {
            steps {
                bat "dotnet clean WebApplication4\\WebApplication4.csproj"

                bat 'dotnet build WebApplication4\\WebApplication4.csproj -c Release -o "WebApplication4/app/build"'
            }
        }

        stage('Stop Sonarqube analysis') {
            steps {
                withSonarQubeEnv('Test_Sonar') {
                    bat "${scannerHome}\\SonarScanner.MSBuild.exe end "
                }
            }
        }

        stage('Build Docker Image') {
            steps {
            echo "Building docker image"
            bat "docker build -t i-${username}-feature:${BUILD_NUMBER} --no-cache -f Dockerfile ."
            bat "docker tag i-${username}-feature:${BUILD_NUMBER} ${registry}:${BUILD_NUMBER}"
            bat "docker tag i-${username}-feature:${BUILD_NUMBER} ${registry}:latest"
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'DockerHub', url: ""]){
                    bat "docker push ${registry}:${BUILD_NUMBER}"
                    bat "docker push ${registry}:latest"
                }
            }
        }

        stage('Pre Container Check') {
            environment {
                container_id = "${bat(script:"docker ps -a --filter publish=${docker_port} --format {{.ID}}", returnStdout: true).trim().readLines().drop(1).join("")}"
            }
            steps {
                script {
                    if(env.container_id!=null){
                        echo "Removing container: ${env.container_id}"
                        bat "docker rm -f ${env.container_id}"
                    }
                }
            }
        }

        stage('Deployment') {
            parallel {
                stage('Docker Deployment') {
                    steps {
                        bat "docker run --name c-${username}-feature -d -p ${docker_port}:80 ${registry}:${BUILD_NUMBER}"
                    }
                }

                stage('Kubernetes Deployment') {
                    steps {
                        bat "kubectl apply -f deployment.yaml"
                    }
                }
            }
        }
    }
}