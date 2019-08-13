### Simple example of how to create one Consul server in single DC using Terraform and AWS.

### How to use it :

- In a directory of your choice, clone the github repository :
    ```
    git clone https://github.com/martinhristov90/consul_terraform_aws.git
    ```

- Change into the directory :
    ```
    cd consul_terraform_aws
    ```
- Create a AWS AMI by running `packer build packer/template.json`.

- Run `terraform plan` and `terraform apply`

### Nota Bene:

- The `packer` directory contains a Packer template to build a AWS AMI with Consul installed as Systemd service.
- Private key to connect to the EC2 instance is going to be placed inside private_keys directory.
- For more detailed information review the comments inside the code.