node {
    def source = 'https://github.com/eformat/node-hello-world-swagger.git'
    def branch = "${env.BRANCH_NAME}"
    branch = branch.toLowerCase()
    def name = "node-hello-world-swagger-${branch}"

    echo "Build Number is: ${env.BUILD_NUMBER}"
    echo "Branch name is: ${env.BRANCH_NAME}"

    stage('Create Application') {
        echo 'Building image'
        createApplication(source, name)        
    }

    stage ('Build') {
        echo 'Building image'
        def build = getBuildName(name)
        openshiftBuild(buildConfig: build, showBuildLogs: 'true')
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
def createApplication(String source, String name) {
    try {
        sh "oc new-app ${source} --name=${name}"
   } catch(Exception e) {
        echo "new-app exists"
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
    def cmd1 = $/buildconfig=$(oc get bc -l app=${name} -o name);echo $${buildconfig##buildconfig/} > buildName/$
    sh cmd1
    bld = readFile('buildName').trim()
    sh 'rm buildName'
    return bld
}

// Get Deploy Config Name
def getDeployName(String name) {
    def cmd2 = $/deploymentconfig=$(oc get dc -l app=${name} -o name);echo $${deploymentconfig##deploymentconfig/} > deployName/$
    sh cmd2
    dply = readFile('deployName').trim()
    sh 'rm deployName'
    return dply
}

// Get Service Name
def getServiceName(String name) {
    def cmd3 = $/service=$(oc get svc -l app=${name} -o name);echo $${service##service/} > serviceName/$
    sh cmd3
    svc = readFile('serviceName').trim()
    sh 'rm serviceName'
    return svc
}