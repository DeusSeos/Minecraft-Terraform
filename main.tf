provider "aws" {
  profile = "CA" # Replace with your desired profile
  region = "us-east-1"  # Replace with your desired region
}

# add user data from out init.sh to the instance
resource "aws_instance" "mc_instance" {
  ami           = "ami-0440d3b780d96b29d"  # Replace with your desired AMI ID
  instance_type = "m5.large"
  user_data = file("init.sh")
  key_name = "MCserver"

}

resource "aws_eip" "mc_eip" {
  instance = aws_instance.mc_instance.id
}


# create a cloudwatch metric for cpu utilization and set an alarm if less than 7 for 3 periods with a 15 minute period and stop the instance
resource "aws_cloudwatch_metric_alarm" "mc_alarm" {
  alarm_name          = "mc_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "900"
  statistic           = "Average"
  threshold           = "7"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:stop"]
  dimensions = {
    InstanceId = aws_instance.mc_instance.id
  }
}
