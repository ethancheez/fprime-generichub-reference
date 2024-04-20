module LocalDeployment {

  # ----------------------------------------------------------------------
  # Symbolic constants for port numbers
  # ----------------------------------------------------------------------

    enum Ports_RateGroups {
      rateGroup1
    }

    enum Ports_StaticMemory {
      framer
      deframer
      deframing
      hub
      hubFramer
      hubDeframer
      hubCommDriver
    }

  topology LocalDeployment {

    # ----------------------------------------------------------------------
    # Instances used in the topology
    # ----------------------------------------------------------------------

    instance cmdDisp
    instance commDriver
    instance commQueue
    instance commStub
    instance deframer
    instance eventLogger
    instance fatalAdapter
    instance fatalHandler
    instance framer
    instance rateDriver
    instance rateGroup1
    instance rateGroupDriver
    instance staticMemory
    instance systemResources
    instance textLogger
    instance timeHandler
    instance tlmSend

    # Hub
    instance cmdSplitter
    instance hub
    instance hubCommDriver
    instance hubFramer
    instance hubDeframer

    # ----------------------------------------------------------------------
    # Pattern graph specifiers
    # ----------------------------------------------------------------------

    command connections instance cmdDisp

    event connections instance eventLogger

    telemetry connections instance tlmSend

    text event connections instance textLogger

    time connections instance timeHandler

    # ----------------------------------------------------------------------
    # Direct graph specifiers
    # ----------------------------------------------------------------------

    connections RateGroups {
      # Block driver
      rateDriver.CycleOut -> rateGroupDriver.CycleIn

      # Rate group 1
      rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup1] -> rateGroup1.CycleIn
      rateGroup1.RateGroupMemberOut[0] -> commDriver.schedIn
      rateGroup1.RateGroupMemberOut[1] -> hubCommDriver.schedIn
      rateGroup1.RateGroupMemberOut[2] -> tlmSend.Run
      rateGroup1.RateGroupMemberOut[3] -> systemResources.run
      rateGroup1.RateGroupMemberOut[4] -> commQueue.run
    }

    connections FaultProtection {
      eventLogger.FatalAnnounce -> fatalHandler.FatalReceive
    }

    connections Downlink {

      tlmSend.PktSend -> commQueue.comQueueIn[0]
      eventLogger.PktSend -> commQueue.comQueueIn[1]

      commQueue.comQueueSend -> framer.comIn
      commQueue.buffQueueSend -> framer.bufferIn

      framer.framedAllocate -> staticMemory.bufferAllocate[Ports_StaticMemory.framer]
      framer.framedOut -> commStub.comDataIn
      commStub.drvDataOut -> commDriver.$send
      commDriver.deallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.framer]
      commDriver.ready -> commStub.drvConnected
      commStub.comStatus -> commQueue.comStatusIn

    }
    
    connections Uplink {

      commDriver.allocate -> staticMemory.bufferAllocate[Ports_StaticMemory.deframer]
      commDriver.$recv -> commStub.drvDataIn
      commStub.comDataOut -> deframer.framedIn
      deframer.framedDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.deframer]

      deframer.comOut -> cmdSplitter.CmdBuff
      cmdSplitter.LocalCmd -> cmdDisp.seqCmdBuff
      cmdDisp.seqCmdStatus -> cmdSplitter.seqCmdStatus
      cmdSplitter.forwardSeqCmdStatus -> deframer.cmdResponseIn

      deframer.bufferAllocate -> staticMemory.bufferAllocate[Ports_StaticMemory.deframing]
      deframer.bufferDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.deframing]
      
    }

    connections HubToDriver {
      # Hub -> Framer -> Uart Driver
      hub.dataOutAllocate -> staticMemory.bufferAllocate[Ports_StaticMemory.hub]
      hub.dataOut -> hubFramer.bufferIn
      hubFramer.bufferDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.hub]
      hubFramer.framedAllocate -> staticMemory.bufferAllocate[Ports_StaticMemory.hubFramer]
      hubFramer.framedOut -> hubCommDriver.$send
      hubCommDriver.deallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.hubFramer]

      # Uart Driver -> Deframer -> Hub
      hubCommDriver.allocate -> staticMemory.bufferAllocate[Ports_StaticMemory.hubCommDriver]
      hubCommDriver.$recv -> hubDeframer.framedIn
      hubDeframer.framedDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.hubCommDriver]
      hubDeframer.bufferAllocate -> staticMemory.bufferAllocate[Ports_StaticMemory.hubDeframer]
      hubDeframer.bufferOut -> hub.dataIn
      hub.dataInDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.hubDeframer]
    }


    connections HubToDeployment {
      hub.LogSend -> eventLogger.LogRecv
      hub.TlmSend -> tlmSend.TlmRecv

      cmdSplitter.RemoteCmd -> hub.portIn[0]
      hub.portOut[0] -> cmdSplitter.seqCmdStatus

      hub.portOut[1] -> commQueue.buffQueueIn[0]
      framer.bufferDeallocate -> hub.portIn[1]
    }

    connections LocalDeployment {
      # Add here connections to user-defined components
    }

  }

}
