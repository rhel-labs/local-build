# REQUIREMENTS

This process uses the QEMU builder for packer.  Make sure libvirt is installed and your user can create virtual machines without escalated privileges.  You may need to update the "qemu_binary" path in the JSON file if you have problems starting a build.

Download packer 1.4.2 from packer.io and put somewhere you can execute it.  E.G. `/home/<userid>/bin/` with that as part of your PATH, or just use the full path when calling it.  

>**NOTE** If you are building on RHEL, there is a 'packer' command shipped by default in RHEL from the cracklib-dicts package.

Download the binary ISO and put it somewhere you can access it.  You will need the path and the checksum of the ISO for the JSON file.

Clone this repo, all commands in this README will be run relative to the top level of this directory.

# Set up the ISO config

Get the MD5 checksum for the ISO you've downloaded.

`md5sum isos/rhel-8.0-x86_64-dvd.iso`

Add the checksum and the path to the ISO in the following variables in the "builders" section of the JSON file.

```
 "iso_url": "/path/to/iso/rhel-8.0-x86_64-dvd.iso",
 "iso_checksum": "8a0bUseTheRightmd5sum3f39",
 "iso_checksum_type": "md5",
```

# Katacoda environments
Katacoda uses [the shell provisioner](https://www.packer.io/docs/provisioners/shell.html) for packer to build images.

There are multiple scripts, each of which contains a small set of actions.  Our best practice is to group small related sets of actions together in a single BASH script.  Ordering of scripts is managed by the naming convention of `#_descripion.sh`.

To test additional build scripts, add the new script to the build/ directory of the appropriate environment and the "scripts" block under "provisioners" in the JSON file.

There are several images that can be built for katacoda labs.  These can have different sets of build scripts, and are found in the `environments` directory. The default for most use cases is `rhel8`.  If you need to work with SQL Server, use the `rhel8-highmem` environment.  Images to build can be selected at build time using a variable.

>__WARNING__ Multi-node builds currently do not work.  As this environment is simply two identical VMs, you can create a local multi-node config by creating a second VM in the [launch section](#launching-an-image).

## Set up subscriptions

In the `build/1_enablerepo.sh` script for your environment, set the pool for the subscription you plan to use.  The Katacoda environments will use 'Red Hat Enterprise Linux Server Entry Level with Smart Management, Self-support' subscriptions.  Review the list of enabled repositories in this script.  If you plan to use channels or packages from another subscription, please email rhel-labs@redhat.com.

There are several ways to get the pool ID of the subscription that should be used.  If you know the pool ID from the Portal, set the `pool_match` variable to the appropriate poolID.

`pool_match=RH00010`

If you only know the name of the subscription, you can use the alternate command. These use pattern matching and some output cutting to get the right pool.  Set the `pool_match` variable to a string that includes the name of the SKU.

`pool_match='*Red Hat Enterprise Linux Server*'`

You may want to check the output and order of reporting if more than one pool may be reported, e.g. where physical and virtual entitlements are available in the account.

## Build an image
>**NOTE** If you've previously built an image, be sure the output-qemu/ does not exist.

The default image is the `rhel8` environment.  This is used for most of the labs.  Subscription credentials are passed via environment variables and masked from the log output, as follows:

RHN_USER=<userid> RHN_PASS=<userpass>  ~/bin/packer build rhel-8.0-x86_64-libvirt.json

Set the variables with the user/pass combo for the portal account that has subscriptions you want to use.

`RHN_USER=shadowman RHN_PASS=supersecret ~/bin/packer build rhel-8.0-x86_64-libvirt.json`

To build a different image from the environments directory, add `-var` and the directory name to the build command to override the default, e.g:

-var 'target=<directory_name>'

`RHN_USER=shadowman RHN_PASS=supersecret ~/bin/packer build -var 'target=rhel8-highmem' rhel-8.0-x86_64-libvirt.json`

## Launching an image

You can launch the image created in the output-qemu/ directory.  You can either use virtual machine manager or virt-install --import

`virt-install -n packer-test --import --disk output-qemu/rhel-8.0-katacoda-base --memory 2048 --vcpus 2 --noautoconsole`

>**NOTE** Once you've create the VM using that image, each subsequent build will use the same disk image name.  This means removing the ouput-qemu/ directory and doing another successful build will drop the same image in the same place, and you can just restart the existing VM without recreating.

This image can now be used to develop and test the steps for your scenario.  Any additional packages needed by your lab can be added at build time in the appropriate build script.  For more information about writing good labs, refer to the style guide.
