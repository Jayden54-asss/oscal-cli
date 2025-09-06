pipeline {
    agent any
    tools {
        maven 'Maven3'
        jdk 'Java11'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Jayden54-ass/oscal-cli.git'
            }
        }
        stage('Build & Test') {
            steps {
                sh 'mvn clean install'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        stage('Validate OSCAL Examples') {
            steps {
                sh 'java -jar target/oscal-cli-*.jar validate examples/ssp-example.json'
                sh 'java -jar target/oscal-cli-*.jar validate examples/profile-example.xml'
            }
        }
        stage('Coverage') {
            steps {
                sh 'mvn jacoco:report'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/site/jacoco/**', fingerprint: true
                }
            }
        }
    }
}
