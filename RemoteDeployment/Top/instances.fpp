module RemoteDeployment {

  constant REMOTE_TOPOLOGY_BASE = 0x10000000

  # ----------------------------------------------------------------------
  # Defaults
  # ----------------------------------------------------------------------

  module Default {
    constant QUEUE_SIZE = 10
    constant STACK_SIZE = 64 * 1024
  }

  # ----------------------------------------------------------------------
  # Active component instances
  # ----------------------------------------------------------------------

  instance remote_blockDrv: Drv.BlockDriver base id REMOTE_TOPOLOGY_BASE + 0x0100 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 140

  instance remote_rateGroup1: Svc.ActiveRateGroup base id REMOTE_TOPOLOGY_BASE + 0x0200 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 120

  instance remote_rateGroup2: Svc.ActiveRateGroup base id REMOTE_TOPOLOGY_BASE + 0x0300 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 119

  instance remote_rateGroup3: Svc.ActiveRateGroup base id REMOTE_TOPOLOGY_BASE + 0x0400 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 118

  instance remote_cmdDisp: Svc.CommandDispatcher base id REMOTE_TOPOLOGY_BASE + 0x0500 \
    queue size 20 \
    stack size Default.STACK_SIZE \
    priority 101

  instance remote_cmdSeq: Svc.CmdSequencer base id REMOTE_TOPOLOGY_BASE + 0x0600 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 100

  instance remote_comQueue: Svc.ComQueue base id REMOTE_TOPOLOGY_BASE + 0x0700 \
      queue size Default.QUEUE_SIZE \
      stack size Default.STACK_SIZE \
      priority 100 \

  instance remote_fileDownlink: Svc.FileDownlink base id REMOTE_TOPOLOGY_BASE + 0x0800 \
    queue size 30 \
    stack size Default.STACK_SIZE \
    priority 100

  instance remote_fileManager: Svc.FileManager base id REMOTE_TOPOLOGY_BASE + 0x0900 \
    queue size 30 \
    stack size Default.STACK_SIZE \
    priority 100

  instance remote_fileUplink: Svc.FileUplink base id REMOTE_TOPOLOGY_BASE + 0x0A00 \
    queue size 30 \
    stack size Default.STACK_SIZE \
    priority 100

  instance remote_eventLogger: Svc.ActiveLogger base id REMOTE_TOPOLOGY_BASE + 0x0B00 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 98

  # comment in Svc.TlmChan or Svc.TlmPacketizer
  # depending on which form of telemetry downlink
  # you wish to use

  instance remote_tlmSend: Svc.TlmChan base id REMOTE_TOPOLOGY_BASE + 0x0C00 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 97

  #instance tlmSend: Svc.TlmPacketizer base id REMOTE_TOPOLOGY_BASE + 0x0C00 \
  #    queue size Default.QUEUE_SIZE \
  #    stack size Default.STACK_SIZE \
  #    priority 97

  instance remote_prmDb: Svc.PrmDb base id REMOTE_TOPOLOGY_BASE + 0x0D00 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 96

  # ----------------------------------------------------------------------
  # Queued component instances
  # ----------------------------------------------------------------------

  instance remote_health: Svc.Health base id REMOTE_TOPOLOGY_BASE + 0x2000 \
    queue size 25

  # ----------------------------------------------------------------------
  # Passive component instances
  # ----------------------------------------------------------------------

  @ Communications driver. May be swapped with other com drivers like UART or TCP
  instance remote_comDriver: Drv.LinuxUartDriver base id REMOTE_TOPOLOGY_BASE + 0x4000

  instance remote_framer: Svc.Framer base id REMOTE_TOPOLOGY_BASE + 0x4100

  instance remote_fatalAdapter: Svc.AssertFatalAdapter base id REMOTE_TOPOLOGY_BASE + 0x4200

  instance remote_fatalHandler: Svc.FatalHandler base id REMOTE_TOPOLOGY_BASE + 0x4300

  instance remote_bufferManager: Svc.BufferManager base id REMOTE_TOPOLOGY_BASE + 0x4400

  instance remote_posixTime: Svc.PosixTime base id REMOTE_TOPOLOGY_BASE + 0x4500

  instance remote_rateGroupDriver: Svc.RateGroupDriver base id REMOTE_TOPOLOGY_BASE + 0x4600

  instance remote_textLogger: Svc.PassiveTextLogger base id REMOTE_TOPOLOGY_BASE + 0x4800

  instance remote_deframer: Svc.Deframer base id REMOTE_TOPOLOGY_BASE + 0x4900

  instance remote_systemResources: Svc.SystemResources base id REMOTE_TOPOLOGY_BASE + 0x4A00

  instance remote_comStub: Svc.ComStub base id REMOTE_TOPOLOGY_BASE + 0x4B00

  # Hub

  instance remote_hub: Svc.GenericHub base id REMOTE_TOPOLOGY_BASE + 0x100000

  instance remote_hubFramer: Svc.Framer base id REMOTE_TOPOLOGY_BASE + 0x100100

  instance remote_hubDeframer: Svc.Deframer base id REMOTE_TOPOLOGY_BASE + 0x100200

  instance remote_hubDriver: Drv.LinuxUartDriver base id REMOTE_TOPOLOGY_BASE + 0x100300
}
