#!/bin/bash

if [ -O ${TMPDIR} && -d ${TMPDIR} ]; then
    rm -rf ${TMPDIR}/*
fi
