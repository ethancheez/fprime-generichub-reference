module LocalDeployment {

  # ----------------------------------------------------------------------
  # Symbolic constants for port numbers
  # ----------------------------------------------------------------------

    enum Ports_RateGroups {
      rateGroup1
    }

  topology LocalDeployment {

    # ----------------------------------------------------------------------
    # Instances used in the topology
    # ----------------------------------------------------------------------

    instance bufferManager
    instance cmdDisp
    instance commDriver
    instance commQueue
    instance commStub
    instance deframer
    instance eventLogger
    instance fatalHandler
    instance framer
    instance rateDriver
    instance rateGroup1
    instance rateGroupDriver
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
    }

    connections FaultProtection {
      # eventLogger.FatalAnnounce -> fatalHandler.FatalReceive
    }

    connections Downlink {

      tlmSend.PktSend -> commQueue.comQueueIn[0]
      eventLogger.PktSend -> commQueue.comQueueIn[1]

      commQueue.comQueueSend -> framer.comIn
      commQueue.buffQueueSend -> framer.bufferIn

      framer.framedAllocate -> bufferManager.bufferGetCallee
      framer.framedOut -> commStub.comDataIn
      commStub.drvDataOut -> commDriver.$send
      commDriver.deallocate -> bufferManager.bufferSendIn
      commDriver.ready -> commStub.drvConnected
      commStub.comStatus -> commQueue.comStatusIn

    }
    
    connections Uplink {

      commDriver.allocate -> bufferManager.bufferGetCallee
      commDriver.$recv -> commStub.drvDataIn
      commStub.comDataOut -> deframer.framedIn
      deframer.framedDeallocate -> bufferManager.bufferSendIn

      deframer.comOut -> cmdSplitter.CmdBuff
      cmdSplitter.LocalCmd -> cmdDisp.seqCmdBuff
      cmdDisp.seqCmdStatus -> cmdSplitter.seqCmdStatus
      cmdSplitter.forwardSeqCmdStatus -> deframer.cmdResponseIn

      deframer.bufferAllocate -> bufferManager.bufferGetCallee
      deframer.bufferDeallocate -> bufferManager.bufferSendIn
      
    }

    connections HubToDriver {
      # Hub -> Framer -> Uart Driver
      hub.dataOutAllocate -> bufferManager.bufferGetCallee
      hub.dataOut -> hubFramer.bufferIn
      hubFramer.bufferDeallocate -> bufferManager.bufferSendIn
      hubFramer.framedAllocate -> bufferManager.bufferGetCallee
      hubFramer.framedOut -> hubCommDriver.$send
      hubCommDriver.deallocate -> bufferManager.bufferSendIn

      # Uart Driver -> Deframer -> Hub
      hubCommDriver.allocate -> bufferManager.bufferGetCallee
      hubCommDriver.$recv -> hubDeframer.framedIn
      hubDeframer.framedDeallocate -> bufferManager.bufferSendIn
      hubDeframer.bufferAllocate -> bufferManager.bufferGetCallee
      hubDeframer.bufferOut -> hub.dataIn
      hub.dataInDeallocate -> bufferManager.bufferSendIn
    }

    connections HubToDeployment {
      hub.LogSend -> eventLogger.LogRecv
      hub.TlmSend -> tlmSend.TlmRecv

      cmdSplitter.RemoteCmd -> hub.portIn[0]
      hub.portOut[0] -> cmdSplitter.seqCmdStatus

      hub.portOut[1] -> commQueue.buffQueueIn[0]
      framer.bufferDeallocate -> hub.portIn[1]

      # File Uplink
      deframer.bufferOut -> hub.portIn[2]
      hub.portOut[2] -> bufferManager.bufferSendIn
    }

    connections LocalDeployment {
      # Add here connections to user-defined components
    }

  }

}
