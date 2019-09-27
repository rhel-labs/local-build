# set -e

echo "ENABLING REPOSITORIES"
subscription-manager register --username $RHSM_USER --password $RHSM_PASS

# Typical SKU PoolIDs / Names
# Employee:             ES0113909 / 'Employee SKU'
# RHEL Server Standard: RH00004 / 'Red Hat Enterprise Linux Server, Standard (Physical or Virtual Nodes)' OR 'Red Hat Enterprise Linux Server*'
# RHEL Server Entry:    RH00010 / 'Red Hat Enterprise Linux Server Entry Level with Smart Management, Self-support' OR 'Red Hat Enterprise Linux Server*'
# RHEL Developer Suite: RH2262474 / 'Red Hat Enterprise Linux Developer Suite'

pool_match=RH00004
# pool_match='Red Hat Enterprise Linux Server*'

export token=$(subscription-manager list --all --available --matches "$pool_match" --pool-only | head -n 1)

echo $token
subscription-manager attach --pool=$token

# Configure main repositories
subscription-manager repos --disable "*" \
--enable rhel-8-for-x86_64-baseos-rpms \
--enable rhel-8-for-x86_64-appstream-rpms  \
--enable rhel-8-for-x86_64-supplementary-rpms
