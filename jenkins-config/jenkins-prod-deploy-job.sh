if [ -z "$AUTH_TOKEN" ]; then
  AUTH_TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
fi

if [ -e /run/secrets/kubernetes.io/serviceaccount/ca.crt ]; then
  alias oc="oc --token=$AUTH_TOKEN --server=$OPENSHIFT_API_URL --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt "
else 
  alias oc="oc --token=$AUTH_TOKEN --server=$OPENSHIFT_API_URL --insecure-skip-tls-verify "
fi

oc project $DEV_PROJECT -n $DEV_PROJECT

IS_NAME=`oc get is| tail -1|awk '{print $1}'`

# get full name of the image
FULL_IMAGE_NAME=`oc describe is ${IS_NAME} -n $DEV_PROJECT | grep -a1 "Tag" | tail -1 | awk '{print $6}'`

# Tag to promote to QA
oc tag $FULL_IMAGE_NAME $DEV_PROJECT/${IS_NAME}:prod -n $DEV_PROJECT

# This should automatically initiate deployment
oc project $PROD_PROJECT -n $PROD_PROJECT

# Find the DeploymentConfig to see if this is a new deployment or just needs an update
DC_ID=`oc get dc -n $PROD_PROJECT | tail -1| awk '{print $1}'`

if [ $DC_ID == "NAME" ]; then
  oc new-app $DEV_PROJECT/${IS_NAME}:prod --name=$APP_NAME -n $PROD_PROJECT
  SVC_ID=`oc get svc -n $PROD_PROJECT | tail -1 | awk '{print $1}'`
  oc expose service $SVC_ID --hostname=$APP_HOSTNAME -n $PROD_PROJECT
fi

# find the new rc based on the FULL_IMAGE_NAME=$FULL_IMAGE_NAME
RC_ID=""
attempts=75
count=0
while [ -z "$RC_ID" -a $count -lt $attempts ]; do
  RC_ID=`oc get rc -n $PROD_PROJECT | grep $FULL_IMAGE_NAME | awk '{print $1}'`
  count=$(($count+1))
  sleep 2
done

if [ -z "$RC_ID" ]; then
  echo "Fail: App deployment was not successful"
  exit 1 
fi

# Scale the app to 1 pod (just to make sure)
scale_result=`oc scale rc $RC_ID --replicas=1 -n $PROD_PROJECT | awk '{print $3}'`

if [ $scale_result != "scaled" ]; then
  echo "Fail: Scaling not successful"
  exit 1 
fi
