node {
    def source = 'https://github.com/eformat/node-hello-world-swagger.git'
    def name = "node-hello-world-swagger-${env.BRANCH_NAME}"

    echo "Build Number is: ${env.BUILD_NUMBER}"
    echo "Branch name is: ${env.BRANCH_NAME}"

    stage('Create Application') {
        echo 'Building image'
        createApplication(source)        
    }

    stage ('Build') {
        echo 'Building image'
        def build = getBuildName()
        openshiftBuild(buildConfig: build, showBuildLogs: 'true')
    }

    stage ('Deploy') {
        echo 'Deploying image'
        def deploy = getDeployName()
        openshiftDeploy(deploymentConfig: deploy)
    }

    stage ('Create Route') {
        echo 'Creating a route to application'
        createRoute()
    }
}

// Create application if it doesnt exist
def createApplication(String source) {
    try {
        sh "oc new-app ${source} --name=${name}"
   } catch(Exception e) {
        echo "new-app exists"
    }
}

// Expose service to create a route
def createRoute() {
    try {
        def service = getServiceName()
        sh "oc expose svc ${service}"
    } catch(Exception e) {
        echo "route exists"
    }    
}

// Get Build Name
def getBuildName() {
    def cmd1 = $/buildconfig=$(oc get bc -l app=${name} -o name);echo $${buildconfig##buildconfig/} > buildName/$
    sh cmd1
    bld = readFile('buildName').trim()
    sh 'rm buildName'
    return bld
}

// Get Deploy Config Name
def getDeployName() {
    def cmd2 = $/deploymentconfig=$(oc get dc -l app=${name} -o name);echo $${deploymentconfig##deploymentconfig/} > deployName/$
    sh cmd2
    dply = readFile('deployName').trim()
    sh 'rm deployName'
    return dply
}

// Get Service Name
def getServiceName() {
    def cmd3 = $/service=$(oc get svc -l app=${name} -o name);echo $${service##service/} > serviceName/$
    sh cmd3
    svc = readFile('serviceName').trim()
    sh 'rm serviceName'
    return svc
}