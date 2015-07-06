## Nubis wrapper scripts

### Script information

I got tired of typing out the cloudformation commands so i wrote scripts to help me.

You will need to configure the BASE_DIR variable by editing the variables.sh file

| Scripts         | Description |
|-----------------|-------------|
|build.sh         | Builds the cloudformation stack and requires a stackname as a command line parameter |
|update.sh        | Updates the cloudformation stack, also requires a stackname. |
|delete.sh        | Deletes the stack, this also deletes any data that is in consul |
|packer-build.sh  | Builds ami using nubis-builder|

### Usage
All scripts need to be ran from the base directory of your project instead of the bin directory

*Examples:*

* Building ami (This also assumes you have nubis-builder in your path)
  ```bash
  $ cd $PROJECTDIR
  $ ./bin/packer-build
  ```

* Building cloudformation stack
  ```bash
  $ cd $PROJECTDIR
  $ ./bin/build.sh <stack name>
  ```

### Git submodule
The intent of this repository is to make this a submodule for nubis projects that wants to utilize these scripts

Assuming you already have a nubis project directory setup you can run the following commands in your project directory
```bash
cd $PROJECTDIR
git submodule add git://github.com/limed/nubis-wrapper ./bin
git commit -am "Added nubis-wrapper submodule"
git push origin master
```


