include_recipe "deploy"
 
#########################
# convenience constants #
#########################
 
ENVIRONMENT = "prod"
APP_NAME = "pythonexampleapp"
 
# patch over DEPLOY
node.set["deploy"][APP_NAME]["deploy_to"] = node["pythonexampleapp"]["deploy_dir"]
node.set["deploy"][APP_NAME]["user"] = node["pythonexampleapp"]["user"]
node.set["deploy"][APP_NAME]["group"] = node["pythonexampleapp"]["group"]
node.set["deploy"][APP_NAME]["home"] = "/home/#{node["pythonexampleapp"]["user"]}"
DEPLOY = node["deploy"][APP_NAME]
 
#############################
# end convenience constants #
#############################
 
APPLICATION = "api"
USER = deploy["user"]
GROUP = deploy["group"]
 
    directory DEPLOY["home"] do
        owner USER
        group GROUP
        recursive true
        action :create
    end
 
    # make sure the deploy user is there
    opsworks_deploy_user do
        deploy_data DEPLOY
    end
 
    opsworks_deploy_dir do
        path DEPLOY["deploy_to"]
        user DEPLOY["user"]
        group DEPLOY["group"]
    end
 
    opsworks_deploy do
        deploy_data DEPLOY
        app APP_NAME
    end
 
    # update virtualenv, reinstall requirments
    python_virtualenv node["pythonexampleapp"]["env_dir"] do
        owner USER
        group GROUP
        action :create
    end
 
    python_pip "#{node["pythonexampleapp"]["deploy_dir"]}/current/requirements.txt" do
        virtualenv node["pythonexampleapp"]["env_dir"]
        user USER
        group GROUP
        options "-r"
        action :install
    end
