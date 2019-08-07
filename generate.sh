#!/bin/bash

generate_header () {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "generate.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

generate () {
	TEMPLATE_DIR="$1/templates"
	PROJECT_TEMPLATE_DIR="$TEMPLATE_DIR/projects"
	OUTPUT_DIR="$1/dist"

	for p in $(find $PROJECT_TEMPLATE_DIR/* -type d)
	do
		project=${p##*/}

		path="$OUTPUT_DIR/$project"
		file="$path/Dockerfile"

		mkdir -p $path

		cp -R $TEMPLATE_DIR/files/* $path

		generate_header > $file
		sed -e "/# Additions/ r $PROJECT_TEMPLATE_DIR/$project/Dockerfile.template" "$TEMPLATE_DIR/Dockerfile.template" >> $file
		sed -i -e "s/%PHP_VERSION%/$v/" $file
	done
}

generate "php-5"
generate "php-7"
