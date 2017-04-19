node {
    def project = getProjectName()
    def source = 'https://github.com/eformat/node-hello-world-swagger.git'

    stage ('Build image') {
        echo 'Building image'
        buildApplication(project, source, build)
    }

    stage ('Deploy image') {
        echo 'Deploying image'
        deployApplication(project)
    }

    stage ('Create Route') {
        echo 'Creating a route to application'
        createRoute()
    }
}

// Creates a Build and triggers it
def buildApplication(String project, String source) {
    def ret = sh "oc new-app ${source}"
    if (ret != 0) {
        sh "echo 'Build exists'"
        def build = getBuildName()
        sh "oc start-build ${build} --follow --wait=true"
    }
}

// Create a Deployment and trigger it
def deployApplication(String project) {
    def ret = sh "oc new-app ${project}"
    if (ret != 0) {
        sh "echo 'Application already exists'"
        sh "oc deploy ${project} --latest"
    }
}

// Expose service to create a route
def createRoute(String project){
    sh "oc expose svc ${project} || echo 'Route already exists'"
}

// Get Project Name
def getProjectName() {
    def cmd1 = $/project=$(oc get project -o name);echo $${project##project/} > projectName/$
    sh cmd1
    name = readFile('projectName').trim()
    sh 'rm projectName'
    return name
}

// Get Build Name
def getBuildName() {
    def cmd2 = $/buildconfig=$(oc get bc -l app=node-hello-world-swagger -o name);echo $${buildconfig##buildconfig/} > buildName/$
    sh cmd2
    bld = readFile('buildName').trim()
    sh 'rm buildName'
    return bld
}

// Get Deploy Config Name
def getBuildName() {
    def cmd3 = $/deploymentconfig=$(oc get dc -l app=node-hello-world-swagger -o name);echo $${deploymentconfig##deploymentconfig/} > deployName/$
    sh cmd3
    dply = readFile('deployName').trim()
    sh 'rm deployName'
    return dply
}