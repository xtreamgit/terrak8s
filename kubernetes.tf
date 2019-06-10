output "cluster_name" {
  value = "staging.devdatalab.com"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-staging-devdatalab-com.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-staging-devdatalab-com.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-staging-devdatalab-com.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-staging-devdatalab-com.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.us-west-1a-staging-devdatalab-com.id}", "${aws_subnet.us-west-1b-staging-devdatalab-com.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-staging-devdatalab-com.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-staging-devdatalab-com.name}"
}

output "region" {
  value = "us-west-1"
}

output "vpc_id" {
  value = "vpc-030564af13abbb958"
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_autoscaling_attachment" "master-us-west-1a-masters-staging-devdatalab-com" {
  elb                    = "${aws_elb.api-staging-devdatalab-com.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-west-1a-masters-staging-devdatalab-com.id}"
}

resource "aws_autoscaling_group" "master-us-west-1a-masters-staging-devdatalab-com" {
  name                 = "master-us-west-1a.masters.staging.devdatalab.com"
  launch_configuration = "${aws_launch_configuration.master-us-west-1a-masters-staging-devdatalab-com.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.us-west-1a-staging-devdatalab-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "staging.devdatalab.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-1a.masters.staging.devdatalab.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-1a"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-staging-devdatalab-com" {
  name                 = "nodes.staging.devdatalab.com"
  launch_configuration = "${aws_launch_configuration.nodes-staging-devdatalab-com.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.us-west-1a-staging-devdatalab-com.id}", "${aws_subnet.us-west-1b-staging-devdatalab-com.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "staging.devdatalab.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.staging.devdatalab.com"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "a-etcd-events-staging-devdatalab-com" {
  availability_zone = "us-west-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "staging.devdatalab.com"
    Name                 = "a.etcd-events.staging.devdatalab.com"
    "k8s.io/etcd/events" = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "a-etcd-main-staging-devdatalab-com" {
  availability_zone = "us-west-1a"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "staging.devdatalab.com"
    Name                 = "a.etcd-main.staging.devdatalab.com"
    "k8s.io/etcd/main"   = "a/a"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_eip" "us-west-1a-staging-devdatalab-com" {
  vpc = true
}

resource "aws_eip" "us-west-1b-staging-devdatalab-com" {
  vpc = true
}

resource "aws_elb" "api-staging-devdatalab-com" {
  name = "api-staging-devdatalab-co-m1119b"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-staging-devdatalab-com.id}"]
  subnets         = ["${aws_subnet.utility-us-west-1a-staging-devdatalab-com.id}", "${aws_subnet.utility-us-west-1b-staging-devdatalab-com.id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "staging.devdatalab.com"
    Name              = "api.staging.devdatalab.com"
  }
}

resource "aws_iam_instance_profile" "masters-staging-devdatalab-com" {
  name = "masters.staging.devdatalab.com"
  role = "${aws_iam_role.masters-staging-devdatalab-com.name}"
}

resource "aws_iam_instance_profile" "nodes-staging-devdatalab-com" {
  name = "nodes.staging.devdatalab.com"
  role = "${aws_iam_role.nodes-staging-devdatalab-com.name}"
}

resource "aws_iam_role" "masters-staging-devdatalab-com" {
  name               = "masters.staging.devdatalab.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.staging.devdatalab.com_policy")}"
}

resource "aws_iam_role" "nodes-staging-devdatalab-com" {
  name               = "nodes.staging.devdatalab.com"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.staging.devdatalab.com_policy")}"
}

resource "aws_iam_role_policy" "masters-staging-devdatalab-com" {
  name   = "masters.staging.devdatalab.com"
  role   = "${aws_iam_role.masters-staging-devdatalab-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.staging.devdatalab.com_policy")}"
}

resource "aws_iam_role_policy" "nodes-staging-devdatalab-com" {
  name   = "nodes.staging.devdatalab.com"
  role   = "${aws_iam_role.nodes-staging-devdatalab-com.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.staging.devdatalab.com_policy")}"
}

resource "aws_key_pair" "kubernetes-staging-devdatalab-com-3c9b12e53198bd8bb4731cce9db869e5" {
  key_name   = "kubernetes.staging.devdatalab.com-3c:9b:12:e5:31:98:bd:8b:b4:73:1c:ce:9d:b8:69:e5"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.staging.devdatalab.com-3c9b12e53198bd8bb4731cce9db869e5_public_key")}"
}

resource "aws_launch_configuration" "master-us-west-1a-masters-staging-devdatalab-com" {
  name_prefix                 = "master-us-west-1a.masters.staging.devdatalab.com-"
  image_id                    = "ami-011bb5e58aacca28a"
  instance_type               = "m3.medium"
  key_name                    = "${aws_key_pair.kubernetes-staging-devdatalab-com-3c9b12e53198bd8bb4731cce9db869e5.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-staging-devdatalab-com.id}"
  security_groups             = ["${aws_security_group.masters-staging-devdatalab-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-1a.masters.staging.devdatalab.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  ephemeral_block_device = {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-staging-devdatalab-com" {
  name_prefix                 = "nodes.staging.devdatalab.com-"
  image_id                    = "ami-011bb5e58aacca28a"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-staging-devdatalab-com-3c9b12e53198bd8bb4731cce9db869e5.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-staging-devdatalab-com.id}"
  security_groups             = ["${aws_security_group.nodes-staging-devdatalab-com.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.staging.devdatalab.com_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "us-west-1a-staging-devdatalab-com" {
  allocation_id = "${aws_eip.us-west-1a-staging-devdatalab-com.id}"
  subnet_id     = "${aws_subnet.utility-us-west-1a-staging-devdatalab-com.id}"
}

resource "aws_nat_gateway" "us-west-1b-staging-devdatalab-com" {
  allocation_id = "${aws_eip.us-west-1b-staging-devdatalab-com.id}"
  subnet_id     = "${aws_subnet.utility-us-west-1b-staging-devdatalab-com.id}"
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.staging-devdatalab-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "igw-01a7ec4eec93c035b"
}

resource "aws_route" "private-us-west-1a-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-us-west-1a-staging-devdatalab-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.us-west-1a-staging-devdatalab-com.id}"
}

resource "aws_route" "private-us-west-1b-0-0-0-0--0" {
  route_table_id         = "${aws_route_table.private-us-west-1b-staging-devdatalab-com.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.us-west-1b-staging-devdatalab-com.id}"
}

resource "aws_route53_record" "api-staging-devdatalab-com" {
  name = "api.staging.devdatalab.com"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-staging-devdatalab-com.dns_name}"
    zone_id                = "${aws_elb.api-staging-devdatalab-com.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z1ACVY9NP8CEOM"
}

resource "aws_route_table" "private-us-west-1a-staging-devdatalab-com" {
  vpc_id = "vpc-030564af13abbb958"

  tags = {
    KubernetesCluster = "staging.devdatalab.com"
    Name              = "private-us-west-1a.staging.devdatalab.com"
  }
}

resource "aws_route_table" "private-us-west-1b-staging-devdatalab-com" {
  vpc_id = "vpc-030564af13abbb958"

  tags = {
    KubernetesCluster = "staging.devdatalab.com"
    Name              = "private-us-west-1b.staging.devdatalab.com"
  }
}

resource "aws_route_table" "staging-devdatalab-com" {
  vpc_id = "vpc-030564af13abbb958"

  tags = {
    KubernetesCluster = "staging.devdatalab.com"
    Name              = "staging.devdatalab.com"
  }
}

resource "aws_route_table_association" "private-us-west-1a-staging-devdatalab-com" {
  subnet_id      = "${aws_subnet.us-west-1a-staging-devdatalab-com.id}"
  route_table_id = "${aws_route_table.private-us-west-1a-staging-devdatalab-com.id}"
}

resource "aws_route_table_association" "private-us-west-1b-staging-devdatalab-com" {
  subnet_id      = "${aws_subnet.us-west-1b-staging-devdatalab-com.id}"
  route_table_id = "${aws_route_table.private-us-west-1b-staging-devdatalab-com.id}"
}

resource "aws_route_table_association" "utility-us-west-1a-staging-devdatalab-com" {
  subnet_id      = "${aws_subnet.utility-us-west-1a-staging-devdatalab-com.id}"
  route_table_id = "${aws_route_table.staging-devdatalab-com.id}"
}

resource "aws_route_table_association" "utility-us-west-1b-staging-devdatalab-com" {
  subnet_id      = "${aws_subnet.utility-us-west-1b-staging-devdatalab-com.id}"
  route_table_id = "${aws_route_table.staging-devdatalab-com.id}"
}

resource "aws_security_group" "api-elb-staging-devdatalab-com" {
  name        = "api-elb.staging.devdatalab.com"
  vpc_id      = "vpc-030564af13abbb958"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "staging.devdatalab.com"
    Name              = "api-elb.staging.devdatalab.com"
  }
}

resource "aws_security_group" "masters-staging-devdatalab-com" {
  name        = "masters.staging.devdatalab.com"
  vpc_id      = "vpc-030564af13abbb958"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "staging.devdatalab.com"
    Name              = "masters.staging.devdatalab.com"
  }
}

resource "aws_security_group" "nodes-staging-devdatalab-com" {
  name        = "nodes.staging.devdatalab.com"
  vpc_id      = "vpc-030564af13abbb958"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "staging.devdatalab.com"
    Name              = "nodes.staging.devdatalab.com"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.masters-staging-devdatalab-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.masters-staging-devdatalab-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-staging-devdatalab-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-staging-devdatalab-com.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.api-elb-staging-devdatalab-com.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-staging-devdatalab-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-protocol-ipip" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4001" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port                = 2382
  to_port                  = 4001
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-staging-devdatalab-com.id}"
  source_security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-staging-devdatalab-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-staging-devdatalab-com.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "us-west-1a-staging-devdatalab-com" {
  vpc_id            = "vpc-030564af13abbb958"
  cidr_block        = "172.21.32.0/19"
  availability_zone = "us-west-1a"

  tags = {
    KubernetesCluster                              = "staging.devdatalab.com"
    Name                                           = "us-west-1a.staging.devdatalab.com"
    "kubernetes.io/cluster/staging.devdatalab.com" = "owned"
    "kubernetes.io/role/internal-elb"              = "1"
  }
}

resource "aws_subnet" "us-west-1b-staging-devdatalab-com" {
  vpc_id            = "vpc-030564af13abbb958"
  cidr_block        = "172.21.64.0/19"
  availability_zone = "us-west-1b"

  tags = {
    KubernetesCluster                              = "staging.devdatalab.com"
    Name                                           = "us-west-1b.staging.devdatalab.com"
    "kubernetes.io/cluster/staging.devdatalab.com" = "owned"
    "kubernetes.io/role/internal-elb"              = "1"
  }
}

resource "aws_subnet" "utility-us-west-1a-staging-devdatalab-com" {
  vpc_id            = "vpc-030564af13abbb958"
  cidr_block        = "172.21.0.0/22"
  availability_zone = "us-west-1a"

  tags = {
    KubernetesCluster                              = "staging.devdatalab.com"
    Name                                           = "utility-us-west-1a.staging.devdatalab.com"
    "kubernetes.io/cluster/staging.devdatalab.com" = "owned"
    "kubernetes.io/role/elb"                       = "1"
  }
}

resource "aws_subnet" "utility-us-west-1b-staging-devdatalab-com" {
  vpc_id            = "vpc-030564af13abbb958"
  cidr_block        = "172.21.4.0/22"
  availability_zone = "us-west-1b"

  tags = {
    KubernetesCluster                              = "staging.devdatalab.com"
    Name                                           = "utility-us-west-1b.staging.devdatalab.com"
    "kubernetes.io/cluster/staging.devdatalab.com" = "owned"
    "kubernetes.io/role/elb"                       = "1"
  }
}

terraform = {
  required_version = ">= 0.9.3"
}
