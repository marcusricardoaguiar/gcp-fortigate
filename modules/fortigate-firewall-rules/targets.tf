# The following resources will be created once we have the Hub and Spoke configured
# Forwarding the N-S traffic
resource "fortios_firewall_vip" "vip" {
  count = length(var.targets)

  name = "${var.prefix}tcp-${var.targets[count.index].name}-${var.targets[count.index].port}"
  extintf = "port1"
  extip = var.fortigate_elb_eip_address
  portforward = "enable"
  extport = var.targets[count.index].port
  mappedport = var.targets[count.index].mappedport

  mappedip {
    range = var.targets[count.index].ip
  }
}

resource "fortios_firewallservice_custom" "service" {
  count = length(var.targets)

  name = "${var.prefix}tcp-${var.targets[count.index].name}-${var.targets[count.index].mappedport}"
  tcp_portrange = var.targets[count.index].mappedport
}

resource "fortios_firewall_policy" "vip_allow" {
  count = length(var.targets)

  name = "allow-${var.prefix}tcp-${var.targets[count.index].name}-${var.targets[count.index].port}"
  action = "accept"
  schedule = "always"
  inspection_mode = "flow"
  status = "enable"
  logtraffic = "all"

  srcintf {
    name = "port1"
  }
  dstintf {
    name = "port2"
  }
  srcaddr {
    name = "all"
  }
  dstaddr {
    name = fortios_firewall_vip.vip[count.index].name
  }
  service {
    name = fortios_firewallservice_custom.service[count.index].name
  }
  nat = "disable"
}
