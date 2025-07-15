#!/usr/bin/env bash

set -e

for ns in team-a team-b security analytics; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl -n team-a create sa sa-team-a-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl -n team-b create sa sa-team-b-dev --dry-run=client -o yaml | kubectl apply -f -

kubectl -n security create sa sa-security-auditor --dry-run=client -o yaml | kubectl apply -f -

kubectl -n analytics create sa sa-analytics-viewer --dry-run=client -o yaml | kubectl apply -f -

kubectl -n security create sa sa-devops --dry-run=client -o yaml | kubectl apply -f -

kubectl -n security create sa sa-ib-admin --dry-run=client -o yaml | kubectl apply -f -

