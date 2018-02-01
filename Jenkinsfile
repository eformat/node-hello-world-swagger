#!groovy
/*
  Intended to run from a separate project where you have deployed Jenkins.
  To allow the jenkins service account to create projects:

  oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:$(oc project -q):jenkins
  oc adm policy add-cluster-role-to-user view system:serviceaccount:$(oc project -q):jenkins
 */
pipeline {
    // environment {}
    options {
        // set a timeout of 20 minutes for this pipeline
        timeout(time: 20, unit: 'MINUTES')
    }
    agent none
    parameters {
        string(name: 'APP_NAME', defaultValue: 'node-hello', description: "Application Name - all resources use this name as a label")
        string(name: 'GIT_URL', defaultValue: 'https://github.com/eformat/node-hello-world-swagger.git', description: "Project Git URL)")
        string(name: 'GIT_BRANCH', defaultValue: 'master', description: "Git Branch (from Multibranch plugin if being used)")
        string(name: 'STI_IMAGE', defaultValue: 'openshift/nodejs:latest', description: "S2I Image to use for build")
        string(name: 'DEV_PROJECT', defaultValue: 'node-hello-dev', description: "Name of the Development namespace")
        string(name: 'DEV_REPLICA_COUNT', defaultValue: '1', description: "Number of development pods we desire")
        string(name: 'DEV_TAG', defaultValue: 'latest', description: "Development tag")
        string(name: 'TEST_PROJECT', defaultValue: 'node-hello-test', description: "Name of the Test namespace")
        string(name: 'TEST_REPLICA_COUNT', defaultValue: '1', description: "Number of test pods we desire")
        string(name: 'TEST_TAG', defaultValue: 'test', description: "Test tag")
    }
    stages {
        stage('initialise') {
            agent any
            steps {
                echo "Build Number is: ${env.BUILD_NUMBER}"
                echo "Job Name is: ${env.JOB_NAME}"
                sh "oc version"
                sh 'printenv'
            }
        }

        stage('create dev project') {
            agent any
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject() {
                            return !openshift.selector("project", "${DEV_PROJECT}").exists();
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject() {
                                openshift.newProject("${DEV_PROJECT}")
                            }
                        }
                    }
                }
            }
        }

        stage('build dev') {
            agent any
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject("${DEV_PROJECT}") {
                            return openshift.selector("bc", "${APP_NAME}").exists();
                        }
                    }

                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${DEV_PROJECT}") {
                                openshift.selector("bc", "${APP_NAME}").startBuild("--wait").logs("-f")
                            }
                        }
                    }
                }
            }
        }

        stage('new build dev') {
            agent any
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject("${DEV_PROJECT}") {
                            return !openshift.selector("bc", "${APP_NAME}").exists();
                        }
                    }

                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${DEV_PROJECT}") {
                                def bc_args = ["${GIT_URL}", "--name ${APP_NAME}", "--strategy=source", "--image-stream=${STI_IMAGE}"]
                                def created = openshift.newApp(bc_args)
                                echo "new-app created ${created.count()} objects named: ${created.names()}"
                                def bc = created.narrow('bc')
                                bc.logs('-f')
                                def build = bc.related('builds')
                                build.untilEach(1) { // We want a minimum of 1 build
                                    return it.object().status.phase == "Complete"
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('deploy dev') {
            agent any
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${DEV_PROJECT}") {
                                openshift.selector("dc", "${APP_NAME}").rollout()
                                openshift.selector("dc", "${APP_NAME}").scale("--replicas=${DEV_REPLICA_COUNT}")
                                openshift.selector("dc", "${APP_NAME}").related('pods').untilEach("${DEV_REPLICA_COUNT}".toInteger()) {
                                    return (it.object().status.phase == "Running")
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('create dev route') {
            agent any
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject("${DEV_PROJECT}") {
                            return !openshift.selector("route", "${APP_NAME}").exists();
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${DEV_PROJECT}") {
                                openshift.selector("svc", "${APP_NAME}").expose()
                            }
                        }
                    }
                }
            }
        }

        stage('test deployment') {
            agent any
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    input 'Do you approve deployment to Test environment ?'
                }
            }
        }

        stage('create test project') {
            agent any
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject() {
                                return !openshift.selector("project", "${TEST_PROJECT}").exists();
                            }
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject() {
                                openshift.newProject("${TEST_PROJECT}")
                            }
                        }
                    }
                }
            }
        }

        stage('promote to test') {
            agent any
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${DEV_PROJECT}") {
                                openshift.tag("${DEV_PROJECT}/${APP_NAME}:${DEV_TAG}", "${TEST_PROJECT}/${APP_NAME}:${TEST_TAG}")
                            }
                        }
                    }
                }
            }
        }

        stage('new deploy test') {
            agent any
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${TEST_PROJECT}") {
                                return !openshift.selector("dc", "${APP_NAME}").exists();
                            }
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${TEST_PROJECT}") {
                                def bc_args = ["${TEST_PROJECT}/${APP_NAME}:${TEST_TAG}", "--name ${APP_NAME}"]
                                def created = openshift.newApp(bc_args)
                                echo "new-app created ${created.count()} objects named: ${created.names()}"
                            }
                        }
                    }
                }
            }
        }

        stage('scale replicas test') {
            agent any
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${TEST_PROJECT}") {
                                openshift.selector("dc", "${APP_NAME}").scale("--replicas=${TEST_REPLICA_COUNT}")
                                openshift.selector("dc", "${APP_NAME}").related('pods').untilEach("${TEST_REPLICA_COUNT}".toInteger()) {
                                    return (it.object().status.phase == "Running")
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('create test route') {
            agent any
            when {
                expression {
                    openshift.withCluster() {
                        openshift.withProject("${TEST_PROJECT}") {
                            return !openshift.selector("route", "${APP_NAME}").exists();
                        }
                    }
                }
            }
            steps {
                script {
                    openshift.withCluster() {
                        openshift.withCredentials() {
                            openshift.withProject("${TEST_PROJECT}") {
                                openshift.selector("svc", "${APP_NAME}").expose()
                            }
                        }
                    }
                }
            }
        }
    }
}

