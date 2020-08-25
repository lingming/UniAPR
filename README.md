# UniAPR: Fast and Precise On-the-fly Patch Validation for All

## Table of Contents
- [Introduction](#introduction)
- [UniAPR Setup](#uniapr-setup)
    * [Fine Tuning UniAPR](#fine-tuning-uniapr)
- [UniAPR Demonstration](#uniapr-demonstration)
- [System Requirements](#system-requirements)

## Introduction
UniAPR is an efficient patch validation framework. Upon this framework, different automatic program repair (APR) techniques can be installed as patch generation add-ons. This has a couple of immediate benefits: (1) one can take advantage of the power of different APR technique each of which is good in handling different kind of bugs; (2) APR research community can focus on developing more and more sophisticated patch generation mechanisms without worrying about the cost of patch validation which dominates end-to-end program repair time.

This repository contains executables for UniAPR together with an example so that the reviewers of our paper can try the system on a number of real-world projects.

## UniAPR Setup
Please follow these steps to setup UniAPR:

:one: Before checking out and installing the program, please make sure you have all the [required software](#system-requirements) installed on your computer. In order to checkout the project, the user can invoke the following command in a terminal window.

```shell script
git clone https://github.com/Selab2020/UniAPR.git
```

:two: You will need to install UniAPR on your computer before being able to use it. We have provided the users with a shell script so that they can install the JAR file on their local Maven repository. Please run the following commands to install UniAPR Maven plugin on your local Maven repository.

```
cd UniAPR
./install
```

Having installed UniAPR on the local repository, the users can invoke the plugin by configuring the POM file of the target project. The following XML snippet shows the minimum configuration needed for applying UniAPR with its default setting.

```xml
<plugin>
    <groupId>org.uniapr</groupId>
    <artifactId>uniapr-plugin</artifactId>
    <version>1.0-SNAPSHOT</version>
</plugin>
```

The users only need to add this XML snippet in the `<plugins>` section under the `<build>` tag in the POM file of the target project. After adding this, UniAPR can be invoked simply by running the following command.

```shell script
mvn org.uniapr:uniapr-plugin:validate
```

By default, UniAPR expects a directory name `patches-pool` under the base directory of the target project. This directory is expected to contain a sub-directory for each patch inside each of which the class file(s) for the corresponding patch should reside. If everything goes well, the user will see a `BUILD SUCCESS` message on their screen. Above this message, UniAPR will print a brief summary of its output, e.g., the time taken to validate patches and the number of plausible patches found. The id of the plausible patch(es) shall also be printed as they are discovered. Therefore, the user might want to log the standard output for examination.

### Fine Tuning UniAPR
The user can override default values of UniAPR parameters by adding a `<configuration>` tag under the tag corresponding to UniAPR plugin. The following XML snippet shows the full form of plugin specification. Optional parameters, with their default values, are shown in comments. Please note that for ease of reference, we have marked each section so that in the rest of this section, we can explain each section in greater detail.

```xml
<plugin>
    <groupId>org.uniapr</groupId>
    <artifactId>uniapr-plugin</artifactId>
    <version>1.0-SNAPSHOT</version>
    <!-- <configuration>                                                            -->
    (1)   <!-- <failingTests>                                                       -->
          <!--  <failingTest>fully.qualified.test.Class1::testMethod1</failingTest> -->
          <!--    ...                                                               -->
          <!--  <failingTest>fully.qualified.test.ClassN::testMethodN</failingTest> -->
          <!-- </failingTests>                                                      -->

    (2)   <!-- <whiteListPrefix>${project.groupId}</whiteListPrefix>                -->
    
    (3)   <!-- <patchesPool>patches-pool</patchesPool>                              -->

    (4)   <!-- <resetJVM>false</resetJVM>                                           -->
        
    (5)   <!-- <childJVMArgs>                                                       -->
          <!--  <childJVMArg>-Xmx16g</childJVMArg>                                  -->
          <!--  ...                                                                 -->
          <!--  <childJVMArg>Mth argument to the child JVM</childJVMArg>            -->
          <!-- </childJVMArgs>                                                      -->
    <!-- </configuration>                                                           -->
</plugin>
```

UniAPR needs to know the list of failing tests so as to run them before regression tests. The system is able to infer the test cases if the user leaves them blank, but for some projects, due to some dependency issues that show up only in certain scenarios, the user might need to manually specify them in the POM file. In such a case, the fully qualified name of the failing tests should be provided in `<failingTests>` section (the part marked with (1) in the above snippet).

For profiling purposes, as well as to locate test cases, the system needs to distinguish application classes from library classes. We assume that user classes all begin with certain class name prefix. Class name prefix can be specified via the parameter `<whiteListPrefix>` (the part marked with (2) in the above snippet). By default, groupId of the project will be used as a whitelist prefix.

UniAPR expects that the user has the class files for the patches bundled inside a directory under the base directory of the target project. The directory is expected to have a separate subdirectory for each patch. The class file(s) for each patch resides within the subdirectory corresponding to the patch. By default, UniAPR looks for the directory named `patches-pool` under the base directory. The user can choose to use a different directory by changing the value of the parameter `<patchesPool>`. (the part marked with (3) in the above snippet)

JVM-reset capability of UniAPR can be controlled by the user. The user can use the parameter `<resetJVM>` (the part marked with (4) in the above snippet) to enable or disable JVM-reset functionality of UniAPR. When disabled no JVM state clean up will happen between each patch validation session, and thus the side-effects of test case executions might propagate from one patch to another. In this mode of operation, since there is no instrumentation and no added overhead of invoking reset code is in place, UniAPR will run with maximum speed. However, since the side-effects of test cases are not contained, chances are that UniAPR reports imprecise results.

Last but not least, since some patches might need more heap/stack space to run, we have provided the user with a way of setting JVM parameters from the POM file. This can be specified in the part marked by (5) in the above snippet.

## UniAPR Demonstration
Since the reviewers might not have any bugs available, we have shipped a real-world example project from [Defects4J](https://github.com/rjust/defects4j) bug database. The project is already compiled and come with a preconfigured POM file as well.

### Example: Bugs fixed by CapGen
[CapGen](https://github.com/justinwm/CapGen) is a source code level APR system belonging to the family of mutation-/template-based APR techniques. This repository contains a sample Defects4J bug drawn from our experiments: we have applied our CapGen add-on to generate patches for Lang-6. The preconfigured bugs fixed by CapGen are located under `example/Lang-6`. In order to apply UniAPR on the bug example, the user first needs to navigate to the desired bug folder and then invoke Maven.

```
cd example/Lang-6
mvn org.uniapr:uniapr-plugin:validate -Dhttps.protocols=TLSv1.2
```

Please note that since Defects4J bugs are only compatible with JDK 1.7, we will need to include the extra switch `-Dhttps.protocols=TLSv1.2` when invoking Maven. This is to satisfy a security requirement in place since June 2018.

Running UniAPR without JVM-reset feature activated will result in UniAPR failing to find the plausible patch. This is due to the fact that test case execution side-effects are being propagated from one patch validation session to another (as UniAPR strives to do all patch validations in the same process as long as it is possible). To mitigate this, the user wants to activate JVM-reset feature. In order to run UniAPR with JVM-reset feature activated, the user can either modify the POM file and invoke UniAPR as before, or simply try the following command.

```shell script
mvn org.uniapr:uniapr-plugin:validate -Dhttps.protocols=TLSv1.2 -DresetJVM=true
```

## System Requirements
* Git: version control system.
* OS: Ubuntu Linux or Mac OS X.
* Build System: Maven 3+.
* JDK: Oracle Java SE Development Kit 7u80 (recommended for Defects4J).


