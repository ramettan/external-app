pipeline {
    agent any 
    tools {nodejs "nodejs"}

   
    stages {
        stage('Run the tests') {
            
            steps {
                echo 'Retrieve source from github' 
                git branch: 'main',
                    url: 'https://github.com/ramettan/external-app.git'
                echo 'showing files from repo?' 
                sh 'ls -a'
                echo 'install dependencies' 
                sh 'npm install'
                echo 'Run tests'
                sh 'npm test'
                echo 'Testing completed'
                sh 'ls -a'
                
            }
        }
        
       
        
        stage('Building image') {
            steps{
                script {
                    echo 'building image' 
                    dockerImage = docker.build("${env.imageName}:${env.BUILD_ID}")
                    echo 'image built'
                }
            }
            }
stage ('Docker push'){
        steps{
            withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', passwordVariable: 'docker_password', usernameVariable: 'docker_user')]){
            sh"""
            docker build -t ${docker_user}/external:${BUILD_NUMBER} .
            docker login -u ${docker_user} -p ${docker_password}
            docker push ${docker_user}/external:${BUILD_NUMBER} >&1 | tee docker.txt
            
            """
            }
        }
    }    
     stage('deploy to k8s') {
             agent {
                docker { 
                    image 'google/cloud-sdk:latest'
                    args '-e HOME=/tmp'
                    reuseNode true
                        }
                    }
            steps {
                echo 'Get cluster credentials'
                sh '''
                gcloud container clusters get-credentials my-app-cluster --zone us-central1-c --project big-quanta-356212
                pwd
                ls
                echo "create a temporary folder for storing manifest"
                tmp_dir="tmp-vars-${BUILD_NUMBER}"
                echo $tmp_dir
		mkdir -p ${tmp_dir}
                
                cp  ./yaml/* ./${tmp_dir}
                cd ${tmp_dir}
                pwd
                ls -l
                echo "replacing image tag"
                sed -i 's|${BUILD_NUMBER}|'"${BUILD_NUMBER}"'|g' external-deployment.yaml
                cat external-deployment.yaml
                cat external-load-balancer.yaml
                
                kubectl apply -f external-deployment.yaml
                kubectl apply -f external-load-balancer.yaml
               
                
                '''
                

             }
        }     
     /*   stage('Remove local docker image') {
            steps{
                echo "pending"
                // sh "docker rmi $imageName:latest"
                sh "docker rmi -f ${env.imageName}:${env.BUILD_ID}"
            }
        }*/
    }
}
