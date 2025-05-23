# Informatica IICS-CAI Migration Tools

<!-- TOC -->

- [Informatica IICS-CAI Migration Tools](#informatica-iics-cai-migration-tools)
  - [Main Ant Script](#main-ant-script)
  - [Example Transformation Configuration](#example-transformation-configuration)
  - [Invoking transform from Main Build Script of Your IICS component Build](#invoking-transform-from-main-build-script-of-your-iics-component-build)
    - [Key properties to drive invocation of transform Target](#key-properties-to-drive-invocation-of-transform-target)
    - [Example Target Implementation in Main Build](#example-target-implementation-in-main-build)
  - [Set Process Suspend On Fault Deployment Attributes](#set-process-suspend-on-fault-deployment-attributes)
  - [Suspend On Fault XSLT](#suspend-on-fault-xslt)
    - [Parameters](#parameters)
    - [Example use in Ant](#example-use-in-ant)
  - [Set Process Tracing Level Attribute](#set-process-tracing-level-attribute)
    - [XSLT Set Tracing Level](#xslt-set-tracing-level)
    - [Parameters](#parameters-1)
    - [Example use in Ant](#example-use-in-ant-1)
  - [Setting Run On Parameter of the Process](#setting-run-on-parameter-of-the-process)
  - [Move Process to different agent or group](#move-process-to-different-agent-or-group)
    - [Example Use in Ant](#example-use-in-ant-2)
  - [Move Process from Secure Agent or agent deployment group to Cloud](#move-process-from-secure-agent-or-agent-deployment-group-to-cloud)
    - [Example Use in Ant](#example-use-in-ant-3)
  - [Sort Connectors Transformation](#sort-connectors-transformation)
    - [Example Allowed Groups Mapping File](#example-allowed-groups-mapping-file)
  - [Set Allowed Groups on  Process Designs](#set-allowed-groups-on--process-designs)
    - [Parameters](#parameters-2)
    - [Example Allowed Groups Mapping File](#example-allowed-groups-mapping-file-1)
    - [Example Allowed Users Mapping File](#example-allowed-users-mapping-file)
    - [Example Use in Ant](#example-use-in-ant-4)
  - [Licenses anf Credits](#licenses-anf-credits)

<!-- /TOC -->

This Project provides set of IICS Asset Transformation Utilities to automate common
transition changes on Application Integration Design Assets. Transformations are mostly implemented
using XSLT while providing Apache Ant Scripting to run these transformations in platform independent way.

This Tool set uses the same XSLT Processor as Informatica Cloud Platform
(Saxon) to provide consistent output for transformed designs.

## Main Ant Script

The [build.xml](https://github.com/jbrazda/icai-migration-tools/blob/master/build.xml) ant script provides targets to Transform Expanded Designs in the directory

It has following main targets

```text
Buildfile: /Users/jbrazda/git/icai-migration-tools/build.xml

Main targets:

 build.dist  Build Migration Utility Distribution File with Sources
 help        help - describes how to use this script
 transform   Migrate IPD Exported Archive from one environment to another
Default target: help
```

Use the `transform` target to execute all migration transformations in one step sequentially.

The transformation process relies on Externally provided properties or property file which
enable/disable individual transformation steps and configure which designs should undergo specific
transformation and what will be transformation parameters.

## Example Transformation Configuration

transformation property file should have an extension `transform.properties` as the script can prompt for list of
pre configured transformation properties when the file property is not set. Follow example naming convention in
the form of `PackageName_customer_environment.transform.properties` i.e. `AlertServices_iclab_dev.transform.properties`

```properties
# MOVE Process to Cloud
# ---------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.to.cloud.enabled=true
# use this property to include specific processes or use Ant pattern expressions.
# migrate.processObjects.enabled=true is set
ipd.migrate.processes.to.cloud.include=*.PROCESS.xml
# you can exclude specified files from tar
ipd.migrate.processes.to.cloud.exclude=*-1.PROCESS.xml


# MOVE Processes to Agent
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.to.agent.enabled=true
# specify target Agent Name or Agent Group Name to Migrate to
ipd.migrate.processes.to.agent.name=NA
# Use this property to include specific processes or use Ant pattern expressions.
# This property is required when migrate.processObjects.enabled=true is set
# ipd.migrate.processes.to.agent.include=Explore/Tools/Processes/SP-Shell-CMD.PROCESS.xml
ipd.migrate.processes.to.agent.include=**/*.PROCESS.xml
# you can exclude specified files from 
ipd.migrate.processes.to.agent.exclude=SCH-*.PROCESS.xml


# MOVE Connections to Agent
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.connections.to.agent.enabled=true
# specify target Agent Name or Agent Group Name to Migrate to
ipd.migrate.connections.to.agent.name=NA
# Use this property to include specific connections or use Ant pattern expressions.
# This property is required when migrate.processObjects.enabled=true is set
# ipd.migrate.processes.to.agent.include=Explore/Tools/Processes/SP-Shell-CMD.PROCESS.xml
ipd.migrate.connections.to.agent.include=**/*.AI_CONNECTION.xml
# you can exclude specified files from 
ipd.migrate.connections.to.agent.exclude=**/Email-Alerts.AI_CONNECTION.xml

# SET Process Tracing Levels
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.tracingLevelUpdate.enabled=true

# List of tracing levels to be processed
# this is an example to process all levels when you want to set levels on any selected processes
# ipd.migrate.processes.tracingLevelUpdate.levels=none,terse,normal,verbose
# note that each supported tracing level must have incudes/excludes defined
# Following example setting will set  all processes tracing level to None
ipd.migrate.processes.tracingLevelUpdate.levels=none

# Includes Excludes for each level
# Use this property to include specific processes to get their Logging levels updated 
# Use relative path reference starting from $basedir or use Ant pattern expressions.
# This property is required when migrate.processObjects.enabled=true is set

ipd.migrate.processes.tracingLevelUpdate.none.includes=**/*.PROCESS.xml
ipd.migrate.processes.tracingLevelUpdate.none.excludes=

ipd.migrate.processes.tracingLevelUpdate.terse.includes=nothing
ipd.migrate.processes.tracingLevelUpdate.terse.excludes=**/*.xml

ipd.migrate.processes.tracingLevelUpdate.normal.includes=nothing
ipd.migrate.processes.tracingLevelUpdate.normal.excludes=**/*.xml

ipd.migrate.processes.tracingLevelUpdate.verbose.includes=nothing
ipd.migrate.processes.tracingLevelUpdate.verbose.excludes=**/*.xml


# SET Process Suspend On fault
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.tracingLevelUpdate.execute=true

# includes/excludes for processes to enable suspendOnFault
ipd.migrate.processes.suspendOnFault.true.execute=true
ipd.migrate.processes.suspendOnFault.true.includes=**/*.PROCESS.xml
ipd.migrate.processes.suspendOnFault.true.excludes=
 
# includes/excludes for processes to disable suspendOnFault
ipd.migrate.processes.suspendOnFault.false.execute=true
ipd.migrate.processes.suspendOnFault.false.includes=none
ipd.migrate.processes.suspendOnFault.false.excludes=**/*.PROCESS.xml



# SET Allowed Consumers
# -----------------------
# Set this property to Enable/Disable Transform Step
# includes/excludes for processes to set Allowed Consumers
ipd.migrate.processes.setAllowedConsumers.execute=true
ipd.migrate.processes.setAllowedConsumers.includes=**/*.PROCESS.xml
ipd.migrate.processes.setAllowedConsumers.excludes=none

ipd.process.allowedUsersMap=../sample-data/test-configs/user-map.xml
ipd.process.allowedGroupsMap=../sample-data/test-configs/group-map.xml

# SET Tags
# -----------------------
# remove Specific tags based on pattern
ipd.migrate.removeTags=false
ipd.tags.remove.include=**/*.xml
ipd.tags.remove.exclude=
ipd.tags.remove.tagMatchPattern=(,)?(GIT:\w+)

# ADD Design Tags
ipd.migrate.addTags=true
ipd.tags.add.include=**/*.xml
ipd.tags.add.exclude=
ipd.tags.add.tags=TEST,for migration,version: 1.0 

## Apply Version Update to Selected CAI designs
ipd.migrate.updateVersions=true
# Include files
ipd.update.version.include=**/**.xml
# Exclude files
ipd.update.version.exclude=**/**.xml
# you can exclude specified files from 
ipd.update.version.label=1.0


# Sort Connectors
# -----------------------
ipd.migrate.processes.sortConnectors.execute=true
ipd.sortConnectors.include=**/*.AI_SERVICE_CONNECTOR.xml
ipd.sortConnectors.exclude=

```

## Invoking transform from Main Build Script of Your IICS component Build

Following is an example snippet how this transformation can be called from main Build Script.

### Key properties to drive invocation of transform Target

| Property                      | Description                                                                                     | Example Value                                     |
|-------------------------------|-------------------------------------------------------------------------------------------------|---------------------------------------------------|
| iics.release                  | Path to release configuration file                                                              | `./conf/iclab-dev.release.properties`             |
| transform.source.dir          | Path to transformation Source Directory with IPD designs                                        | `./target/transform/src`                          |
| transform.target.dir          | Path to Temp target directory used to transformation output                                     | `./target/transform/temp`                         |
| migration.properties.base     | Path to directory where Transformation Configuration files are stored, used in interactive mode | `/users/jbrazda/iics`                             |
| iics.package.transform.config | Path to Selected Transformation Properties file                                                 | `AlertServices_PennyMac_dev.transform.properties` |

### Example Target Implementation in Main Build

```xml
<target name="iics.prepare.package"
    unless="${tools.transform.disabled}"
    depends="-env.info,-select-release,-load.release.properties,install.tools.transform">
    <property name="transform.src.folder" location="${basedir}/target/transform/src"></property>
    <property name="transform.temp.folder" location="${basedir}/target/transform/temp"></property>
    <echo level="info">Copying Sources from ${iics.extract.dir} to ${transform.src.folder}</echo>
    <delete dir="${transform.src.folder}"/>
    <copy todir="${transform.src.folder}" overwrite="true" verbose="true">
        <fileset dir="${iics.extract.dir}">
        </fileset>
    </copy>
    <ant antfile="${tools.package.transform}" target="transform" inheritall="false" inheritrefs="false">
        <property name="iics.release" value="${iics.release.basename}"/>
        <property name="transform.source.dir" location="${transform.src.folder}"/>
        <property name="transform.target.dir" location="${transform.temp.folder}"/>
        <property name="migration.properties.base" value="${iics.external.properties.dir}"/>
    </ant>
</target>
```

## Set Process Suspend On Fault Deployment Attributes

"Suspend on Fault" is advanced ICAI Process engine feature used in certain types of process
to suspend process execution when process unexpectedly faults. This allows to retry failed invoke
or resume process. Read more about [Suspend On Fault][suspend_on_fault] feature.
This transformation allows to bulk change this IPD process parameter when necessary,
for example in test environments processes are left to fault on unexpected errors but in production
they might be set to suspend on Fault which allows longer time to inspect them for root cause of
failure or take corrective actions manually and resume process to running state.
Successful resuming might also need elevated [persistence level][persistence_level].  

## Suspend On Fault XSLT

[xsl/set_service_suspendOnFault.xsl](xsl/set_service_suspendOnFault.xsl)

### Parameters

| Parameter      | Values     |
|----------------|------------|
| suspendOnFault | true/false |

### Example use in Ant

```xml
<target name="test-set-suspendOnFault" depends="-init,-env.info">
    <property name="transform.source.dir" location="${basedir}/sample-data/src"/>
    <property name="transform.target.dir" location="${basedir}/target/test-set-suspendOnFault"/>
    <property name="service.suspendOnFault" value="true"/>

    <mkdir dir="${transform.target.dir}"/>
    <xslt style="${xsl.scripts.base}/set_service_suspendOnFault.xsl"
        basedir="${transform.source.dir}"
        destdir="${transform.target.dir}"
        includes="**/*.pd.xml,**/*.PROCESS.xml"
        extension=".xml"
        force="true"
        classpathref="tools.classpath">
        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
        <param name="suspendOnFault" expression="${service.suspendOnFault}"/>
    </xslt>
</target>
```

## Set Process Tracing Level Attribute

Select a Tracing Level from this list to determine the corresponding persistence and
logging level settings: None, Terse, Normal, Verbose. See the table below for more information.
The Tracing Level of a process implemented using Process Designer couples the [Persistence][persistence_level] and
[Logging levels][logging_level] that are handled separately by Process Developer.

| Tracing Level | Persistence Level | Logging Level               |
|---------------|-------------------|-----------------------------|
| None          | Brief             | None                        |
| Terse         | Brief             | Fault                       |
| Normal        | Brief             | Execution with Service Data |
| Verbose       | Final             | Execution with Data         |

### XSLT Set Tracing Level

### Parameters

| Parameter    | Values                       |
|--------------|------------------------------|
| tracingLevel | none, terse, normal, verbose |

[xsl/set_service_tracingLevel.xsl](xsl/set_service_tracingLevel.xsl)

### Example use in Ant

```xml
<target name="test-set-tracingLevel" depends="-init">
    <property name="transform.source.dir" location="${basedir}/sample-data/src"/>
    <property name="transform.target.dir" location="${basedir}/target/test-set-tracingLevel"/>
    <property name="service.tracingLevel" value="none"/>
    <mkdir dir="${transform.target.dir}"/>
    <xslt style="${xsl.scripts.base}/set_service_tracingLevel.xsl"
        basedir="${transform.source.dir}"
        destdir="${transform.target.dir}"
        includes="**/*.pd.xml,**/*.PROCESS.xml"
        extension=".xml"
        force="true"
        classpathref="tools.classpath">
        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
        <param name="tracingLevel" expression="${service.tracingLevel}"/>
    </xslt>
</target>
```

## Setting Run On Parameter of the Process

One of the key parameters of the Process design is "Run On" which defines where process
would be deployed  on "Publish". You can choose Cloud Server, specific agent or agent group.
If your process uses a connector that is event based, make sure
that you run the process on the same agent that the connector runs on.

This Tool provides two targets to manage `Run On` Parameter:

## Move Process to different agent or group

| Parameter      | Values                           |
|----------------|----------------------------------|
| targetLocation | Name of the Agent or Agent Group |

[xsl/move_service_to_agent.xsl](xsl/move_service_to_agent.xsl)

### Example Use in Ant

```xml
<target name="test-move-to-agent" depends="-init,-env.info">
    <property name="transform.source.dir" location="${basedir}/sample-data/src"/>
    <property name="transform.target.dir" location="${basedir}/target/test-move-to-agent"/>
    <property name="targetLocation" value="TEST_1"/>
    <mkdir dir="${transform.target.dir}"/>
    <xslt style="${xsl.scripts.base}/move_service_to_agent.xsl"
        basedir="${transform.source.dir}"
        destdir="${transform.target.dir}"
        includes="**/*.pd.xml,**/*.PROCESS.xml"
        extension=".xml"
        force="true"
        classpathref="tools.classpath">
        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
        <param name="targetLocation" expression="${targetLocation}"/>
    </xslt>
</target>
```

## Move Process from Secure Agent or agent deployment group to Cloud

XSLT - This Script does not have parameters

[xsl/move_service_to_cloud.xsl](xsl/move_service_to_cloud.xsl)

### Example Use in Ant

```xml
<target name="test-move-to-cloud" depends="-init">
    <property name="transform.source.dir" location="${basedir}/sample-data/src"/>
    <property name="transform.target.dir" location="${basedir}/target/test-move-to-cloud"/>
    <mkdir dir="${transform.target.dir}"/>
    <xslt style="${xsl.scripts.base}/move_service_to_cloud.xsl"
        basedir="${transform.source.dir}"
        destdir="${transform.target.dir}"
        includes="**/*.pd.xml,**/*.PROCESS.xml"
        extension=".xml"
        force="true"
        classpathref="tools.classpath">
        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
    </xslt>
</target>
```

## Sort Connectors Transformation

This script allows to sort Connectors. This is very useful to make connectors easier to maintain and make more consistent as IICS Connector editor does not support sorting of Actions, Process Objects and their attributes alphabetically which make it difficult to work with large connectors.

### Example Allowed Groups Mapping File

```xml
<target name="test-sort-connectors" depends="-init">
    <property name="transform.source.dir" location="${basedir}/sample-data/src"/>
    <mkdir dir="${basedir}/target/test-sortConnectors"/>        
    <xslt style="${xsl.scripts.base}/sort-connector-design.xsl" 
        basedir="${transform.source.dir}" 
        destdir="${basedir}/target/test-sortConnectors"
        includes="**/*.AI_SERVICE_CONNECTOR.xml"
        extension=".xml"
        force="true"
        classpathref="tools.classpath">
        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
    </xslt>
    <echo level="info">TEST - Sort Connectors Completed</echo>
</target>
```

## Set Allowed Groups on  Process Designs

This Transform script allows setting of the allowed groups and allowed groups of the Process, this can be used to update such attributes in bulk during a build process.

This script is using a custom mapping files to map `allowedGroups` and `allowedUsers` attributes of the Process. These attributes control permissions to invoke the process

### Parameters

| Parameter | Values                           |
| --------- | -------------------------------- |
| groupMap  | Groups Mapping file location URI |
| usersMap  | Users Mapping file location URI  |

### Example Allowed Groups Mapping File

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Map>
    <Group Name="Administrator">
        <process>SecureAgentMonitor</process>
        <process>UncaughtFaultAlertHandler-G01</process>
        <process>SCH-SecureAgentMonitor</process>
    </Group>
    <Group Name="Service Account">
        <process>SecureAgentMonitor</process>
        <process>UncaughtFaultAlertHandler-G01</process>
        <process>SCH-SecureAgentMonitor</process>
    </Group>
    <Group Name="Sevice Consumer">
        <process>UncaughtFaultAlertHandler-Cloud</process>
    </Group>
</Map>
```

### Example Allowed Users Mapping File

> Note: You should generally prefer to use only groups as the user ids typically differ and are too granular for setting access to services.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Map>
    <User Name="test_user_1@acme.com">
        <process>SecureAgentMonitor</process>
        <process>UncaughtFaultAlertHandler-G01</process>
        <process>SCH-SecureAgentMonitor</process>
    </User>
    <User Name="test_user_2@acme.com">
        <process>SecureAgentMonitor</process>
        <process>UncaughtFaultAlertHandler-G01</process>
        <process>SCH-SecureAgentMonitor</process>
    </User>
    <User Name="test_user_2@acme.com">
        <process>UncaughtFaultAlertHandler-Cloud</process>
    </User>
</Map>
```

### Example Use in Ant

```xml
<target name="test-set-allowedConsumers-mapped" depends="-init">
    <property name="transform.source.dir" location="${basedir}/sample-data/src"/>
    <property name="service.allowedGroupsMap" value="file:/C:/Users/NCVJ9B/git/github/icai-migration-tools/sample-data/test-configs/group-map.xml"/>
    <property name="service.allowedUsersMap" value="file:/C:/Users/NCVJ9B/git/github/icai-migration-tools/sample-data/test-configs/user-map.xml"/>
    <mkdir dir="${basedir}/target/test-set-allowedConsumers"/>        
    <xslt style="${xsl.scripts.base}/set_service_allowedConsumers_mapped.xsl" 
        basedir="${transform.source.dir}" 
        destdir="${basedir}/target/test-set-allowedConsumers"
        includes="**/*.PROCESS.xml"
        extension=".xml"
        force="true"
        classpathref="tools.classpath">
        <factory name="net.sf.saxon.TransformerFactoryImpl"/>
        <param name="groupMap" expression="${service.allowedGroupsMap}"/>
        <param name="usersMap" expression="${service.allowedUsersMap}"/>
    </xslt>
    <echo level="info">TEST - Set Allowed Consumers Completed</echo>
</target>
```

## Licenses anf Credits

This Tool uses Saxon HE and Ant Contrib libraries

- Saxon HE is licensed under [Mozilla Public License Version 2.0](https://www.mozilla.org/en-US/MPL/2.0/)
- Ant Contrib is licensed under [Apache License Version 2.0](lib/ant-contrib-LICENSE)

[suspend_on_fault]: https://network.informatica.com/onlinehelp/activevos/current/index.htm#page/bb-av-designer/Suspending_a_Process_on_Uncaught_Faults.html
[persistence_level]: https://docs.informatica.com/process-automation/informatica-activevos/current-version/5-----administration-console/catalog--reports--and-custom-faults/viewing-process-definitions/process-version-persistence-type.html
[logging_level]: https://docs.informatica.com/process-automation/informatica-activevos/current-version/5-----administration-console/catalog--reports--and-custom-faults/viewing-process-definitions/logging-level.html
