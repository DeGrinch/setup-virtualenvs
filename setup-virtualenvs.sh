#!/bin/bash

# Prompt user for the root virtual directory path
read -p "Where would you like to create your root virtual directory? Enter an absolute path, by default the script will create /virtualenvs. Press enter to use the default: " root_path

# Set default path if user input is empty
if [ -z "$root_path" ]; then
    root_path="/virtualenvs"
fi

# Change to the specified or default root directory
cd "$root_path" || exit

# Create 'virtualenvs' directory if it doesn't exist
if [ ! -d "virtualenvs" ]; then
    mkdir virtualenvs
    echo "Created 'virtualenvs' directory at '$root_path'."
fi

# Change directory to 'virtualenvs'
cd virtualenvs || exit

# Create create_venv.sh script for creating virtual environments
cat << 'EOF' > create_venv.sh
#!/bin/bash

# Prompt user for the virtual environment directory path
read -p "Where would you like to create this new virtual environment? By default, the script will create your new virtual environment inside /virtualenvs. Press enter to use the default: " venv_path

# Set default path if user input is empty
if [ -z "$venv_path" ]; then
    venv_path="/virtualenvs"
fi

# Change to the specified or default virtual environment directory
cd "$venv_path" || exit

# Prompt user for the virtual environment directory name
read -p "Enter the virtual environment directory name: " venv_name

# Check if python3-venv is installed
if ! command -v python3 -m venv &> /dev/null; then
    echo "python3-venv package is not installed."
    read -p "Do you want to install python3-venv package? (Y/N): " install_choice

    if [[ "$install_choice" == "Y" || "$install_choice" == "y" ]]; then
        sudo apt-get update && sudo apt-get install python3-venv
    else
        echo "Installation aborted. Exiting..."
        exit 1
    fi
fi

# Check again if python3-venv got installed or was already present
if command -v python3 -m venv &> /dev/null; then
    # Create the virtual environment
    python3 -m venv "$venv_name"

    # Check if the virtual environment creation was successful
    if [ $? -eq 0 ]; then
        echo "Virtual environment '$venv_name' created successfully."

        # Activate the virtual environment
        source "$venv_name/bin/activate"

        # Provide instructions for deactivation
        echo "Virtual environment activated. Use 'deactivate' to exit the virtual environment."
    else
        echo "Error: Failed to create virtual environment."
    fi
else
    echo "Error: python3-venv is still not installed. Please install it manually."
fi
EOF

# Make create_venv.sh executable
chmod +x create_venv.sh

# Create delete_venv.sh script for deleting virtual environments
cat << 'EOF' > delete_venv.sh
#!/bin/bash

# Prompt user for the virtual environment directory path
read -p "Where is the virtual environment directory located? Enter the absolute path: " delete_venv_path

# Change to the specified virtual environment directory
cd "$delete_venv_path" || exit

# Prompt user for the virtual environment directory name to delete
read -p "Enter the virtual environment directory name to delete: " venv_name

# Check if the virtual environment exists
if [ -d "$venv_name" ]; then
    # Deactivate the virtual environment if currently activated
    deactivate &> /dev/null

    # Delete the virtual environment
    rm -rf "$venv_name"
    echo "Virtual environment '$venv_name' deleted successfully."
else
    echo "Error: Virtual environment '$venv_name' not found."
fi
EOF

# Make delete_venv.sh executable
chmod +x delete_venv.sh

# Create list-venvs.sh script for listing virtual environments
cat << 'EOF' > list-venvs.sh
#!/bin/bash

# Prompt user for the root virtual directory path
read -p "Where are your virtual environments located? Enter an absolute path, by default the script will look into /virtualenvs. Press enter to use the default: " root_path

# Set default path if user input is empty
if [ -z "$root_path" ]; then
    root_path="/virtualenvs"
fi

# Change to the specified or default root directory
cd "$root_path" || exit

# Check if 'virtualenvs' directory exists
if [ ! -d "virtualenvs" ]; then
    echo "No 'virtualenvs' directory found at '$root_path'."
    exit 1
fi

# Change directory to 'virtualenvs'
cd virtualenvs || exit

# List all environments in a numerical format
echo "Listing all virtual environments:"
count=1
for d in */; do
    echo "$count. ${d%/}"
    ((count++))
done

if [ "$count" -eq 1 ]; then
    echo "No virtual environments found in '$root_path/virtualenvs'."
fi
EOF

# Make list-venvs.sh executable
chmod +x list-venvs.sh

echo "Scripts created successfully in the '$root_path/virtualenvs' directory."
