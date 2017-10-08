package org.abuild.groovy

import org.abuild.groovy.Util
import org.abuild.groovy.ParameterHelper
import org.abuild.javabuilder.GroovyBackend
import org.codehaus.groovy.control.CompilationFailedException
import org.abuild.javabuilder.BuildArgs
import org.apache.tools.ant.Project
import org.abuild.QTC

class Backend implements GroovyBackend
{
    File buildDirectory
    BuildArgs buildArgs
    def targets

    def loader = new GroovyClassLoader()
    static Map<File, Class> classCache = [:]

    private BuildState buildState
    private AntBuilder ant
    private Closure parameters

    boolean run(File buildDirectory, BuildArgs buildArgs, Project antProject,
		List<String> targets, Map<String, String> defines)
    {
        this.buildDirectory = buildDirectory
        this.buildArgs = buildArgs
        this.targets = targets

        this.ant = new AntBuilder(antProject)
        this.buildState = new BuildState(
            ant, buildDirectory, buildArgs, defines)
        this.parameters = ParameterHelper.createClosure(this.buildState)

        boolean status = false
        try
        {
            status = build()
        }
        catch (Exception e)
        {
            QTC.TC("abuild", "groovy ERR exception during build")
            String message = e.message
            if ((System.getenv("IN_TESTSUITE") != null) &&
                    (e instanceof CompilationFailedException))
            {
                message = "--COMPILATION ERRORS SUPPRESSED--\n"
            }
            System.err.print "Exception caught during build: " + message
            Util.printStackTrace(e)
        }

        status
    }

    Binding getBinding()
    {
        def b = new Binding()

        b.abuild = this.buildState
        b.ant = this.ant
        b.parameters = this.parameters

        b
    }

    boolean build()
    {
        // The logic here strongly parallels abuild's "make" logic.

        def dynamicFile = new File(buildDirectory.path + "/.ab-dynamic.groovy")
        loadScript(dynamicFile)

        def groovyTop = buildState.abuildTop + "/groovy"
        loadScript(groovyTop + "/global.groovy")

        loadScript(groovyTop + "/qtest.groovy")
        def targetType = buildState.interfaceVars['ABUILD_TARGET_TYPE']
        loadScript(buildState.abuildTop + "/rules/${targetType}/_base.groovy")

        // Load pre-plugin initialization code
        buildState.pluginPaths.each {
            File f = new File("${it}/preplugin.groovy")
            if (f.isFile())
            {
                loadScript(f)
            }
        }

        // Load user's build file
        def sourceDirectory = buildDirectory.parentFile
        def buildFile = new File(sourceDirectory.path + "/Abuild.groovy")
        loadScript(buildFile)

        // Load plugin code
        buildState.pluginPaths.each {
            File f = new File("${it}/plugin.groovy")
            if (f.isFile())
            {
                loadScript(f)
            }
        }

        if (! (buildState.params['abuild.rules'] ||
               buildState.params['abuild.localRules']))
        {
            QTC.TC("abuild", "groovy ERR no rules")
            buildState.error(
                "no build rules are defined; one of abuild.rules or" +
                " abuild.localRules must be defined")
            return false
        }

        // Load any rules specified in params['abuild.rules'].  First
        // search the internal location, and then search in each
        // plugin directory, returning the first item found.
        buildState.resolveAsList('abuild.rules')?.each {
            rule ->
            def found = false
            for (dir in buildState.rulePaths)
            {
                File f = new File("${dir}/${rule}.groovy")
                if (f.isFile())
                {
                    loadScript(f)
                    found = true
                    break
                }
            }
            if (! found)
            {
                buildState.error("unable to find rule \"${rule}\"")
            }
        }

        // Load any local rules files, resolving the path relative to
        // the source directory
        buildState.resolveAsList('abuild.localRules')?.each {
            loadScript(new File("${sourceDirectory.path}/${it}"))
        }

        if (! buildState.checkGraph())
        {
            return false
        }

        boolean status = true
        if (! buildState.anyFailures)
        {
            status = this.buildState.runTargets(this.targets)
        }
        if (buildState.anyFailures)
        {
            status = false
        }
        status
    }

    private loadScript(String filename)
    {
        loadScript(new File(filename))
    }

    private loadScript(File file)
    {
        if (buildArgs.verbose)
        {
            println "--> loading ${file.path}"
        }
        try
        {
            Class groovyClass = parseClass(file)
            if (groovyClass)
            {
                GroovyObject groovyObject = groovyClass.newInstance()
                buildState.curFile = file
                runScript(file, groovyObject)
                buildState.curFile = null
            }
        }
        catch (CompilationFailedException e)
        {
            QTC.TC("abuild", "groovy ERR script compilation errors")
            buildState.error("file ${file.path} had compilation errors")
            throw e
        }
    }

    private parseClass(File file)
    {
        Class c
        synchronized (this.classCache)
        {
            if (! this.classCache.containsKey(file))
            {
                this.classCache[file] = this.loader.parseClass(file)
            }
            c = this.classCache[file]
        }
        c
    }

    private runScript(file, object)
    {
        object.setBinding(binding)
        try
        {
            object.run()
        }
        catch (BuildFailure e)
        {
            QTC.TC("abuild", "groovy ERR script run exception")
            buildState.error("build failure in ${file}: " + e.message)
            if (buildArgs.verbose)
            {
                Util.printStackTrace(e)
            }
        }
        catch (Exception e)
        {
            buildState.error("file ${file} threw exception: " + e.message)
            throw e
        }
    }
}
