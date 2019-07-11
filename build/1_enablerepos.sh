set -e

echo "ENABLING REPOSITORIES"
subscription-manager register --username $RHN_USER --password $RHN_PASS

# Selecting the right pool
# export token=$(subscription-manager list --all --available --matches ES0113909 --pool-only | tail -n 1)
export token=$(subscription-manager list --all --available --matches '*Red Hat Enterprise Linux Server*' --pool-only | head -n 1)
# export token=$(subscription-manager list --all --available --matches '*Red Hat Enterprise Linux Developer Suite*' --pool-only | head -n1)

echo $token
subscription-manager attach --pool=$token

subscription-manager repos --disable "*" --enable rhel-8-for-x86_64-baseos-rpms --enable rhel-8-for-x86_64-appstream-rpms   --enable rhel-8-for-x86_64-supplementary-rpms
