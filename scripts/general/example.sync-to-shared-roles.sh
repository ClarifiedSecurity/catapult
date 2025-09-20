#!/usr/bin/env bash

# Script to sync the changes made in the custom collection to the correct git repo in your machine.
# This is for useful for development purposes, because you can make changes and test them in your

SOURCE_PATH=/path/to/source/roles/folder/
DEST_PATH=/path/to/destination/roles/folder/

rsync -avr \
--exclude "roles/FILES.json" \
--exclude "roles/MANIFEST.json" \
$SOURCE_PATH $DEST_PATH \
--delete
