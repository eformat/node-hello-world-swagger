#!groovy

echo "Build Number is: ${env.BUILD_NUMBER}"
echo "Job Name is: ${env.JOB_NAME}"

def commit_id, source, origin_url, name

openshift.withCluster() {
    openshift.withProject() {
        echo "Using project: ${openshift.project()}"
        pipeline {
            environment {
                //CREDS = credentials('somecreds')
            }
            options {
                // set a timeout of 20 minutes for this pipeline
                timeout(time: 20, unit: 'MINUTES')
            }
            agent {
                node {
                    // spin up a node.js slave pod to run this build on
                    // when running Jenkinsfile from SCM this implicitly does a checkout scm
                    label 'nodejs'
                }
            }
            stages {
                stage('Initialise') {
                    steps {
                        sh 'printenv'
                        dir("${WORKSPACE}") {
                            commit_id = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                            echo "Git Commit is: ${commit_id}"
                            def cmd0 = $/name=$(git config --local remote.origin.url); name=$${name##*/}; echo $${name%%.git}/$
                            name = sh(returnStdout: true, script: cmd0).trim()
                            echo "Name is: ${name}"
                        }
                        origin_url = sh(returnStdout: true, script: 'git config --get remote.origin.url').trim()
                        source = "${origin_url}#${commit_id}"
                        echo "Source URL is: ${source}"
                    }
                }

                stage('CI Build') {
                    when {
                        branch 'PR-*'
                    }
                    steps {
                    }
                }

                stage('Build') {
                    when {
                        branch 'master'
                    }
                    steps {
                        def bc_args = [source, "--name ${name}-master"]
                        def bc = openshift.newApp(bc_args).narrow('bc')
                        def builds = bc.related('builds')
                        builds.untilEach(1) { // We want a minimum of 1 build
                            return it.object().status.phase == "Complete"
                        }
                    }
                }
            }
        }
    }
}
