pipeline {
  agent any

  // Adjust tool names to match your "Global Tool Configuration"
  tools {
    jdk 'JDK17'          // or your configured JDK name
    maven 'Maven3'       // safe even if Gradle is used; won’t be used if gradle wrapper exists
  }

  parameters {
    string(name: 'REPO_URL', defaultValue: 'https://github.com/Jayden54-asss/oscal-cli.git', description: 'Git repository URL')
    string(name: 'BRANCH',   defaultValue: 'master', description: 'Git branch to build')
    booleanParam(name: 'RUN_DEPLOY', defaultValue: false, description: 'Run the generated JAR after build')
  }

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '10'))
    timeout(time: 20, unit: 'MINUTES')
  }

  environment {
    APP_JAR = '' // will be set after build
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: params.BRANCH, url: params.REPO_URL
      }
    }

    stage('Build') {
      steps {
        script {
          if (fileExists('gradlew')) {
            echo 'Detected Gradle Wrapper'
            if (isUnix()) {
              sh 'chmod +x gradlew && ./gradlew --no-daemon clean build -x test'
            } else {
              bat 'gradlew --no-daemon clean build -x test'
            }
          } else if (fileExists('pom.xml')) {
            echo 'Detected Maven Project'
            def cmd = 'mvn -B -ntp -DskipTests clean package'
            if (isUnix()) { sh cmd } else { bat cmd }
          } else {
            error 'Neither gradlew nor pom.xml found. This repo is not a standard Java build (Gradle/Maven).'
          }
        }
      }
    }

    stage('Test') {
      steps {
        script {
          if (fileExists('gradlew')) {
            if (isUnix()) {
              sh './gradlew --no-daemon test'
            } else {
              bat 'gradlew --no-daemon test'
            }
          } else if (fileExists('pom.xml')) {
            def cmd = 'mvn -B -ntp test'
            if (isUnix()) { sh cmd } else { bat cmd }
          } else {
            echo 'Skip tests: no recognized build tool.'
          }
        }
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: '**/build/test-results/test/*.xml, **/target/surefire-reports/*.xml'
        }
      }
    }

    stage('Archive') {
      steps {
        script {
          // Try common output locations
          def jars = findFiles(glob: 'build/libs/*.jar') + findFiles(glob: 'target/*.jar')
          if (jars && jars.size() > 0) {
            // Pick the first non -sources/-javadoc jar if possible
            def chosen = jars.find { !it.name.contains('sources') && !it.name.contains('javadoc') } ?: jars[0]
            env.APP_JAR = chosen.path
            echo "Artifact found: ${env.APP_JAR}"
            archiveArtifacts artifacts: env.APP_JAR, fingerprint: true
          } else {
            echo 'No JAR artifacts found to archive.'
          }
        }
      }
    }

    stage('Deploy (Run JAR)') {
      when {
        expression { return params.RUN_DEPLOY && env.APP_JAR?.trim() }
      }
      steps {
        script {
          if (isUnix()) {
            sh "java -jar '${env.APP_JAR}' || echo 'App exited / no main class'"
          } else {
            // run without blocking the executor too long
            powershell "java -jar '${env.APP_JAR}' ; if (\$LASTEXITCODE -ne 0) { Write-Host 'App exited / no main class' }"
          }
        }
      }
    }
  }

  post {
    always {
      echo 'Cleaning up workspace'
      deleteDir() // cleans after the build completes
    }
    success {
      echo 'Build succeeded!!!'
      // e.g., you can add notifications here
    }
    failure {
      echo 'Build failed!'
      // e.g., you can add notifications here
    }
  }
}
