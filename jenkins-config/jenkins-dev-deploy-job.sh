if [ -z "$AUTH_TOKEN" ]; then
  AUTH_TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
fi

if [ -e /run/secrets/kubernetes.io/serviceaccount/ca.crt ]; then
  alias oc="oc -n $PROJECT --token=$AUTH_TOKEN --server=$OPENSHIFT_API_URL --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt "
else 
  alias oc="oc -n $PROJECT --token=$AUTH_TOKEN --server=$OPENSHIFT_API_URL --insecure-skip-tls-verify "
fi

# this works if on PaaS
# TEST_ENDPOINT=`oc get service ${SERVICE} -t '{{.spec.clusterIP}}{{":"}}{{ $a:= index .spec.ports 0 }}{{$a.port}}'`
# else external, use route
TEST_ENDPOINT=`oc get route ${ROUTE} -t '{{.spec.host}}'`


# we have a rolling deployment - so no need to scale down
# but wany old_rc so we can test if new one deployed
rm old_rc_id || true
echo "none" > old_rc_id
oc get rc -t '{{ range .items }}{{.spec.selector.deploymentconfig}}{{" "}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -e "^$DEPLOYMENT_CONFIG " | awk '{print $2}' | while read -r test_rc_id; do
#  echo "Scaling down old deployment $test_rc_id"
#  oc scale --replicas=0 rc $test_rc_id
  echo $test_rc_id >> old_rc_id
done
old_rc_id=`cat old_rc_id | awk -F - '{print $NF" "$0}' | sort -n | awk '{print $2}' | tail -n 1`

# wait for old pods to be torn down
# TODO should poll instead.
sleep 2

echo "Triggering new application build and deployment"
BUILD_ID=`oc start-build ${BUILD_CONFIG} -n ${PROJECT}`

# stream the logs for the build that just started
rc=1
count=0
attempts=3
set +e
while [ $rc -ne 0 -a $count -lt $attempts ]; do
  oc build-logs $BUILD_ID
  rc=$?
  count=$(($count+1))
done
set -e

echo "Checking build result status"
rc=1
count=0
attempts=100
while [ $rc -ne 0 -a $count -lt $attempts ]; do
  status=`oc get build ${BUILD_ID} -t '{{.status.phase}}'`
  if [[ $status == "Failed" || $status == "Error" || $status == "Canceled" ]]; then
    echo "Fail: Build completed with unsuccessful status: ${status}"
    exit 1
  fi

  if [ $status == "Complete" ]; then
    echo "Build completed successfully, will test deployment next"
    rc=0
  else 
    count=$(($count+1))
    echo "Attempt $count/$attempts"
    sleep 2
  fi
done

if [ $rc -ne 0 ]; then
    echo "Fail: Build did not complete in a reasonable period of time"
    exit 1
fi


# scale up the test deployment
# if this gets scaled up before the new deployment occurs from the build,
# bad things happen...need to make sure a new deployment has occurred first.
count=0
attempts=20
new_rc_id=$old_rc_id
while [ $new_rc_id == $old_rc_id -a $count -lt $attempts ]; do
  rm new_rc_id || true
  oc get rc -t '{{ range .items }}{{.spec.selector.deploymentconfig}}{{" "}}{{.metadata.name}}{{"\n"}}{{end}}' | grep -e "^$DEPLOYMENT_CONFIG " | awk '{print $2}' | while read -r test_rc_id; do
    echo $test_rc_id >> new_rc_id
  done
  new_rc_id=`cat new_rc_id | awk -F - '{print $NF" "$0}' | sort -n | awk '{print $2}' | tail -n 1`
  count=$(($count+1))
  sleep 1
done
if [ $count -eq $attempts ]; then
  echo "Failure: Never found new deployment"
  exit 1
fi

test_rc_id=`cat new_rc_id | awk -F - '{print $NF" "$0}' | sort -n | awk '{print $2}' | tail -n 1`
#echo "Scaling up new deployment $test_rc_id"
#oc scale --replicas=1 rc $test_rc_id

# wait for rc to scale before checking
sleep 5

# check we have replicas for new deployment
replicas=`oc get rc/$test_rc_id -t '{{.spec.replicas}}{{"\n"}}'`
if [ $replicas -lt 1 ]; then
  echo "Failure: No pods found for new deployment"
  exit 1
fi

# check deploy pod status, if we have one - it failed
# note this will trigger another build
# if status is non zero, so not necessarily total failure but
# this job certainly didn't do what was expected


count=0
attempts=10
deploy_status="Running"
while [ ${deploy_status[0]} == "Running" -a $count -lt $attempts ]; do
  deploy_status=($(echo `oc get pod ${BUILD_ID}-deploy -t '{{.status.phase}}' 2>&1 | awk '{print $1 ":" $6$7}'` | sed 's/:/ /g'))

  if [[ ${deploy_status[0]} == "Complete" || ${deploy_status[1]} == "notfound" ]]; then
    echo "Build completed successfully, will test deployment next"
    count=11
  elif [[ ${deploy_status[0]} == "Failed" || ${deploy_status[0]} == "Error" || ${deploy_status[0]} == "Canceled" ]]; then
    echo "Fail: Deploy completed with unsuccessful status: ${status}"
    exit 1
  else 
    count=$(($count+1))
    echo "Attempt $count/$attempts"
    sleep 2
  fi
done

echo "Checking for successful test deployment at $TEST_ENDPOINT"
set +e
rc=1
count=0
attempts=100
while [ $rc -ne 0 -a $count -lt $attempts ]; do
  if curl -s --connect-timeout 2 $TEST_ENDPOINT >& /dev/null; then
    rc=0
    break
  fi
  count=$(($count+1))
  echo "Attempt $count/$attempts"
  sleep 2
done
set -e

if [ $rc -ne 0 ]; then
    echo "Failed to access test deployment, aborting roll out."
    exit 1
fi


# Tag the image into production
#echo "Test deployment succeeded, rolling out to production..."
#oc tag $TEST_IMAGE_TAG $PRODUCTION_IMAGE_TAG
