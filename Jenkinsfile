node {
    def source = "https://github.com/eformat/node-hello-world-swagger.git#${env.BRANCH_NAME}"
    def branch = "${env.BRANCH_NAME}"
    branch = branch.toLowerCase()
    def name = "node-hello-world-swagger-${branch}"

    echo "Build Number is: ${env.BUILD_NUMBER}"
    echo "Branch name is: ${env.BRANCH_NAME}"
    //def commit_id = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim() 
    //echo "Git Commit is: ${commit_id}"
    echo "Workspace: ${WORKSPACE}"

    stage ('Build') {
        echo 'Building image'
        def build = getBuildName(name)        
        createOrBuildApplication(source, name, build)
    }

    stage ('Deploy') {
        echo 'Deploying image'
        def deploy = getDeployName(name)
        openshiftDeploy(deploymentConfig: deploy)
    }

    stage ('Create Route') {
        echo 'Creating a route to application'
        createRoute(name)
    }
}

// Create application if it doesnt exist
def createOrBuildApplication(String source, String name, String build) {
    try {
        openshift.newApp("${source}","--name=${name}","--labels=app=${name}")
   } catch(Exception e) {
        echo "new-app exists"
        openshiftBuild(buildConfig: build, showBuildLogs: 'true')
    }
}

// Expose service to create a route
def createRoute(String name) {
    try {
        def service = getServiceName(name)
        sh "oc expose svc ${service}"
    } catch(Exception e) {
        echo "route exists"
    }    
}

// Get Build Name
def getBuildName(String name) {
    def cmd1 = $/buildconfig=$(oc get bc -l app=${name} -o name);echo $${buildconfig##buildconfig/}/$
    bld = sh(returnStdout: true, script: cmd1).trim()    
    return bld
}

// Get Deploy Config Name
def getDeployName(String name) {
    def cmd2 = $/deploymentconfig=$(oc get dc -l app=${name} -o name);echo $${deploymentconfig##deploymentconfig/}/$
    dply = sh(returnStdout: true, script: cmd2).trim()    
    return dply
}

// Get Service Name
def getServiceName(String name) {
    def cmd3 = $/service=$(oc get svc -l app=${name} -o name);echo $${service##service/}/$
    svc = sh(returnStdout: true, script: cmd3).trim()        
    return svc
}