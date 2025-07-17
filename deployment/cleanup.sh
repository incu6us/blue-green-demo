#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="demo-app"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists kubectl; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    # Check if kubectl can connect to cluster
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Function to cleanup resources
cleanup_resources() {
    print_status "Cleaning up resources..."
    
    # Delete all resources in the namespace
    kubectl delete -f argo-rollout.yaml --ignore-not-found=true
    kubectl delete -f analysis-template.yaml --ignore-not-found=true
    kubectl delete -f istio-destinationrule.yaml --ignore-not-found=true
    kubectl delete -f istio-virtualservice.yaml --ignore-not-found=true
    kubectl delete -f istio-gateway.yaml --ignore-not-found=true
    kubectl delete -f services.yaml --ignore-not-found=true
    kubectl delete -f mock-backend-deployment.yaml --ignore-not-found=true
    kubectl delete -f configmap.yaml --ignore-not-found=true
    
    # Delete namespace (this will delete all remaining resources)
    kubectl delete namespace ${NAMESPACE} --ignore-not-found=true
    
    print_status "Resources cleaned up successfully"
}

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --force    Force cleanup without confirmation"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 -f"
    echo ""
}

# Parse command line arguments
FORCE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main cleanup function
cleanup() {
    print_status "Starting cleanup..."
    
    check_prerequisites
    
    if [ "$FORCE" = false ]; then
        print_warning "This will delete all resources in the '${NAMESPACE}' namespace"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Cleanup cancelled"
            exit 0
        fi
    fi
    
    cleanup_resources
    
    print_status "Cleanup completed successfully!"
}

# Run cleanup
cleanup 