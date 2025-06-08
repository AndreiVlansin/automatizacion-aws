resource "aws_lb" "nlb" {
    name = "ELB"
    internal = false
    load_balancer_type = "network"

    #security_groups = [aws_security_group.http_internet-sg.id]
    subnet_mapping {
      subnet_id = aws_subnet.sub-pub0.id
      allocation_id = aws_eip.balanci.id
    }
}

resource "aws_lb_target_group" "web-tg" {
    name = "web-tg"
    port = 80
    protocol = "TCP"
    vpc_id = aws_vpc.pub-0.id


    health_check {
        protocol = "TCP"
        port = 80
        interval = 30
        healthy_threshold = 3
        unhealthy_threshold = 3
        timeout = 10
      
    }  
}

resource "aws_lb_listener" "web-listener" {
    load_balancer_arn = aws_lb.nlb.arn
    port = 80
    protocol = "TCP"
    

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.web-tg.arn
    }

}


resource "aws_launch_template" "web_lt" {
    name_prefix = "web-"
    image_id = "ami-08e8d6a644303cb60"
    instance_type = "t2.micro"
    

    network_interfaces {
      associate_public_ip_address = false
      security_groups = [aws_security_group.http_lb-sg.id, aws_security_group.ssh_sg_pub-0.id]
    }
}

resource "aws_autoscaling_group" "web_asg" {
    desired_capacity = 2
    min_size = 2
    max_size = 5
    vpc_zone_identifier = [aws_subnet.sub-pub0.id]

    launch_template {
      id = aws_launch_template.web_lt.id
      version = "$Latest"
    }

    target_group_arns = [aws_lb_target_group.web-tg.arn]

    health_check_type = "ELB"
    health_check_grace_period = 300
}

resource "aws_eip" "balanci" {
}

