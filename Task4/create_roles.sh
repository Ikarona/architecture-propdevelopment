#!/usr/bin/env bash

set -e

# 1. ClusterRole: view-only
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: view-only
rules:
  - apiGroups: ["", "apps", "batch", "networking.k8s.io", "rbac.authorization.k8s.io"]
    resources: ["*"]
    verbs: ["get", "list", "watch"]
EOF

# 2. ClusterRole: cluster-operator
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-operator
rules:
  - apiGroups: ["", "apps", "batch"]
    resources:
      - deployments
      - daemonsets
      - replicasets
      - pods
      - services
      - configmaps
      - secrets
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: ["", "apps", "batch"]
    resources: ["namespaces"]
    verbs: ["get", "list", "watch"]
EOF

# 3. ClusterRole: secret-reader
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-reader
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "watch"]
EOF

# 4. Role: namespace-admin в namespace team-a
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-admin
  namespace: team-a
rules:
  - apiGroups: ["", "apps", "batch"]
    resources:
      - pods
      - deployments
      - services
      - configmaps
      - secrets
      - persistentvolumeclaims
      - statefulsets
      - daemonsets
    verbs: ["*"]
EOF

# 5. Role: namespace-admin в namespace team-b
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-admin
  namespace: team-b
rules:
  - apiGroups: ["", "apps", "batch"]
    resources:
      - pods
      - deployments
      - services
      - configmaps
      - secrets
      - persistentvolumeclaims
      - statefulsets
      - daemonsets
    verbs: ["*"]
EOF

# 6. Role: namespace-viewer в namespace analytics
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-viewer
  namespace: analytics
rules:
  - apiGroups: ["", "apps", "batch"]
    resources: ["*"]
    verbs: ["get", "list", "watch"]
EOF
