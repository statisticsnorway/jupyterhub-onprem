#!/usr/bin/env bash

# CLI tool based on the CLI tool in DAPLA

export CLI_NAME=$(basename $0)
export VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY="$HOME/virtual_environment_projects"

if [ "$1" == "create" ]; then
    if [ $# -ne 2 ]; then
        echo "This command creates a directory in your home directory, installs jupyterlab kernel and install a virutal environment for Python"
        echo "Exactly 2 arguments must be supplied to '$CLI_NAME', 'create' and the name of the project (must not contain spaces). The name of the project will also be the name of the kernel."
        exit 1
    fi
    
    echo "Creating project"

    export NEW_PROJECT_NAME=$2

    echo "Please verify the information below"
    
    echo "====================================="
    echo "Project name: $NEW_PROJECT_NAME"
    echo "====================================="

    while true; do
        read -p "Do you wish to continue based on the information above? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
  
    # Setting up root project directory if it does not already exist
    if [ ! -e "$VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY" ]; then 
        echo "Root directory for virutal env projects does not exist. I will create it for you"
        mkdir -p $VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY
    fi

    echo "Virtual environment projects folder is located at: $VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY"

    export VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY="$VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY/$NEW_PROJECT_NAME"

    if [ ! -e "$VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY" ]; then
        echo "Creating project '$VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY'"
        mkdir -p "$VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY"
    else
        echo "Project already exists at '$VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY'"
        while true; do
            read -p "Do you wish to continue regardless? " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit 1;;
                * ) echo "Please answer yes or no.";;
            esac
        done 
    fi
     
     # Setting up jupyterlab kernel and pipenv for the user project
     echo "Setting up Python virtual environment"
        
     cd "$VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY"

     echo "Creating pipenv virtual environment for the project"
     pipenv install
     echo "Installing ipykernel, which is needed to create new kernels"
     pipenv run pip install ipykernel
     echo "In the newly created pipenv associated with the project, create new kernel with name '$NEW_PROJECT_NAME'..."
     pipenv run python -m ipykernel install --user --name="$NEW_PROJECT_NAME"
        
     NEW_PYPATH="$(pipenv --venv)"
       
     NEW_KERNEL_PATH="$HOME/.local/share/jupyter/kernels/$NEW_PROJECT_NAME"
        
     if [ ! -e "$NEW_KERNEL_PATH" ]; then
         echo "Creating kernel at '$NEW_KERNEL_PATH'"
         mkdir -p "$NEW_KERNEL_PATH"
     fi
    
     TEMPLATE="/opt/conda/share/jupyter/kernels/python3"

     # Copying files from the standard python3 kernel we offer
     cp "$TEMPLATE/kernel.json" "$NEW_KERNEL_PATH/kernel.json"
     cp "$TEMPLATE/python.sh" "$NEW_KERNEL_PATH/python.sh"
        
     cp "$TEMPLATE/logo-32x32.png" "$NEW_KERNEL_PATH/logo-32x32.png"
     cp "$TEMPLATE/logo-64x64.png" "$NEW_KERNEL_PATH/logo-64x64.png"
    
     DATA=`cat $NEW_KERNEL_PATH/kernel.json` 
     # Change json values in kernel.json for the new kernel
     jq --arg new_name "$NEW_PROJECT_NAME" \
         --arg new_python_path "$NEW_KERNEL_PATH/python.sh" \
         '.display_name = $new_name | .argv[0] = $new_python_path' <<<"$DATA" > "$NEW_KERNEL_PATH/kernel.json"

     # cut out last line of python.sh to replace which python binary is used
     sed -i '$ d' "$NEW_KERNEL_PATH/python.sh"
     echo -e "export PYTHONPATH=$NEW_PYPATH\n" >> "$NEW_KERNEL_PATH/python.sh"
     echo "exec $NEW_PYPATH/bin/python -m ipykernel \$@" >> "$NEW_KERNEL_PATH/python.sh" 
     
     echo "---> Your project is located at: '$VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY' <---"

     exit 0

elif [ "$1" == "delete" ]; then
    if [ $# -ne 2 ]; then
        echo "This command deletes virtual environment and kernel but allows the project-directory to stay so you don't lose any code"
        echo "Exactly 2 arguments must be supplied to '$CLI_NAME', create and the name of the project (must not contain spaces). The name of the project will also be the name of the kernel."
        echo "To only delete the kernel, but not the pipenv, run 'jupyter kernelspec uninstall project_name'."

        echo "Here is a list of your projects"
        for directory in "$VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY"/*; do
            echo "- $(basename -- $directory)"
        done
        exit 1
    fi
    
    PROJECT_NAME=$2
    
    echo "WARNING: You are about to delete kernel and virutal environment named '$PROJECT_NAME', including Pipfile and Pipfile.lock in your project directory located at '$VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY'"
     
    while true; do
        read -p "Do you REALLY wish to DELETE the kernel and virtual environment named '$PROJECT_NAME', including Pipfile and Pipfile.lock in your project directory? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    
    VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY=$VIRTUAL_ENVIRONMENT_ROOT_DIRECTORY/$PROJECT_NAME
    
    cd "$VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY"
    
    PIPENV_PATH="$(pipenv --venv)"
    echo "Path to pipenv virtual environment associated with '$PROJECT_NAME': $PIPENV_PATH"
    
    # Kill open files in the project's virutalenv
    lsof +D $PIPENV_PATH | awk '{print $2}' | tail -n +2 | xargs -r kill -9
    rm -rf "$PIPENV_PATH"
    
    echo "Virtual environment deleted"
    echo "Removing pipfile and lockfile from $VIRTUAL_ENVIRONMENT_PROJECT_DIRECTORY"
    
    rm -f Pipfile
    rm -f Pipfile.lock
    
    jupyter kernelspec remove "$PROJECT_NAME"
    
    exit 0
else
  echo "'$CLI_NAME' takes argument 'create', 'delete'. Try them without further arguments for more info about what they do."
  exit 1
fi
