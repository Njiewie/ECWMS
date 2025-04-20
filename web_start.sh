#!/bin/bash
cd /ECWMS/templates
yarn install --force
quasar build
quasar d
