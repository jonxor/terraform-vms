virtual_Machines = [
  {
    createsize        = "200G"
    systemName        = "cookie3"
    systemDescription = "Brought up by terraform"
    memoryMB          = 4096
    vcpu              = 4
    networkBridge     = "br101"
    baseImageFile     = "CookieCutterV3.qcow2"
    qemu_agent        = false
    cpuSpecsmode      = "host-passthrough"
    makeAutoStart     = true
    makeRunning       = true
    IPAddress         = "192.168.202.52"
    generateCloudInit = true
  },
  {
    createsize        = "200G"
    systemName        = "cookie2"
    systemDescription = "Brought up by terraform"
    memoryMB          = 4096
    vcpu              = 4
    networkBridge     = "br101"
    baseImageFile     = "CookieCutterV3.qcow2"
    qemu_agent        = false
    cpuSpecsmode      = "host-passthrough"
    makeAutoStart     = true
    makeRunning       = true
    IPAddress         = "192.168.202.51"
    generateCloudInit = false
  }
]
