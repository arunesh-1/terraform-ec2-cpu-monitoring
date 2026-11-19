# EC2 CPU monitoring with CloudWatch

Terraform creates an isolated Amazon Linux 2023 EC2 instance and a CloudWatch
alarm. The alarm enters `ALARM` when average CPU utilization exceeds 70% for
two consecutive one-minute periods. Detailed monitoring provides one-minute
metrics. Missing data is treated as missing, not as a spike.

The instance automatically generates CPU load on all CPUs for 15 minutes on
its first boot, then stops the load. This makes the alarm observable without
logging in or installing software. The security group has **no inbound or
outbound rules**, and the instance has no public IP, so SSH (22) and RDP
(3389) are not enabled. The alarm changes state only; it does not send email
or other notifications.

## Requirements and costs

- Terraform 1.5 or later, the AWS CLI, and configured AWS credentials.
- AWS permissions to manage VPC, subnet, security group, EC2 and CloudWatch
  alarms, and to read the public Amazon Linux SSM parameter.
- EC2, EBS, detailed monitoring and CloudWatch alarms may incur charges.
  Review AWS pricing before creating resources.

## Deploy and observe the alarm

In PowerShell, open this folder and run:

```powershell
terraform init
terraform plan
terraform apply
terraform output
```

Review the plan and enter `yes`. The default region is `us-east-1`. The load
begins during the instance's first boot and stops after 15 minutes; the alarm
can take several minutes to enter `ALARM` as metrics are collected. To view it:

1. Sign in to the AWS console and select the region from the Terraform output.
2. Open **CloudWatch**, then **Alarms** and **All alarms**.
3. Find the alarm name from the Terraform output and open it. Wait until its
   state is `In alarm` and the graph shows the CPU spike.
4. Take a screenshot showing the alarm name, state, and graph.

The alarm returns to `OK` after the load stops and the measured CPU drops.
If you miss the alarm window, recreate the instance to run the load again:

```powershell
terraform apply -replace="aws_instance.monitor"
```

This destroys and recreates the instance; the alarm is updated for the new
instance. Follow the prompts and wait for the new metrics.

## Clean up

Run `terraform destroy` in the same folder and confirm with `yes` to remove the
instance, alarm, and networking. Keep the Terraform state private and do not
delete it before cleanup.
