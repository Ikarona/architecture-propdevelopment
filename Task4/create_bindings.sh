#!/usr/bin/env bash

set -e

# 1. RoleBinding: sa-team-a-dev -> namespace-admin (namespace: team-a)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-team-a-namespace-admin
  namespace: team-a
subjects:
  - kind: ServiceAccount
    name: sa-team-a-dev
    namespace: team-a
roleRef:
  kind: Role
  name: namespace-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# 2. RoleBinding: sa-team-b-dev -> namespace-admin (namespace: team-b)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-team-b-namespace-admin
  namespace: team-b
subjects:
  - kind: ServiceAccount
    name: sa-team-b-dev
    namespace: team-b
roleRef:
  kind: Role
  name: namespace-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# 3. ClusterRoleBinding: sa-security-auditor -> secret-reader
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: crb-secret-reader
subjects:
  - kind: ServiceAccount
    name: sa-security-auditor
    namespace: security
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
EOF

# 4. RoleBinding: sa-analytics-viewer -> namespace-viewer (namespace: analytics)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-analytics-namespace-viewer
  namespace: analytics
subjects:
  - kind: ServiceAccount
    name: sa-analytics-viewer
    namespace: analytics
roleRef:
  kind: Role
  name: namespace-viewer
  apiGroup: rbac.authorization.k8s.io
EOF

# 5. ClusterRoleBinding: sa-devops -> cluster-operator
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: crb-cluster-operator
subjects:
  - kind: ServiceAccount
    name: sa-devops
    namespace: security
roleRef:
  kind: ClusterRole
  name: cluster-operator
  apiGroup: rbac.authorization.k8s.io
EOF

# 6. ClusterRoleBinding: sa-ib-admin -> cluster-admin
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: crb-cluster-admin
subjects:
  - kind: ServiceAccount
    name: sa-ib-admin
    namespace: security
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

echo "✅ RoleBinding и ClusterRoleBinding успешно созданы."
