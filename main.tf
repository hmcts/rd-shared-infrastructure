locals {
  tags = "${merge(var.common_tags,
    map("Team Contact", "${var.team_contact}")
    )}"
}
