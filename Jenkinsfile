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
                    label 'nodejs'
                }
            }
            stages {
                stage('Initialise') {
                    steps {
                        sh 'printenv'
                        checkout scm
                    }
                }
            }
        }
    }
}
