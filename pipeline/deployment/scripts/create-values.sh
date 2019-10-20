#!/bin/bash
# =====================================
#     Author: sandow
#     Email: j.k.yulei@gmail.com
#     HomePage: www.gsandow.com
# =====================================
env
export servicename=gsb
/root/rgtpl -s gsb-infra/pipeline/deployment/sharedservices/infra/terraform-value.template -d  ${servicename}/values.tfvars -f gsb-conf/values.yaml

cat ${servicename}/values.tfvars
ls -R
