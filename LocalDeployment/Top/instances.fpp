module LocalDeployment {

  # ----------------------------------------------------------------------
  # Defaults
  # ----------------------------------------------------------------------

  module Default {
    constant QUEUE_SIZE = 3
    constant STACK_SIZE = 64 * 1024
  }

  # ----------------------------------------------------------------------
  # Active component instances
  # ----------------------------------------------------------------------

  instance cmdDisp: Svc.CommandDispatcher base id 0x0100 \
    queue size Default.QUEUE_SIZE\
    stack size Default.STACK_SIZE \
    priority 101

  instance eventLogger: Svc.ActiveLogger base id 0x0200 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 98

  instance tlmSend: Svc.TlmChan base id 0x0300 \
    queue size Default.QUEUE_SIZE \
    stack size Default.STACK_SIZE \
    priority 97

  instance commQueue: Svc.ComQueue base id 0x0400 \
      queue size Default.QUEUE_SIZE \
      stack size Default.STACK_SIZE \
      priority 100

  # ----------------------------------------------------------------------
  # Queued component instances
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # Passive component instances
  # ----------------------------------------------------------------------

  instance rateGroup1: Svc.PassiveRateGroup base id 0x1000

  instance commStub: Svc.ComStub base id 0x3900

  instance commDriver: Arduino.StreamDriver base id 0x4000

  instance framer: Svc.Framer base id 0x4100

  instance fatalAdapter: Svc.AssertFatalAdapter base id 0x4200

  instance fatalHandler: Svc.FatalHandler base id 0x4300

  instance timeHandler: Arduino.ArduinoTime base id 0x4400 \

  instance rateGroupDriver: Svc.RateGroupDriver base id 0x4500

  instance staticMemory: Svc.StaticMemory base id 0x4600

  instance textLogger: Svc.PassiveTextLogger base id 0x4700

  instance deframer: Svc.Deframer base id 0x4800

  instance systemResources: Svc.SystemResources base id 0x4900

  instance rateDriver: Arduino.HardwareRateDriver base id 0x4A00

  # Hub

  instance cmdSplitter: Svc.CmdSplitter base id 0x10000

  instance hub: Svc.GenericHub base id 0x10100

  instance hubCommDriver: Arduino.StreamDriver base id 0x10200

  instance hubFramer: Svc.Framer base id 0x10300

  instance hubDeframer: Svc.Deframer base id 0x010400

}
