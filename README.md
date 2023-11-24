Trivy provides built-in policies to detect configuration issues in popular Infrastructure as Code files, such as: Docker, Kubernetes, Terraform, CloudFormation, and more.

This config template can be included in your .gitlab-ci.yml to get the scanning job for free (similar to how the gitlab container scanning thing works).

## Setup Instructions
At the very top of your .gitlab-ci.yml either add or expand the `include:` section so it looks similar to this:  
```yaml
include:
  - remote: https://raw.githubusercontent.com/ambient-innovation/gitlab-trivy-config-checks/main/config-checks.yaml
  # There might be more includes here, usually starting with template like the following:
  # - template: 'Workflows/Branch-Pipelines.gitlab-ci.yml'
```

You will also need to have at least one stage called test in your top-level stages config for the default configuration:  
```yaml
stages:
  - prebuild
  - build
  - test
  - posttest
  - deploy
```  
**The `test` stage has to come after the docker image has already been built and pushed to the registry or the scanner will not work.**

Last but not least you need a job within that test stage going by the name `config_scanning`. A minimal config looks like this:  
```yaml
config_scanning:
  variables:
    CONFIG_PATH: "charts/workshop"
```

The example shown here will overwrite the `config_scanning` job from the template and tell it to

a) scan an image as specified in the `CONFIG_PATH` variable,\
b) perform a simple config scan\
c) only report errors with a level of MEDIUM,HIGH,CRITICAL or UNKNOWN.  

You can also specify the `FILENAME` of the result-output as you like. 

**Note:** If you wish to run the `config_scanning` job in another stage than "`test`" (as it does by default) simply copy the above code to your .gitlab-ci.yml file and add the keyword `stage` with your custom stage name.

Example for minimal stage-overwrite setup:

```yaml
config_scanning:
  stage: my-custom-stage
```

## Advanced Settings  
The container scanning job exposes a few more variables by which you can adjust the scanning if needed. The default settings are the recommendation of the TE-Circle, though.  

### Change minimum severity reported
By adding a new variable called `SEVERITY` to your job, you can change which severity items should be reported. The default is to report UNKNOWN, MEDIUM, HIGH and CRITICAL config issues. The remaining options are: `LOW`
Trivy requires a full list of severities to report. To report all severities from LOW and higher for example, you need to specify a comma-separated list like so: `SEVERITY: "LOW, MEDIUM,HIGH,CRITICAL,UNKNOWN"`

We recommend only scanning for config issues with a MEDIUM or higher level.

### Setting exit code for scanner

Since Trivy is not able to exclude findings for OS-level packages, we will have some matches in basically every case. 
A pipeline, that always warns, will in reality never warn. That's why the default here is set to "0", meaning that it 
will be "green" in GitLab. If you want to change this, just set the variable `EXIT_CODE_ON_FINDINGS`.

Here's an example:
```yaml
license_scanning:
  variables:
    EXIT_CODE_ON_FINDINGS: 1
```

### Other settings
By default trivy performs one run in full-silence mode writing the results to the gitlab codeclimate report file and then another one showing the results in a plaintext table. If the scan is taking very long, you can also show a progress bar during the scan by setting the `TRIVY_NO_PROGRESS` variable to `"false"`.  
To make sure you're doing a fresh run and instruct trivy to download a fresh vulnerability database, you can turn off/move the cache directory via the `TRIVY_CACHE_DIR` variable. The default value for this variable is a directory called `.trivycache`

You can add more variables corresponding to the CLI switches as documented on the trivy homepage: https://aquasecurity.github.io/trivy/latest/docs/references/customization/envs/
