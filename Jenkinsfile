pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t tfg-jesus:test .'
            }
        }

        stage('Test') {
            steps {
                echo 'Testing...'

                sh 'docker run --rm --name appjenkins --network jenkins -d -p 9070:80 tfg-jesus:test'
                sh '/bin/nc -vz localhost 9070'
                
                sh label: '', script: '''#!/bin/bash
                    CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk \'{print 100 - $1}\')
                    max=90
                    if (( $(echo "$CPU > $max" | bc -l) )); then
                        echo "Sobrepasa el uso de CPU!"
                        exit 1
                    else
                        echo "CPU correcta."
                    fi
                '''
                
                sh label: '', script: '''#!/bin/bash
                    RamA=$(free -m | grep 'Mem' | awk '{print $2}')
                    RamU=$(free -m | grep 'Mem' | awk '{print $3}')
                    RamPorcentaje=$(echo "scale=1; $RamU / $RamA * 100" | bc)
                    max=90
                    if (( $(echo "$RamPorcentaje > $max" | bc -l) )); then
                        echo "Sobrepasa el uso de RAM! Esta usando el $RamPorcentaje por ciento"
                        exit 1
                    else
                        echo "RAM correcta."
                    fi
                '''
                
                sh 'ab -t 10 -c 200 http://localhost:9070/index.php | grep Requests'
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable: 'gitid', usernameVariable: 'GITHUB_USER')]) {
                    sh 'rm -rf TFG'
                    sh 'git clone --branch produccion https://github.com/JG-Alba/Jenkins-testing.git'
                    sh '''git config --global --add safe.directory /var/jenkins_home/workspace/prueba/Jenkins-testing
'''
                    sh 'cp -r Dockerfile wordpress TFG && cd TFG && git add . && git push https://${GITHUB_USER}:${gitid}@github.com/JG-Alba/Jenkins-testing.git'
                }
                withDockerRegistry([ credentialsId: "dockerhub", url: "" ]) {
	            	sh 'docker tag tfg-jesus:test soramatoi/tfg-jesus:stable'
		            sh 'docker push soramatoi/tfg-jesus:stable'
	            }
            }
        }
        stage('Deploy') {
            steps {
	                sh 'docker stop appjenkins'
	                sh 'docker pull soramatoi/tfg-jesus:stable'
	                sh 'docker run --rm --name wordjenkins --network jenkins -d -p 9070:80 soramatoi/tfg-jesus:stable'
        }
    }
    }
}
