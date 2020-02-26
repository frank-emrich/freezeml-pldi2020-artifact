#!/usr/bin/env bash


#Switch to links subdirectory
pushd links

#Make sure links is compiled
make

#Create examples.tests in links directory by removing all # from examples.links
sed s/#//g ../examples.txt > examples.tests

#Create version of freezeml.config in links directory with new relative path for environment.links
#In particular, we replace environment.links with ../environment.links
sed s_environment.links_../environment.links_g ../freezeml.config > rel_freezeml.config


#Run the links test suite on examples.tests, using config file rel_freezeml.config
./test-harness examples.tests rel_freezeml.config

#Go back
popd
