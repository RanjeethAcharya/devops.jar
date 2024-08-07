pipeline {
    agent {
        label 'jenkins-agent'
    }

    tools {
        jdk 'Java17' // Ensure this matches the JDK installation name in Jenkins
        maven 'Maven3'
    }
    
    environment {
        APP_NAME = "devops-java"
        RELEASE = "1.0"
        DOCKER_USER = "ranjeeth3302"
        DOCKER_PASS = 'dockerhub'
        IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                checkout scmGit(
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/RanjeethAcharya/devops-java.git']]
                )
            }
        }

        // Maven stages start here

        stage('Maven Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        
        stage('Maven Test') {
            steps {
                sh 'mvn test'
            }
        }
        
        stage('Maven Package') { // Ensure this matches the expected artifact name
            steps {
                sh 'mvn package'
            }
        }

        stage('Maven Package After SonarQube') { // If needed, or remove if not required
            steps {
                sh 'mvn package'
            }
        }        
        
        // SonarQube stage

        stage('SonarQube Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: "sonarqube") {
                        sh "mvn clean verify sonar:sonar -Dsonar.projectKey=java -Dsonar.projectName=java"
                    }
                }
            }
        }
        
        
        //Nexus stages start here
        
        stage('Publish Artifacts to Nexus') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'javaArtifactId', classifier: '', file: '/home/ubuntu/workspace/ci/server/target/server.jar', type: 'jar']], credentialsId: 'nexus', groupId: 'java', nexusUrl: '172.31.17.132:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'java', version: '1.0-SNAPSHOT'
            }
        }
        
        stage('build and push docker image ') {
            steps {
                script {
                    docker.withRegistry('https://hub.docker.com/', 'dockerhub') {
                        def docker_image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
            }
        }
    }
}
