#!/bin/bash

# Exit if any command fails
set -e

# Check for required argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <title-with-dashes>"
  echo "Example: $0 meditations-for-mortals"
  exit 1
fi

# Variables
TITLE="$1"
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")
OFFSET="-0700" # Adjust as needed
YEAR=$(date +"%Y")
MONTH=$(date +"%m")

# Filename format: YYYY-MM-DD-title.md
FILENAME="${DATE}-${TITLE}.md"

# Create file and write content
cat <<EOF > "_drafts/$FILENAME"
---
title: "TITLE"
date: ${DATE} ${TIME} ${OFFSET}
categories: [X, Y]
tags: [x, y]
description: "Sub Heading"
image: 
  path: /assets/${YEAR}/${MONTH}/
  width: 700
  height: 500
---

## Introduction
EOF

# Confirm creation
echo "File created: $FILENAME"