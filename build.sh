#!/usr/bin/env bash

usage() {
  cat <<HERE
Usage:
  build.sh --job-artifacts <comma-separated-paths-to-job-artifacts> --from-archive <path-to-dist-archive> [--image-name <image>]
  build.sh --job-artifacts <comma-separated-paths-to-job-artifacts> --from-release --flink-version <x.x.x> --scala-version <x.xx> [--image-name <image>]
  build.sh --help

  If the --image-name flag is not used the built image name will be 'flink-job'.
HERE
  exit 1
}

while [[ $# -ge 1 ]]
do
key="$1"
  case $key in
    --job-artifacts)
    JOB_ARTIFACTS_PATH="$2"
    shift
    ;;
    --from-local-dist)
    FROM_LOCAL="true"
    ;;
    --from-archive)
    FROM_ARCHIVE="$2"
    shift
    ;;
    --from-release)
    FROM_RELEASE="true"
    ;;
    --image-name)
    IMAGE_NAME="$2"
    shift
    ;;
    --flink-version)
    FLINK_VERSION="$2"
    shift
    ;;
    --scala-version)
    SCALA_VERSION="$2"
    shift
    ;;
    --kubernetes-certificates)
    CERTIFICATES_DIR="$2"
    shift
    ;;
    --help)
    usage
    ;;
    *)
    # unknown option
    ;;
  esac
  shift
done

IMAGE_NAME=${IMAGE_NAME:-flink-job}

# TMPDIR must be contained within the working directory so it is part of the
# Docker context. (i.e. it can't be mktemp'd in /tmp)
TMPDIR=_TMP_

cleanup() {
    rm -rf "${TMPDIR}"
}
#trap cleanup EXIT

mkdir -p "${TMPDIR}"

JOB_ARTIFACTS_TARGET="${TMPDIR}/artifacts"
mkdir -p ${JOB_ARTIFACTS_TARGET}

OLD_IFS="$IFS"
IFS=","
job_artifacts_array=(${JOB_ARTIFACTS_PATH})
IFS="$OLD_IFS"
for artifact in ${job_artifacts_array[@]}; do
  cp ${artifact} ${JOB_ARTIFACTS_TARGET}/
done


if [ -n "${FROM_RELEASE}" ]; then

  echo "### Dont use from release"

elif [ -n "${FROM_LOCAL}" ]; then

  DIST_DIR="../../flink-dist/target/flink-*-bin"
  FLINK_DIST="${TMPDIR}/flink.tgz"
  echo "Using flink dist: ${DIST_DIR}"
  tar -C ${DIST_DIR} -cvzf "${FLINK_DIST}" .

elif [ -n "${FROM_ARCHIVE}" ]; then
    echo "### from archive"
    echo "TMPDIR: ${TMPDIR}" 
    FLINK_DIST="${TMPDIR}/flink.tgz"
    cp "${FROM_ARCHIVE}" "${FLINK_DIST}"
else

  usage

fi

docker build --build-arg flink_dist="${FLINK_DIST}" --build-arg job_artifacts="${JOB_ARTIFACTS_TARGET}" -t "${IMAGE_NAME}" .
