# GCP Terraform Deployment

This Terraform configuration deploys the cheapest practical Google Cloud setup for Memos:

- one `e2-micro` Compute Engine VM
- one reserved static external IP
- firewall rules for SSH, HTTP, and HTTPS
- startup provisioning that installs and runs Memos with `sqlite`
- Nginx reverse proxy listening on port `80`

## What it does

The VM startup script will:

1. install `git`, `golang-go`, `build-essential`, and `nginx`
2. clone the Memos repository
3. check out the configured Git ref
4. build `./cmd/memos`
5. run Memos as a `systemd` service using:
   - `--driver sqlite`
   - `--data /var/opt/memos`
   - `--port 8081`
6. configure Nginx to proxy `:80` to `127.0.0.1:8081`

## Cost notes

Defaults are chosen to align with the Google Cloud free-tier-friendly path:

- region: `us-central1`
- zone: `us-central1-a`
- machine type: `e2-micro`
- disk type: `pd-standard`

You should still verify current Google Cloud pricing and free-tier eligibility for your account and region before applying.

## Usage

Create a `terraform.tfvars` file from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then edit the values:

```hcl
project_id  = "your-gcp-project-id"
repo_ref    = "main"
domain_name = ""
```

If you already have a domain pointed at the VM, set `domain_name = "notes.example.com"`.
Otherwise Terraform will configure Memos with `http://<public-ip>` as the instance URL.

Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `public_ip`: reserved VM public IP
- `instance_url`: URL passed to Memos
- `ssh_command`: helper command to SSH into the VM

## Post-deploy

Check the service status:

```bash
gcloud compute ssh memos --project YOUR_PROJECT_ID --zone us-central1-a
sudo systemctl status memos
sudo systemctl status nginx
journalctl -u memos -n 100 --no-pager
```

## Notes

- This setup does not provision TLS certificates. The simplest next step is to put Cloudflare in front of the VM, or install Certbot manually after DNS is set up.
- The startup script builds from source on the VM. For more repeatable production deployments, pin `repo_ref` to a tag or commit SHA.
- `allow_ssh_cidrs` defaults to `0.0.0.0/0` for convenience. Restrict it before using this on the public internet.
