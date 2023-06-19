set -e

rm -rf $WORKSPACE_TMP
mkdir -p $WORKSPACE_TMP
cd $WORKSPACE_TMP

IMAGE_NAME=ldap
BUILD_FOLDER=$WORKSPACE_TMP/ldap
BUILD_GIT=http://gitea:3000/dev/ldap.git
REPO=registry.tim


git clone $BUILD_GIT
cd $BUILD_FOLDER
git checkout alpine

IMAGE_TAG=$(git rev-parse HEAD)

/jenkins/buildkit/buildctl \
  --addr tcp://buildkit:1234 \
  build \
  --frontend dockerfile.v0 \
  --local context=$BUILD_FOLDER/ \
  --local dockerfile=$BUILD_FOLDER/ \
  --output type=image,\"name=$REPO/$IMAGE_NAME:$IMAGE_TAG,$REPO/$IMAGE_NAME:latest\",push=true
