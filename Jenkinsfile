node {
	def source = 'https://github.com/eformat/node-hello-world-swagger.git'
	def builder = 'registry.access.redhat.com/openshift3/nodejs-010-rhel7:latest'
	def project = 'node-hello-world-swagger'

	stage 'Build image'
    echo 'Building image'

    buildApplication(project, source, builder, 'openshift-dev')

    stage 'Deploy image'
    echo 'Deploying image'
	deployApplication(project, 'openshift-dev')

	stage 'Create Route'
	echo 'Creating a route to application'
}

// Creates a Build and triggers it
def buildApplication(String project, String source, String builder, String credentialsId){
    projectSet(project, credentialsId)
    def ret = sh "oc new-build --binary --name=aloha -l app=aloha"
    if (ret != 0) {
        sh "echo 'Build exists'"
        sh "oc start-build ${project} --follow --wait=true"
    }
}

// Create a Deployment and trigger it
def deployApplication(String project, String credentialsId){
    projectSet(project, credentialsId)
    def ret = sh "oc new-app ${project}"
    if (ret != 0) {
        sh "echo 'Application already exists'"
        sh "oc deploy ${project} --latest"
    }
}

// Expose service to create a route
def createRoute(String project, String credentialsId){
    projectSet(project, credentialsId)
    sh "oc expose svc ${project} || echo 'Route already exists'"
}

// Login and set the project
def projectSet(String project, String credentialsId){
    //Use a credential called openshift-dev
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: "${credentialsId}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
        sh "oc login --insecure-skip-tls-verify=true -u $env.USERNAME -p $env.PASSWORD https://${OPENSHIFT_MASTER}"
    }
    sh "oc new-project ${project} || echo 'Project exists'"
    sh "oc project ${project}"
}