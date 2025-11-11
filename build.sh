#!/bin/bash
packer build windows11.pkr.hcl
vagrant box add windows-custom ./windows-custom.box

