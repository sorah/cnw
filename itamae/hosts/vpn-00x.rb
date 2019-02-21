node.reverse_merge!(
  vpn_router: {
    primary_ip: '',
    primary_ip6: '',
    vpn_rtb4: {
      default: false,
      static: [
        "route 0.0.0.0/0 via 10.25.250.x;"
      ],
    },
    vpns: {
      venue: {
        leftsubnet: '0.0.0.0/0',
        rightsubnet: '0.0.0.0/0',
        leftid: '@vpn-001',
        rightid: '@gw-001',
        left: '%any',
        right: '%any',
        ifname: 'venue',
        inner_left: '169.254.1.101/30',
        inner_right: '169.254.1.102/30',
        mark: 20,
        rtb: 'vpn',
        ikelifetime: '21600s',
        keylife: '3600s',
        rekeymargin: '600s',
        aggressive: true,
        ike: 'aes256-sha512-modp2048',
        esp: 'aes256-sha256-modp2048',
        psk: node[:secrets][:vpn_psk],
      },
    },
  },
)
