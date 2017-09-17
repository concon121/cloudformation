# README

## Set Up

### Pre-Requisites

-   Unix / Cygwin
-   Ruby
-   Ruby Gem: Bundler

### Install Dependencies

Run bundler to install the required Ruby Gems.

```
bundle install
```

### Rake Tasks

#### Install

Runs various linters to verify the validity of the source code and generates the cloudformation template with lono.

```
rake install
```

### Deploying

Assuming your template file and parameter files have the same name, the script requires just 1 parameter, the name of the files but without the extension.

```
./form_cloud.sh development-sad-pipeline
```
