#!/bin/bash

set -e


TEMPLATES_DIR="/root/templates"


if [ ! -f .gitignore ]; then
    cp "${TEMPLATES_DIR}/.gitignore" .
    echo "Created .gitignore"
fi

if [ ! -f main.nucleus.yml ]; then
    cp "${TEMPLATES_DIR}/template.main.nucleus.yml" main.nucleus.yml
    echo "Created default main.nucleus.yml"
fi

if [ ! -f vars.nucleus.yml ]; then
    cp "${TEMPLATES_DIR}/template.vars.nucleus.yml" vars.nucleus.yml
    echo "Created default vars.nucleus.yml"
fi
