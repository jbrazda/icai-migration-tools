# Informatica IICS-CAI Migration Tools

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

### Example Transformation Configuration

transformation property file should have an extension `transform.properties` as the script can prompt for list of
pre configured transformation properties when the file property is not set. Follow example naming convention in
the form of `PackageName_customer_environment.transform.properties` i.e. `AlertServices_iclab_dev.transform.properties`

```properties

# MOVE Process to Cloud
# ---------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.to.cloud.enabled=false
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
ipd.migrate.processes.to.agent.name=DEMO
# Use this property to include specific processes or use Ant pattern expressions.
# This property is required when migrate.processObjects.enabled=true is set
# ipd.migrate.processes.to.agent.include=Explore/Tools/Processes/SP-Shell-CMD.PROCESS.xml
ipd.migrate.processes.to.agent.include=**/*NA.PROCESS.xml
# you can exclude specified files from
ipd.migrate.processes.to.agent.exclude=**/SCH-*.PROCESS.xml


# SET Process Tracing Levels
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.tracingLevelUpdate.enabled=true

# List of tracing levels to be processed
# this is an example to process all levels when you want to set levels on any selected processes
# ipd.migrate.processes.tracingLevelUpdate.levels=none,terse,normal,verbose
# note that each supported tracing level must have incudes/excludes defined
# Following example setting will set  all processes tracing level to None
ipd.migrate.processes.tracingLevelUpdate.levels=verbose

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

ipd.migrate.processes.tracingLevelUpdate.verbose.includes=**/*.PROCESS.xml
ipd.migrate.processes.tracingLevelUpdate.verbose.excludes=nothing


# SET Process Suspend On fault
# -----------------------
# Set this property to Enable/Disable Transform Step
ipd.migrate.processes.tracingLevelUpdate.execute=false

#includes/excludes for processes to enable suspendOnFault
ipd.migrate.processes.suspendOnFault.true.execute=true
ipd.migrate.processes.suspendOnFault.true.includes=**/*.PROCESS.xml
ipd.migrate.processes.suspendOnFault.true.excludes=

#includes/excludes for processes to disable suspendOnFault
ipd.migrate.processes.suspendOnFault.false.execute=true
ipd.migrate.processes.suspendOnFault.false.includes=none
ipd.migrate.processes.suspendOnFault.false.excludes=**/*.PROCESS.xml

#remove Specific tags based on pattern
ipd.migrate.removeTags=false
ipd.tags.remove.include=**/*.xml
ipd.tags.remove.exclude=
ipd.tags.remove.tagMatchPattern=(,)?(GIT:\w+)
```

### Invoking transform from Main Build Script of Your IICS component Build

Following is an example snippet how this transformation can be called from main Build Script.

#### Key properties to drive invocation of transform Target

| Property                      | Description                                                                                     | Example Value                                     |
|-------------------------------|-------------------------------------------------------------------------------------------------|---------------------------------------------------|
| iics.release                  | Path to release configuration file                                                              | `./conf/iclab-dev.release.properties`             |
| transform.source.dir          | Path to transformation Source Directory with IPD designs                                        | `./target/transform/src`                          |
| transform.target.dir          | Path to Temp target directory used to transformation output                                     | `./target/transform/temp`                         |
| migration.properties.base     | Path to directory where Transformation Configuration files are stored, used in interactive mode | `/users/jbrazda/iics`                             |
| iics.package.transform.config | Path to Selected Transformation Properties file                                                 | `AlertServices_PennyMac_dev.transform.properties` |

#### Example Target Implementation in Main Build

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

### Suspend On Fault XSLT

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

## Example use in Ant

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

### Move Process to different agent or group

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

### Move Process from Secure Agent or agent deployment group to Cloud

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

[suspend_on_fault]: https://network.informatica.com/onlinehelp/activevos/current/index.htm#page/bb-av-designer/Suspending_a_Process_on_Uncaught_Faults.html
[persistence_level]: https://docs.informatica.com/process-automation/informatica-activevos/current-version/5-----administration-console/catalog--reports--and-custom-faults/viewing-process-definitions/process-version-persistence-type.html
[logging_level]: https://docs.informatica.com/process-automation/informatica-activevos/current-version/5-----administration-console/catalog--reports--and-custom-faults/viewing-process-definitions/logging-level.html
