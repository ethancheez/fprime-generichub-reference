// ======================================================================
// \title  RemoteDeploymentTopology.cpp
// \brief cpp file containing the topology instantiation code
//
// ======================================================================
// Provides access to autocoded functions
#include <TeensyToPi/RemoteDeployment/Top/RemoteDeploymentTopologyAc.hpp>
// Note: Uncomment when using Svc:TlmPacketizer
//#include <RemoteDeployment/Top/RemoteDeploymentPacketsAc.hpp>

// Necessary project-specified types
#include <Fw/Types/MallocAllocator.hpp>
#include <Svc/FramingProtocol/FprimeProtocol.hpp>
#include <Utils/Hash/HashConfig.hpp>

// Used for 1Hz synthetic cycling
#include <Os/Mutex.hpp>

#include <Fw/Logger/Logger.hpp>

// Allows easy reference to objects in FPP/autocoder required namespaces
using namespace RemoteDeployment;

// The reference topology uses a malloc-based allocator for components that need to allocate memory during the
// initialization phase.
Fw::MallocAllocator mallocator;

// The reference topology uses the F´ packet protocol when communicating with the ground and therefore uses the F´
// framing and deframing implementations.
Svc::FprimeFraming framing;
Svc::FprimeDeframing deframing;

Svc::ComQueue::QueueConfigurationTable configurationTable;

// The reference topology divides the incoming clock signal (1Hz) into sub-signals: 1Hz, 1/2Hz, and 1/4Hz with 0 offset
Svc::RateGroupDriver::DividerSet rateGroupDivisorsSet{{{1, 0}, {2, 0}, {4, 0}}};

// Rate groups may supply a context token to each of the attached children whose purpose is set by the project. The
// reference topology sets each token to zero as these contexts are unused in this project.
NATIVE_INT_TYPE rateGroup1Context[Svc::ActiveRateGroup::CONNECTION_COUNT_MAX] = {};
NATIVE_INT_TYPE rateGroup2Context[Svc::ActiveRateGroup::CONNECTION_COUNT_MAX] = {};
NATIVE_INT_TYPE rateGroup3Context[Svc::ActiveRateGroup::CONNECTION_COUNT_MAX] = {};

// A number of constants are needed for construction of the topology. These are specified here.
enum TopologyConstants {
    CMD_SEQ_BUFFER_SIZE = 5 * 1024,
    FILE_DOWNLINK_TIMEOUT = 30000,
    FILE_DOWNLINK_COOLDOWN = 1000,
    FILE_DOWNLINK_CYCLE_TIME = 1000,
    FILE_DOWNLINK_FILE_QUEUE_DEPTH = 10,
    HEALTH_WATCHDOG_CODE = 0x123,
    COMM_PRIORITY = 100,
    // bufferManager constants
    FRAMER_BUFFER_SIZE = FW_MAX(FW_COM_BUFFER_MAX_SIZE, FW_FILE_BUFFER_MAX_SIZE + sizeof(U32)) + HASH_DIGEST_LENGTH + Svc::FpFrameHeader::SIZE,
    FRAMER_BUFFER_COUNT = 30,
    DEFRAMER_BUFFER_SIZE = FW_MAX(FW_COM_BUFFER_MAX_SIZE, FW_FILE_BUFFER_MAX_SIZE + sizeof(U32)),
    DEFRAMER_BUFFER_COUNT = 30,
    COM_DRIVER_BUFFER_SIZE = 3000,
    COM_DRIVER_BUFFER_COUNT = 30,
    BUFFER_MANAGER_ID = 200
};

// Ping entries are autocoded, however; this code is not properly exported. Thus, it is copied here.
Svc::Health::PingEntry pingEntries[] = {
    {PingEntries::RemoteDeployment_blockDrv::WARN, PingEntries::RemoteDeployment_blockDrv::FATAL, "blockDrv"},
    {PingEntries::RemoteDeployment_tlmSend::WARN, PingEntries::RemoteDeployment_tlmSend::FATAL, "chanTlm"},
    {PingEntries::RemoteDeployment_cmdDisp::WARN, PingEntries::RemoteDeployment_cmdDisp::FATAL, "cmdDisp"},
    {PingEntries::RemoteDeployment_cmdSeq::WARN, PingEntries::RemoteDeployment_cmdSeq::FATAL, "cmdSeq"},
    {PingEntries::RemoteDeployment_eventLogger::WARN, PingEntries::RemoteDeployment_eventLogger::FATAL, "eventLogger"},
    {PingEntries::RemoteDeployment_fileDownlink::WARN, PingEntries::RemoteDeployment_fileDownlink::FATAL, "fileDownlink"},
    {PingEntries::RemoteDeployment_fileManager::WARN, PingEntries::RemoteDeployment_fileManager::FATAL, "fileManager"},
    {PingEntries::RemoteDeployment_fileUplink::WARN, PingEntries::RemoteDeployment_fileUplink::FATAL, "fileUplink"},
    {PingEntries::RemoteDeployment_prmDb::WARN, PingEntries::RemoteDeployment_prmDb::FATAL, "prmDb"},
    {PingEntries::RemoteDeployment_rateGroup1::WARN, PingEntries::RemoteDeployment_rateGroup1::FATAL, "rateGroup1"},
    {PingEntries::RemoteDeployment_rateGroup2::WARN, PingEntries::RemoteDeployment_rateGroup2::FATAL, "rateGroup2"},
    {PingEntries::RemoteDeployment_rateGroup3::WARN, PingEntries::RemoteDeployment_rateGroup3::FATAL, "rateGroup3"},
};

/**
 * \brief configure/setup components in project-specific way
 *
 * This is a *helper* function which configures/sets up each component requiring project specific input. This includes
 * allocating resources, passing-in arguments, etc. This function may be inlined into the topology setup function if
 * desired, but is extracted here for clarity.
 */
void configureTopology() {
    // Buffer managers need a configured set of buckets and an allocator used to allocate memory for those buckets.
    Svc::BufferManager::BufferBins upBuffMgrBins;
    memset(&upBuffMgrBins, 0, sizeof(upBuffMgrBins));
    upBuffMgrBins.bins[0].bufferSize = FRAMER_BUFFER_SIZE;
    upBuffMgrBins.bins[0].numBuffers = FRAMER_BUFFER_COUNT;
    upBuffMgrBins.bins[1].bufferSize = DEFRAMER_BUFFER_SIZE;
    upBuffMgrBins.bins[1].numBuffers = DEFRAMER_BUFFER_COUNT;
    upBuffMgrBins.bins[2].bufferSize = COM_DRIVER_BUFFER_SIZE;
    upBuffMgrBins.bins[2].numBuffers = COM_DRIVER_BUFFER_COUNT;
    remote_bufferManager.setup(BUFFER_MANAGER_ID, 0, mallocator, upBuffMgrBins);

    // Framer and Deframer components need to be passed a protocol handler
    remote_hubFramer.setup(framing);
    remote_hubDeframer.setup(deframing);

    // Rate group driver needs a divisor list
    remote_rateGroupDriver.configure(rateGroupDivisorsSet);

    // Rate groups require context arrays.
    remote_rateGroup1.configure(rateGroup1Context, FW_NUM_ARRAY_ELEMENTS(rateGroup1Context));
    remote_rateGroup2.configure(rateGroup2Context, FW_NUM_ARRAY_ELEMENTS(rateGroup2Context));
    remote_rateGroup3.configure(rateGroup3Context, FW_NUM_ARRAY_ELEMENTS(rateGroup3Context));

    // File downlink requires some project-derived properties.
    remote_fileDownlink.configure(FILE_DOWNLINK_TIMEOUT, FILE_DOWNLINK_COOLDOWN, FILE_DOWNLINK_CYCLE_TIME,
                           FILE_DOWNLINK_FILE_QUEUE_DEPTH);

    // Parameter database is configured with a database file name, and that file must be initially read.
    remote_prmDb.configure("PrmDb.dat");
    remote_prmDb.readParamFile();

    // Note: Uncomment when using Svc:TlmPacketizer
    // tlmSend.setPacketList(RemoteDeploymentPacketsPkts, RemoteDeploymentPacketsIgnore, 1);

    // Events (highest-priority)
    configurationTable.entries[0] = {.depth = 100, .priority = 0};
    // Telemetry
    configurationTable.entries[1] = {.depth = 500, .priority = 2};
    // File Downlink
    configurationTable.entries[2] = {.depth = 100, .priority = 1};
    // Allocation identifier is 0 as the MallocAllocator discards it
    remote_comQueue.configure(configurationTable, 0, mallocator);
}

// Public functions for use in main program are namespaced with deployment name RemoteDeployment
namespace RemoteDeployment {
void setupTopology(const TopologyState& state) {
    // Autocoded initialization. Function provided by autocoder.
    initComponents(state);
    // Autocoded id setup. Function provided by autocoder.
    setBaseIds();
    // Autocoded connection wiring. Function provided by autocoder.
    connectComponents();
    // Autocoded configuration. Function provided by autocoder.
    configComponents(state);
    // Deployment-specific component configuration. Function provided above. May be inlined, if desired.
    configureTopology();
    // Autocoded command registration. Function provided by autocoder.
    regCommands();
    // Autocoded parameter loading. Function provided by autocoder.
    // loadParameters();
    // Autocoded task kick-off (active components). Function provided by autocoder.
    startTasks(state);
    if (state.uartDevice != nullptr) {
        Os::TaskString name("ReceiveTask");
        // Uplink is configured for receive so a socket task is started
        if (remote_hubDriver.open(state.uartDevice, static_cast<Drv::LinuxUartDriver::UartBaudRate>(state.baudRate), 
                           Drv::LinuxUartDriver::NO_FLOW, Drv::LinuxUartDriver::PARITY_NONE, Svc::DeframerCfg::RING_BUFFER_SIZE)) {
            remote_hubDriver.start(COMM_PRIORITY, Default::STACK_SIZE);
        } else {
            printf("Failed to open UART device %s at baud rate %" PRIu32 "\n", state.uartDevice, state.baudRate);
        }
    }
}

// Variables used for cycle simulation
Os::Mutex cycleLock;
volatile bool cycleFlag = true;

void startSimulatedCycle(Fw::TimeInterval interval) {
    cycleLock.lock();
    bool cycling = cycleFlag;
    cycleLock.unLock();

    // Main loop
    while (cycling) {
        RemoteDeployment::remote_blockDrv.callIsr();
        Os::Task::delay(interval);

        cycleLock.lock();
        cycling = cycleFlag;
        cycleLock.unLock();
    }
}

void stopSimulatedCycle() {
    cycleLock.lock();
    cycleFlag = false;
    cycleLock.unLock();
}

void teardownTopology(const TopologyState& state) {
    // Autocoded (active component) task clean-up. Functions provided by topology autocoder.
    stopTasks(state);
    freeThreads(state);

    // Other task clean-up.
    remote_hubDriver.quitReadThread();
    (void)remote_hubDriver.join();

    // Resource deallocation
    remote_bufferManager.cleanup();
}
};  // namespace RemoteDeployment
