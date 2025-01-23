data "fortios_system_interface" "probe" {
  name = "probe"
}
data "fortios_system_proberesponse" "probe" {}

resource "fortios_firewall_vip" "vip_probe" {
  name        = "${var.prefix}probe"
  extintf     = "port1"
  extip       = var.fortigate_elb_eip_address
  portforward = "enable"
  extport     = data.fortios_system_proberesponse.probe.port
  mappedport  = data.fortios_system_proberesponse.probe.port
  mappedip {
    range = split(" ", data.fortios_system_interface.probe.ip)[0]
  }
}

resource "fortios_firewallservice_custom" "service_probe" {
  name          = "LB_Probe"
  tcp_portrange = data.fortios_system_proberesponse.probe.port
}

resource "fortios_firewall_policy" "probe_allow" {
  name            = "allow-${var.prefix}probe"
  action          = "accept"
  schedule        = "always"
  inspection_mode = "flow"
  status          = "enable"

  srcintf {
    name = "port1"
  }
  dstintf {
    name = "probe"
  }
  srcaddr {
    name = "all"
  }
  dstaddr {
    name = fortios_firewall_vip.vip_probe.name
  }
  service {
    name = fortios_firewallservice_custom.service_probe.name
  }
  nat = "disable"
}
