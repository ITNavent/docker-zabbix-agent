#!/usr/bin/env groovy
def NAME = 'docker-zabbix-agent'
pipeline {
  agent {
    kubernetes {
      label "mypod-${UUID.randomUUID().toString()}"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker
    command:
    - cat
    tty: true
    volumeMounts:
    - name: dockersock
      mountPath: /var/run/docker.sock
  volumes:
  - name: dockersock
    hostPath:
      path: /var/run/docker.sock
  - name: mavenrepo
    hostPath:
      path: /tmp/jenkins/.m2
  - name: gradlerepo
    hostPath:
      path: /tmp/jenkins/.gradle
"""
    }
  }
  stages {
    stage('Image') {
      steps {
        container('docker') {
          withCredentials([file(credentialsId: 'jenkins-redeo-all', variable: 'KEYFILE')]) {
            sh """
            docker login -u _json_key --password-stdin https://gcr.io < ${KEYFILE}
            docker build --build-arg VERSION=${env.TAG_NAME} -t gcr.io/redeo-all/${NAME}:${env.TAG_NAME} .
            docker tag gcr.io/redeo-all/${NAME}:${env.TAG_NAME} gcr.io/redeo-all/${NAME}:${env.GIT_COMMIT}
            docker push gcr.io/redeo-all/${NAME}:${env.TAG_NAME}
            """
          }
        }
      }
    }
  }
}