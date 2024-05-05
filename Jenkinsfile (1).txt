pipeline {

    agent any
    
    environment {
        PROJECT_ID = 'pro-lattice-421310'
        CLUSTER_NAME = 'my-gke-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = 'Jenkins-GKE'
    }

    tools {
        maven "mymaven"
    }

    stages {

        stage ("Clone the Git Repository") {

            steps{
                echo "Cloning the repository"
                git credentialsId: 'Project', url: 'https://github.com/amarkaja/ABC-Technologies.git'
            }
        }

        stage ("Compile the Code"){
            
            steps {
                echo "Compiling the code"
                sh "mvn compile"
            
            }
        }

        stage ("Test the Code"){
            
            steps {
                echo "Test the code"
                sh "mvn test"
            }
        }

        stage ("Package the Code"){

            steps {
                echo "Packaging the code"
                sh "mvn clean package"
            }
            post {
                success {
                    junit 'target/surefire-reports/*.xml'
                }
            }
            
        }
	
	stage ('Build the Docker Image'){
            steps{
                sh 'cp $WORKSPACE/target/ABCtechnologies-1.0.war ABCtechnologies-1.0.war'
                sh 'sudo docker build -t amarkaja/project:$BUILD_NUMBER .'
            }
        }
        
        stage ('Push to the DockerHub Registry'){
            steps{
                withDockerRegistry(credentialsId: 'Dockerhub', url: '') {
                    sh 'sudo docker push amarkaja/project:$BUILD_NUMBER'
                }
            }
        }
        
        stage ('Testing Local- Build Container from DockerHub Image'){
            steps{
                sh 'sudo docker run -d -P amarkaja/project:$BUILD_NUMBER'
            }
        }
	
	
        stage('Creating GKE Cluster with Terraform') {
            steps {
                sh 'cp $WORKSPACE/GKE-Terraform/* .'
                sh 'sudo terraform init'
                sh 'sudo terraform apply -auto-approve'
            }
        }
                
        stage('Deploy App to Kubernetes Cluster'){
            steps{
		sh "sed -i 's/project:latest/project:$BUILD_NUMBER/g' abcapplication.yaml"
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'abcapplication.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
		
            }
         }
      }
}	
