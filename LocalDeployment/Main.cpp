// ======================================================================
// \title  Main.cpp
// \brief main program for the F' application. Intended for CLI-based systems (Linux, macOS)
//
// ======================================================================
// Used to access topology functions
#include <LocalDeployment/Top/LocalDeploymentTopologyAc.hpp>
#include <LocalDeployment/Top/LocalDeploymentTopology.hpp>
// Used for Task Runner
#include <Os/Baremetal/TaskRunner/TaskRunner.hpp>

// Used for logging
#include <Os/Log.hpp>
#include <Arduino/Os/StreamLog.hpp>

// Instantiate a system logger that will handle Fw::Logger::logMsg calls
Os::Log logger;

// Task Runner
Os::TaskRunner taskrunner;

/**
 * \brief setup the program
 *
 * This is an extraction of the Arduino setup() function.
 * 
 */
void setup()
{
    // Setup Serial
    Serial.begin(115200);
    Serial1.begin(115200);
    Serial2.begin(115200);
    Os::setArduinoStreamLogHandler(&Serial2);
    delay(1000);
    Fw::Logger::logMsg("Program Started\n");

    // Object for communicating state to the reference topology
    LocalDeployment::TopologyState inputs;
    inputs.uartNumber = 0;
    inputs.uartBaud = 115200;

    // Setup topology
    LocalDeployment::setupTopology(inputs);
}

/**
 * \brief run the program
 *
 * This is an extraction of the Arduino loop() function.
 * 
 */
void loop()
{
#ifdef USE_BASIC_TIMER
    rateDriver.cycle();
#endif
    taskrunner.run();
}