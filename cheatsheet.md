
# Cheat Sheet

## WebHooks for MultiBranch

http://localhost:10000/jenkins/job/worker/build?delay=0

## Simple Dockerfile

```groovy
pipeline {
  agent {
    docker {
      image 'maven:3-jdk-8-alpine'
    }

  }
  stages {
    stage('Build') {
      steps {
        sh 'mvn compile'
      }
    }
    stage('Unit Test') {
      steps {
        sh 'mvn test'
      }
    }
    stage('Integration Test') {
      steps {
        sh 'mvn verify'
      }
    }
  }
}
```
