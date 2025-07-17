#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REGISTRY="your-registry"
TAG="latest"

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
    
    if ! command_exists docker; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Function to build and push demo app image
build_demo_app() {
    print_status "Building demo app image..."
    
    # Build the image
    docker build -t ${REGISTRY}/demo-app:${TAG} .
    
    # Push the image
    print_status "Pushing demo app image..."
    docker push ${REGISTRY}/demo-app:${TAG}
    
    print_status "Demo app image built and pushed successfully"
}

# Function to build and push mock backend image
build_mock_backend() {
    print_status "Building mock backend image..."
    
    # Build the image
    docker build -t ${REGISTRY}/demo-app-mock-backend:${TAG} ./mock-backend
    
    # Push the image
    print_status "Pushing mock backend image..."
    docker push ${REGISTRY}/demo-app-mock-backend:${TAG}
    
    print_status "Mock backend image built and pushed successfully"
}

# Function to show usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -r, --registry REGISTRY    Docker registry (default: your-registry)"
    echo "  -t, --tag TAG              Image tag (default: latest)"
    echo "  -a, --all                  Build both demo app and mock backend"
    echo "  -d, --demo                 Build only demo app"
    echo "  -m, --mock                 Build only mock backend"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -r docker.io/myuser -t v1.0.0 -a"
    echo "  $0 -r docker.io/myuser -d"
    echo "  $0 -r docker.io/myuser -m"
    echo ""
}

# Parse command line arguments
BUILD_DEMO=false
BUILD_MOCK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -a|--all)
            BUILD_DEMO=true
            BUILD_MOCK=true
            shift
            ;;
        -d|--demo)
            BUILD_DEMO=true
            shift
            ;;
        -m|--mock)
            BUILD_MOCK=true
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

# If no specific build target is specified, build both
if [ "$BUILD_DEMO" = false ] && [ "$BUILD_MOCK" = false ]; then
    BUILD_DEMO=true
    BUILD_MOCK=true
fi

# Main build function
build() {
    print_status "Starting image build process..."
    print_status "Registry: ${REGISTRY}"
    print_status "Tag: ${TAG}"
    
    check_prerequisites
    
    if [ "$BUILD_DEMO" = true ]; then
        build_demo_app
    fi
    
    if [ "$BUILD_MOCK" = true ]; then
        build_mock_backend
    fi
    
    print_status "Image build process completed successfully!"
    print_status "You can now deploy using: ./deploy.sh -r ${REGISTRY}"
}

# Run build
build 