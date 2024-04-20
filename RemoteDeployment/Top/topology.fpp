module RemoteDeployment {

  # ----------------------------------------------------------------------
  # Symbolic constants for port numbers
  # ----------------------------------------------------------------------

    enum Ports_RateGroups {
      rateGroup1
      rateGroup2
      rateGroup3
    }

  topology RemoteDeployment {

    # ----------------------------------------------------------------------
    # Instances used in the topology
    # ----------------------------------------------------------------------

    # instance remote_health
    instance remote_blockDrv
    instance remote_cmdDisp
    instance remote_comDriver
    instance remote_comQueue
    instance remote_comStub
    instance remote_deframer
    instance remote_eventLogger
    instance remote_fatalAdapter
    instance remote_fatalHandler
    instance remote_fileDownlink
    instance remote_fileManager
    instance remote_fileUplink
    instance remote_bufferManager
    instance remote_framer
    instance remote_posixTime
    instance remote_prmDb
    instance remote_rateGroup1
    instance remote_rateGroup2
    instance remote_rateGroup3
    instance remote_rateGroupDriver
    instance remote_textLogger
    instance remote_systemResources
    instance remote_tlmSend

    # Hub

    instance remote_hub
    instance remote_hubDeframer
    instance remote_hubDriver
    instance remote_hubFramer

    # ----------------------------------------------------------------------
    # Pattern graph specifiers
    # ----------------------------------------------------------------------

    command connections instance remote_cmdDisp

    event connections instance remote_hub

    param connections instance remote_prmDb

    telemetry connections instance remote_hub

    text event connections instance remote_textLogger

    time connections instance remote_posixTime

    # health connections instance remote_health

    # ----------------------------------------------------------------------
    # Direct graph specifiers
    # ----------------------------------------------------------------------

    connections RateGroups {
      # Block driver
      remote_blockDrv.CycleOut -> remote_rateGroupDriver.CycleIn

      # Rate group 1
      remote_rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup1] -> remote_rateGroup1.CycleIn
      # remote_rateGroup1.RateGroupMemberOut[0] -> remote_blockDrv.Sched
      # remote_rateGroup1.RateGroupMemberOut[1] -> remote_bufferManager.schedIn
      remote_rateGroup1.RateGroupMemberOut[0] -> remote_fileDownlink.Run

      # Rate group 2
      remote_rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup2] -> remote_rateGroup2.CycleIn

      # Rate group 3
      remote_rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup3] -> remote_rateGroup3.CycleIn
      # remote_rateGroup3.RateGroupMemberOut[0] -> remote_systemResources.run
      # remote_rateGroup3.RateGroupMemberOut[0] -> remote_health.Run
    }

    connections HubToDriver {
      # Hub -> Framer -> Uart Driver
      remote_hub.dataOutAllocate -> remote_bufferManager.bufferGetCallee
      remote_hub.dataOut -> remote_comQueue.buffQueueIn[0]
      remote_comQueue.buffQueueSend -> remote_framer.bufferIn
      remote_framer.comStatusOut -> remote_comQueue.comStatusIn
      remote_framer.bufferDeallocate -> remote_bufferManager.bufferSendIn
      remote_framer.framedAllocate -> remote_bufferManager.bufferGetCallee
      remote_framer.framedOut -> remote_comStub.comDataIn
      remote_comStub.comStatus -> remote_framer.comStatusIn
      remote_comStub.drvDataOut -> remote_comDriver.$send
      remote_comDriver.deallocate -> remote_bufferManager.bufferSendIn
      remote_comDriver.ready -> remote_comStub.drvConnected

      # Uart Driver -> Deframer -> Hub
      remote_comDriver.allocate -> remote_bufferManager.bufferGetCallee
      remote_comDriver.$recv -> remote_comStub.drvDataIn
      remote_comStub.comDataOut -> remote_deframer.framedIn
      remote_deframer.framedDeallocate -> remote_bufferManager.bufferSendIn
      remote_deframer.bufferAllocate -> remote_bufferManager.bufferGetCallee
      remote_deframer.bufferOut -> remote_hub.dataIn
      remote_hub.dataInDeallocate -> remote_bufferManager.bufferSendIn
    }

    connections HubToDeployment {
      remote_hub.portOut[0] -> remote_cmdDisp.seqCmdBuff
      remote_cmdDisp.seqCmdStatus -> remote_hub.portIn[0]

      remote_fileDownlink.bufferSendOut -> remote_hub.portIn[1]
      remote_hub.portOut[1] -> remote_fileDownlink.bufferReturn
    }

    connections RemoteDeployment {
      # Add here connections to user-defined components
    }

  }

}
