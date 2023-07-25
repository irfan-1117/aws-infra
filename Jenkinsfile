pipeline {
    agent any
    
    environment {
     AWS_CRED = credentials('AWS-ID')
    }

    tools {
      terraform 'Terraform'
    }

    stages {
        
        stage('Clean workspace') {
            steps {
              cleanWs()
            }
        }
        
        stage('Checkout SCM') {
            steps {
              checkout scmGit(branches: [[name: '*/development']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/irfan-1117/aws-infra.git']])
            }
        }

        stage('EC2-Instance') {
            steps {
                script {
                  sh '''  
                     cd ./aws-infra/EC2
                     terraform init && terraform apply -auto-approve
                  '''
                }
            }  
        }

    }   

}

