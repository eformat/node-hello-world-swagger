# Swagger Node Hello World

[Swagger node server using mocks] (https://www.npmjs.com/package/swagger-server)

[Swagger codegen] (https://github.com/swagger-api/swagger-codegen)

## Run locally

    npm install
    npm start

[Browse to here to test] (http://localhost:8080)


## Run in OSEv3

Users:

     base user = mike
     developer = udev1
     tester    = utest1
     prod      = uprod1

Create users

    for x in udev1 utest1 uprod1; do
        htpasswd -b /etc/openshift/openshift-passwd $x <password>
    done

As cluster admin, setup projects so we can set node-selector

    for x in helloworld-dev helloworld-test helloworld-prod; do
        oadm new-project $x --display-name="HelloWorld $x demo project" --description='HelloWorld project' --node-selector='region=primary' --admin=mike
     done

As mike user, setup permissions

    oc project helloworld-dev
    oc policy add-role-to-user edit udev1
    oc policy add-role-to-user view utest1
    oc policy add-role-to-user view uprod1

    oc project helloworld-test
    oc policy add-role-to-user edit utest1
    oc policy add-role-to-user view uprod1
    oc policy add-role-to-group system:image-puller system:serviceaccounts:helloworld-test -n helloworld-dev

    oc project helloworld-prod
    oc policy add-role-to-user edit uprod1
    oc policy add-role-to-group system:image-puller system:serviceaccounts:helloworld-prod -n helloworld-dev

At default scope create global jenkins user for builds. This could be project scoped as well if desired

    oc create -f - <<EOF
    {
      "apiVersion": "v1",
      "kind": "ServiceAccount",
      "namespace" : "default",
      "metadata": {
          "name": "jenkins"
      }
    }
    EOF

Add jenkins user to projects

    oc project helloworld-dev
    oc policy add-role-to-user edit system:serviceaccount:default:jenkins

Manual Step: Get jenkins secret token - put this in jenkins jobs xml

    oc describe serviceaccount jenkins -n default
    oc describe secret jenkins-token-5kyvy

    oc project helloworld-test
    oc policy add-role-to-user edit system:serviceaccount:default:jenkins

    oc project helloworld-prod
    oc policy add-role-to-user edit system:serviceaccount:default:jenkins

Dev project

    oc project helloworld-dev
    oc new-app https://github.com/eformat/node-hello-world-swagger.git --name=helloworld --strategy=sti
    oc expose service helloworld --name=helloworld --hostname=helloworld-dev.apps.example.com

Can now perform jenkins builds

Test + Prod projects -  should be setup and ready to promote to using jenkins pipeline

Have not separated Jenkins logins - but can do this as well if desired

## Jenkins Config

Deploy jobs and pipeline into remote jenkins from scratch

    curl -X POST http://admin:password@localhost:8080/job/helloworld-dev-build/doDelete
    curl -X POST http://admin:password@localhost:8080/job/helloworld-test-deploy/doDelete
    curl -X POST http://admin:password@localhost:8080/view/HelloWorld%20Pipeline/doDelete
    cat jenkins-ose-dev-deploy-build-job.xml | curl -X POST -H "Content-Type: application/xml" -H "Expect: " --data-binary @- http://admin:password@localhost:8080/createItem?name=helloworld-dev-build
    cat jenkins-ose-test-deploy-build-job.xml | curl -X POST -H "Content-Type: application/xml" -H "Expect: " --data-binary @- http://admin:password@localhost:8080/createItem?name=helloworld-test-deploy
    cat jenkins-helloworld-pipeline.xml | curl -X POST -H "Content-Type: application/xml" -H "Expect: " --data-binary @- http://admin:password@localhost:8080/createView?name=HelloWorld%20Pipeline

Export jenkins configs for development

    curl -s http://admin:password@localhost:8080/job/helloworld-test-deploy/config.xml > jenkins-ose-test-deploy-build-job.xml
    curl -s http://admin:password@localhost:8080/job/helloworld-test-deploy/config.xml > jenkins-ose-test-deploy-build-job.xml
    curl -s http://admin:password@localhost:8080/job/helloworld-prod-deploy/config.xml > jenkins-ose-prod-deploy-build-job.xml
    curl -s http://admin:password@localhost:8080/view/HelloWorld%20Pipeline/config.xml > jenkins-helloworld-pipeline.xml

## Generate JAX-RS stubs (or any other code stubs - see codegen link)

    npm start

    java -jar ~/git/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate \
    -i http://localhost:8080/api-docs/ \
    -l jaxrs \
    -o samples/jaxrs \
    -c swagger-generate-java-config.json```

