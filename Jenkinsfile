node {
    def source = 'https://github.com/eformat/node-hello-world-swagger.git'

    stage ('Build image') {
        echo 'Building image'
        buildApplication(source)
    }

    stage ('Deploy image') {
        echo 'Deploying image'
        deployApplication(source)
    }

    stage ('Create Route') {
        echo 'Creating a route to application'
        createRoute()
    }
}

// Creates a Build and triggers it
def buildApplication(String source) {
    try {
        def ret = sh "oc new-app ${source}"
    } catch (error) {
      echo "new-app exists"
        def build = getBuildName()
        sh "oc start-build ${build} --follow --wait=true"
    }
}

// Create a Deployment and trigger it
def deployApplication(String source) {
    def deploy = getDeployConfigName()
    sh "oc rollout latest ${deploy}"
}

// Expose service to create a route
def createRoute(String project){
    sh "oc expose svc ${project} || echo 'Route already exists'"
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
def getDeployConfigName() {
    def cmd2 = $/deploymentconfig=$(oc get dc -l app=node-hello-world-swagger -o name);echo $${deploymentconfig##deploymentconfig/} > deployName/$
    sh cmd2
    dply = readFile('deployName').trim()
    sh 'rm deployName'
    return dply
}