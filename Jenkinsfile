node {
	def source = 'https://github.com/eformat/node-hello-world-swagger.git'
	def builder = 'registry.access.redhat.com/openshift3/nodejs-010-rhel7:latest'
	def project = 'node-hello-world-swagger'

    //stage 'Checkout'
	//git branch: 'master', url: "${source}"

	stage 'Build image'
    echo 'Building image'
    buildApplication(project, source, builder, 'openshift-dev')

    stage 'Deploy image'
    echo 'Deploying image'
	deployApplication(project, 'openshift-dev')

	stage 'Verify image deploy'
	// add step

	stage 'Create Route'
	echo 'Creating a route to application'

	// Verify service
	// openShiftVerifyService
}

// Creates a Build and triggers it
def buildApplication(String project, String source, String builder, String credentialsId){
    projectSet(project, credentialsId)
    def ret = sh "oc new-build ${builder}~${source} || echo 'Build already exists' && exit -1"
    if (ret < 0) {
    	openShiftBuild(buildConfig: ${project})
    }
}

// Create a Deployment and trigger it
def deployApplication(String project, String credentialsId){
    projectSet(project, credentialsId)
    def ret = sh "oc new-app ${project} || echo 'DeployConfig already exists' && exit -1"
    if (ret < 0) {
        openShiftDeploy(deployConfig: {project})
    }
}

// Verify deploy
def verifyDeployment(String project, String credentialsId){
    projectSet(project, credentialsId)
    openShiftVerifyDeployment(depCfg: ${project}, replicaCount: 1, verifyReplicaCount: true)
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