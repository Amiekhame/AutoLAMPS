# AutoLAMPS

AutoLAMPS is an automated deployment project for setting up a LAMP (Linux, Apache, MySQL, PHP) stack on two Ubuntu-based servers using Vagrant, Bash scripting, and Ansible. The project streamlines the process of deploying web applications, with a particular focus on PHP Laravel applications.

## Project Overview

AutoLAMPS is designed to simplify the deployment of a LAMP stack and the associated web application on two Ubuntu-based virtual machines. It uses Vagrant to provision the servers, a Bash script for the LAMP stack setup, and an Ansible playbook to automate the deployment process.

## Getting Started

To use AutoLAMPS, follow these steps:

1. Clone this GitHub repository to your local machine.
2. Provision the virtual machines using Vagrant by running the provided Vagrantfile.
3. Execute the Bash script on the "Master" server to set up the LAMP stack and deploy the PHP Laravel application.
4. Use the Ansible playbook to execute the Bash script on the "Slave" server.
5. Verify the project's success by testing and checking the server's uptime.

## Documentation

For detailed instructions and documentation, please refer to the project's [Documentation](./documentation) section.

## Author

- [Amiekhame Emmanuel](https://github.com/Amiekhame) 
