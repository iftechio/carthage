pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        ws(dir: '~/JenkinsProducts')
        dir(path: '~/JenkinsProducts')
        sh '''brew install --build-bottle jikecarthage 
brew bottole --json jikecarthage'''
      }
    }
  }
}