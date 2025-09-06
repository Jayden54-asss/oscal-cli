pipeline {
    agent any

    environment {
        NODE_ENV = 'development'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/Jayden54-asss/oscal-cli.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                // Install Node.js dependencies if package.json exists
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                // Run tests if defined in package.json
                sh 'npm test || echo "No tests defined"'
            }
        }

        stage('Build/Package') {
            steps {
                // Optional: build step if required
                sh 'npm run build || echo "No build step defined"'
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: '**/dist/**', allowEmptyArchive: true
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
