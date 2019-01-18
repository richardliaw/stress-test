#!/bin/ash
set +e

UPLOAD_DIR="'s3://richardresults/test_stress'"
LOCAL_DIR=$(echo \'$(pwd)\')
WORKDIR=~/stress_test_dir
mkdir $WORKDIR || true

setup_testing() {
    echo "Setting up testing" 
    source activate tensorflow_p36 && pip uninstall -y ray || true
    local FILE=ray-0.6.2-cp36-cp36m-manylinux1_x86_64.whl
    wget https://s3-us-west-2.amazonaws.com/ray-wheels/latest/$FILE
    source activate tensorflow_p36 && pip install -U $FILE[rllib]
    rm -rf $FILE
}

run_apex_test() {
    echo "Running Ape-X Test"
    cronwrap -c "bash -c 'source activate tensorflow_p36'" # && rllib train -f apex-stress-test.yaml'"# -e "rliaw@berkeley.edu, ekhliang@gmail.com"
}

cleanup_ray_session() {
    DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
    local LOGDIR=ray-logs-$DATE
    mkdir $LOGDIR || true
    pushd $LOGDIR
      zip -r $LOGDIR.zip /tmp/ray/session_*
      aws s3 cp $LOGDIR.zip s3://richardresults/$LOGDIR/ray_logs.zip
    popd $LOGDIR
    rm -rf /tmp/ray/
}

while true; do
    echo $LOCAL_DIR
    echo $UPLOAD_DIR
    cat ./apex-stress-tmpl.yaml | sed -e "s,<<<UPLOAD_DIR>>>,$UPLOAD_DIR,; s,<<<LOCAL_DIR>>>,$LOCAL_DIR,;" > apex-stress-test.yaml
    cat apex-stress-test.yaml
    setup_testing
    run_apex_test
    cleanup_ray_session
done


