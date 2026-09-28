# ==============================================================================
# Terraform Provisioners Practice
# `local-exec`, `remote-exec`, `file`, and `connection` blocks
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. `local-exec` Provisioner (Creation-time & Destroy-time)
# ------------------------------------------------------------------------------
# Executes commands locally on the machine running `terraform apply`.
resource "local_file" "sample_app" {
  content  = "Sample application configuration - Env: ${var.environment}"
  filename = "${path.module}/generated_outputs/app.txt"

  # Creation-Time local-exec provisioner
  provisioner "local-exec" {
    command     = "echo '[SUCCESS] File created at ${self.filename} on $(date)' >> ${path.module}/generated_outputs/local_exec_log.txt"
    interpreter = ["/bin/bash", "-c"]
  }

  # Destroy-Time local-exec provisioner (runs when resource is being destroyed)
  provisioner "local-exec" {
    when    = destroy
    command = "echo '[DESTROY] Resource ${self.filename} is being deleted' >> ${path.module}/generated_outputs/destroy_log.txt"
  }
}

# ------------------------------------------------------------------------------
# 2. `null_resource` with `local-exec` Provisioner
# ------------------------------------------------------------------------------
# A null_resource does not create infrastructure; it is used to run provisioners or trigger scripts.
resource "null_resource" "inventory_builder" {
  # Triggers re-execution whenever the app file content changes
  triggers = {
    file_id = local_file.sample_app.id
  }

  provisioner "local-exec" {
    command = "echo 'Building Ansible inventory for environment: ${var.environment}' > ${path.module}/generated_outputs/ansible_inventory.ini"
  }
}

# ------------------------------------------------------------------------------
# 3. AWS EC2 Instance with `file` & `remote-exec` Provisioners + `connection`
# ------------------------------------------------------------------------------
# Demonstrates remote provisioners over SSH connection.
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  key_name      = var.key_name

  tags = {
    Name        = "${var.environment}-provisioner-demo"
    Environment = var.environment
  }

  # Connection block defines SSH parameters used by file and remote-exec
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/id_rsa")
    host        = self.public_ip
    timeout     = "2m"
  }

  # 1. `file` Provisioner: Copies local file to remote EC2 instance
  provisioner "file" {
    source      = "${path.module}/generated_outputs/app.txt"
    destination = "/tmp/app.txt"

    # Ignore failure if connection fails in local practice
    on_failure = continue
  }

  # 2. `remote-exec` Provisioner: Runs bash commands on remote EC2 instance
  provisioner "remote-exec" {
    inline = [
      "echo 'Updating packages...'",
      "echo 'Application config contents:'",
      "cat /tmp/app.txt || true"
    ]

    on_failure = continue
  }

  # 3. `local-exec` Provisioner: Output public IP after EC2 creation
  provisioner "local-exec" {
    command = "echo 'EC2 Instance deployed with IP: ${self.public_ip}' >> ${path.module}/generated_outputs/server_ips.txt"

    on_failure = continue
  }
}
