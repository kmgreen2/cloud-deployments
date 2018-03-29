while getopts o:e: opt; do
  case $opt in
    e)
      if [[ $OPTARG = -* ]]; then
        ((OPTIND--))
        continue
      fi
      ENV=$OPTARG
    ;;
    o)
      if [[ $OPTARG = -* ]]; then
        ((OPTIND--))
        continue
      fi
      OP=$OPTARG
    ;;
    \?)
      echo "Bad argument: $opt"
      exit 1
    ;;
  esac
done


if [[ -z $ENV ]]; then
    echo "Must specify an environment to build (e.g. prod)"
    exit 1
fi

if [[ -z $OP ]]; then
    echo "Must specify an operation (e.g. apply)"
    exit 1
fi

if [[ -z `echo "plan apply destroy" | grep ${OP}` ]]; then
    echo "Illegal operation: ${OP}"
    exit 1
fi

TERRAFORM_DIR=manifests/terraform/${ENV}

if [[ ! -e ${TERRAFORM_DIR} ]]; then
    echo "Cannot find ${TERRAFORM_DIR}"
    exit 1
fi

pushd .
cd ${TERRAFORM_DIR}

terraform ${OP}

popd
