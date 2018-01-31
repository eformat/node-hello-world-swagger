#!groovy

echo "Build Number is: ${env.BUILD_NUMBER}"
echo "Job Name is: ${env.JOB_NAME}"

openshift.withCluster() {
    pipeline {
        environment {
            //CREDS = credentials('somecreds')
            def commit_id, source, origin_url, name
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
        parameters {
            string(name: 'Greeting', defaultValue: 'Hello', description: 'Hi Mike!')
        }
        openshift.withProject() {
            echo "Using project: ${openshift.project()}"
            stages {
                stage('initialise') {
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

                /*
                stage('ci build') {
                    when {
                        branch 'PR-*'
                    }
                    steps {
                    }
                }

                stage('build') {
                    when {
                        branch 'master'
                    }
                    steps {
                        timeout(10) {
                            def build = openshift.selector("bc", "${name}-master")
                            if (build.count() == 1) {
                                // existing bc
                                def buildSelector = build.startBuild()
                                buildSelector.logs("-f")
                            } else {
                                // create new build
                                def bc_args = [origin_url, "--name ${name}-master", "--strategy=source"]
                                def created = openshift.newApp(bc_args)
                                echo "new-app created ${created.count()} objects named: ${created.names()}"
                                def bc = created.narrow('bc')
                                bc.logs('-f')
                                build = bc.related('builds')
                                build.untilEach(1) { // We want a minimum of 1 build
                                    return it.object().status.phase == "Complete"
                                }
                            }
                        }
                    }
                }

                stage('deploy') {
                    steps {
                        timeout(5) {
                            def rm = openshift.selector("dc", "${name}-master").rollout()
                            openshift.selector("dc", "${name}-master").related('pods').untilEach(1) {
                                return (it.object().status.phase == "Running")
                            }
                        }
                    }
                }

                stage('create route') {
                    steps {
                        timeout(1) {
                            def route = openshift.selector("route", "${name}-master")
                            if (route.count() != 1) {
                                def svc = openshift.selector("svc", "${name}-master")
                                def result = svc.expose()
                                return ("${result.status}" == 0)
                            }
                        }
                    }
                }
                */
            }
            openshift.doAs('my-privileged-credential') {
                stage('promote to test') {
                    input "Ready to update Test Project?"

                    steps {
                        timeout(10) {
                            // export as a template or map of exportable objects
                            // change image to reference :test image
                            // add in configmaps / secrets support
                            def project = openshift.selector("project", "node-hello-test")
                            if (project.count() != 1) {
                                openshift.newProject('node-hello-test')
                            }
                            openshift.withProject('node-hello-test') {
                                def maps = openshift.selector(['dc', 'svc', 'route'], [app: "${name}-master"])
                                def objs = maps.objects(exportable: true)
                                // Modify the models as you see fit.
                                def timestamp = "${System.currentTimeMillis()}"
                                for (obj in objs) {
                                    obj.metadata.labels["promoted-on"] = timestamp
                                }
                                maps.delete('--ignore-not-present')
                                openshift.create(objs)
                                // Let's wait until at least one pod is Running
                                maps.related('pods').untilEach {
                                    return it.object().status.phase == 'Running'
                                }
                            }
                        }
                    }
                }
            }

            /*
            stage('promote to prod in a new cluster') {
                // with another cluster - repeat test steps using :prod
                openshift.withCluster( 'prodcluster' ) {

                }
            }*/

            /* stage('tag') {
                steps {
                    // if everything else succeeded, tag the ${templateName}:latest image as ${templateName}-staging:latest
                    // a pipeline build config for the staging environment can watch for the ${templateName}-staging:latest
                    // image to change and then deploy it to the staging environment
                    openshift.tag("${templateName}:latest", "${templateName}-staging:latest")
                }
            }*/
        }
    }
}

