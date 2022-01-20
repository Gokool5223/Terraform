pipeline{
    agent any
    
    stages {

         stage('Build Docker Image'){
            steps{
                sh "docker build . -t gokul/helloworld"
            }
        }
        stage('DockerHub Push'){
            steps{
                withCredentials([string(credentialsId: 'docker-hub', variable: 'dockerHubPwd')]) {
                    sh "docker login -u gokul -p ${dockerHubPwd}"
                    sh "docker push gokul/helloworld"
                }
            }
        }

        stage('Deploy to App server'){
            steps{
                sh "ansible-playbook playbook1.yml"
            }
        }

        
        
    }
   
}
