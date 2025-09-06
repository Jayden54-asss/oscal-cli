pipeline {
  agent any

  tools {
    jdk 'JDK17'       // Jenkins > Global Tool Configuration name for JDK 17
    maven 'Maven3'    // Jenkins > Global Tool Configuration name for Maven 3.x
  }

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
    timeout(time: 20, unit: 'MINUTES')
  }

  environment {
    MAVEN_OPTS = '-Dmaven.wagon.http.pool=false'
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'master', url: 'https://github.com/Jayden54-asss/oscal-cli.git'
      }
    }

    stage('Build (skip tests)') {
      steps {
        script {
          def cmd = 'mvn -B -ntp -DskipTests clean package'
          if (isUnix()) { sh cmd } else { bat cmd }
        }
      }
    }

    stage('Test') {
      steps {
        script {
          def cmd = 'mvn -B -ntp test'
          if (isUnix()) { sh cmd } else { bat cmd }
        }
      }
      post {
        always {
          // surefire/failsafe default locations
          junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml, **/target/failsafe-reports/*.xml'
        }
      }
    }

    stage('Archive Artifact') {
      steps {
        archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
      }
    }
  }

  post {
    success { echo 'CI passed for oscal-cli' }
    failure { echo 'CI failed for oscal-cli' }
    always  { echo 'Build complete' }
  }
}
