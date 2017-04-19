node {
    def source = 'https://github.com/eformat/node-hello-world-swagger.git'

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
        sh "oc new-app ${source}"
    } finally {
        echo "new-app exists"
    }
}

// Expose service to create a route
def createRoute() {
    try {
        sh "oc expose svc ${project} || echo 'Route already exists'"
    } finally {
        echo "route exists"
    }    
}

// Get Build Name
def getBuildName() {
    def cmd1 = $/buildconfig=$(oc get bc -l app=node-hello-world-swagger -o name);echo $${buildconfig##buildconfig/} > buildName/$
    sh cmd1
    bld = readFile('buildName').trim()
    sh 'rm buildName'
    return bld
}

// Get Deploy Config Name
def getDeployName() {
    def cmd2 = $/deploymentconfig=$(oc get dc -l app=node-hello-world-swagger -o name);echo $${deploymentconfig##deploymentconfig/} > deployName/$
    sh cmd2
    dply = readFile('deployName').trim()
    sh 'rm deployName'
    return dply
}

// Get Service Name
def getDeployName() {
    def cmd3 = $/service=$(oc get svc -l app=node-hello-world-swagger -o name);echo $${service##service/} > serviceName/$
    sh cmd3
    svc = readFile('serviceName').trim()
    sh 'rm serviceName'
    return svc
}