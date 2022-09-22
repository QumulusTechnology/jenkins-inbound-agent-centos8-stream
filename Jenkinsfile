pipeline {
  agent {
    kubernetes {
      yaml '''
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: IfNotPresent
    resources:
      limits:
        cpu: "1000m"
        memory: "2Gi"
      requests:
        cpu: "1000m"
        memory: "2Gi"
    command:
    - sleep
    args:
    - 9999999
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  - name:  jnlp
    image: jenkins/inbound-agent:4.13.2-1-jdk11
    imagePullPolicy: IfNotPresent
    resources:
      limits:
        cpu: "1000m"
        memory: "2Gi"
      requests:
        cpu: "1000m"
        memory: "2Gi"
    command:
  volumes:
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: qumulus-repo-docker-credentials
          items:
            - key: .dockerconfigjson
              path: config.json
'''
    }
  }
  stages {
    stage('Build with Kaniko') {
      steps {
        script {
          env.TAG = sh(script:"git describe 2>/dev/null | sed 's/[^0-9\\.]*//g'", returnStdout: true).trim()
        }
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
            if [ -n "$TAG" ]; then
              /kaniko/executor --context `pwd` --force \
                --destination repo.qumulus.io/jenkins/jenkins-inbound-agent-centos-stream8:latest \
                --destination repo.qumulus.io/jenkins/jenkins-inbound-agent-centos-stream8:$TAG
            else
              /kaniko/executor --context `pwd` --force \
                --destination repo.qumulus.io/jenkins/jenkins-inbound-agent-centos-stream8:latest
            fi
          '''
        }
      }
    }
  }
}
