pipeline {
    agent none
    triggers {
        upstream(upstreamProjects: 'UCSB-PSTAT GitHub/jupyter-base/main', threshold: hudson.model.Result.SUCCESS)
    }
    environment {
        IMAGE_NAME = 'phys225a'
        CONTAINER_REGISTRY  = 'registry.cloud.college.ucsb.edu'
    }
    stages {
        stage('Build Test Deploy') {
            agent {
                kubernetes {
                    cloud 'rke-test'
                    inheritFrom 'podman'
                }
            }
            stages{
                stage('Build') {
                    steps {
                        script {
                            if (currentBuild.getBuildCauses('com.cloudbees.jenkins.GitHubPushCause').size() || currentBuild.getBuildCauses('jenkins.branch.BranchIndexingCause').size()) {
                               scmSkip(deleteBuild: true, skipPattern:'.*\\[ci skip\\].*')
                            }
                        }
                        container('podman') {
                            echo "NODE_NAME = ${env.NODE_NAME}"
                            sh 'podman build -t localhost/$IMAGE_NAME --pull --force-rm --no-cache .'
                        }
                     }
                    post {
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Test') {
                    steps {
                        container('podman') {
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep python -c "import awkward"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep python -c "import hist"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep python -c "import uproot"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep python -c "import pythia8"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep python -c "import streamlit"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep python -c "import vector"'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep bash which DelphesLHEF'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep bash which mg5_aMC'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep bash which findingz-ui'
                            sh 'podman run -it --rm --pull=never localhost/$IMAGE_NAME mamba run -n hep root --version'
                            sh 'podman run --rm --pull=never localhost/$IMAGE_NAME bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate hep"'
                            sh 'podman run -d --name=$IMAGE_NAME --rm --pull=never -p 8888:8888 localhost/$IMAGE_NAME start-notebook.sh --NotebookApp.token="jenkinstest"'
                            sh 'sleep 10 && curl -v http://localhost:8888/lab?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                            sh 'curl -v http://localhost:8888/tree?token=jenkinstest 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                            sh 'podman run -d --name=$IMAGE_NAME --rm --pull=never -p 8501:8501 localhost/$IMAGE_NAME conda run -n hep findingz-ui --server.port=8501'
                            sh 'sleep 10 && curl -v http://localhost:8501/ 2>&1 | grep -P "HTTP\\S+\\s200\\s+[\\w\\s]+\\s*$"'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rm -ifv $IMAGE_NAME'
                            }
                        }
                        unsuccessful {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }
                stage('Deploy') {
                    when { branch 'main' }
                    environment {
                        DOCKER_HUB_CREDS = credentials('harbor-registry-token')
                    }
                    steps {
                        container('podman') {
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://$CONTAINER_REGISTRY/ucsb/$IMAGE_NAME:latest --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                            sh 'skopeo copy containers-storage:localhost/$IMAGE_NAME docker://$CONTAINER_REGISTRY/ucsb/$IMAGE_NAME:v$(date "+%Y%m%d") --dest-username $DOCKER_HUB_CREDS_USR --dest-password $DOCKER_HUB_CREDS_PSW'
                        }
                    }
                    post {
                        always {
                            container('podman') {
                                sh 'podman rmi -i localhost/$IMAGE_NAME || true'
                            }
                        }
                    }
                }                
            }
        }
    }
    post {
        success {
            slackSend(username: 'jenkins', color: 'good', message: "Build ${env.JOB_NAME} ${env.BUILD_NUMBER} just finished successfull! (<${env.BUILD_URL}|Details>)")
        }
        failure {
            slackSend(username: 'jenkins', color: 'danger', message: "Uh Oh! Build ${env.JOB_NAME} ${env.BUILD_NUMBER} had a failure! (<${env.BUILD_URL}|Find out why>).")
        }
    }
}
