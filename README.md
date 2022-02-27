# Oracle-EBusiness-Suite-Clone-Automation
Automate Oracle E-Business Suite Clone using shell scripts


To make it run for other environment, the environment settings need to be set in the `clone_environment.properties` file and passwords are need to be stored  as `{ENVIRONMENT_NAME}.pwd`. After storing the password as plain text, you need to run `encrypt_password.sh` to convert plain text passwords to encrypted format. 

Below are main scripts which does the whole EBS cloning process in three steps and can be run as single job by scheduling through OEM. 

1. `1050_source_apps_processing.sh` will take the backup of the production apps environment, it is run from source apps server. 
2. `2000_target_processing.sh` will refresh the target database and it is run from the target server. 
3. `3050_target_apps_processing.sh` will clone the apps and it is run from the target server. After completion of this step, you should be able to login to the webconsole. 

Any custom code need to be placed in the `custom_lib` suffix with Environment name. 

If the script fails with any error, it sends notification with the step number where it is failed. After fixing the issue manually, just execute the script again it will continue from failed step (not from first step). 


Note: Older version 12c Below DB and 12.1.x application is in the `version1` branch