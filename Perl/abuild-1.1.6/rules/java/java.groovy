import org.abuild.groovy.Util

//
// NOTE: when modifying this file, you must keep java-help.txt up to
// date!
//

class JavaRules
{
    def abuild
    def ant
    def pathSep

    List<String> defaultCompileClassPath = []
    List<String> defaultManifestClassPath = []
    List<String> defaultPackageClassPath = []
    List<String> defaultWrapperClassPath = []

    JavaRules(abuild, ant)
    {
        this.abuild = abuild
        this.ant = ant
        this.pathSep = ant.project.properties['path.separator']
    }

    def getPathVariable(String var)
    {
        String result = abuild.resolveAsString("java.dir.${var}")
        if (! new File(result).isAbsolute())
        {
            result = new File(abuild.sourceDirectory, result)
        }
        // Wrap this in a file object and call absolutePath so
        // paths are formatted appropriately for the operating
        // system.
        new File(result).absolutePath
    }

    def getPathListVariable(String var)
    {
        abuild.resolveAsList("java.dir.${var}").collect {
            if (new File(it).isAbsolute())
            {
                new File(it).absolutePath
            }
            else
            {
                new File(abuild.sourceDirectory, it).absolutePath
            }
        }
    }

    def getArchiveAttributes()
    {
        [
            'distdir': getPathVariable('dist'),
            'classesdir': getPathVariable('classes'),
            'resourcesdirs': [getPathVariable('resources'),
                              getPathVariable('generatedResources')],
            'extraresourcesdirs' : getPathListVariable('extraResources'),
            'metainfdirs' : [getPathVariable('metainf'),
                             getPathVariable('generatedMetainf')],
            'extrametainfdirs' : getPathListVariable('extraMetainf'),
            'extramanifestkeys' : [:]
        ]
    }

    def initTarget()
    {
        // We have three classpath interface variables that we combine
        // in various ways to initialize our various classpath
        // variables here.  See java_help.txt for details.

        defaultCompileClassPath.addAll(
            abuild.resolve('abuild.classpath') ?: [])
        defaultCompileClassPath.addAll(
            abuild.resolve('abuild.classpath.external') ?: [])

        defaultManifestClassPath.addAll(
            abuild.resolve('abuild.classpath.manifest') ?: [])

        defaultPackageClassPath.addAll(
            abuild.resolve('abuild.classpath') ?: [])

        defaultWrapperClassPath.addAll(defaultCompileClassPath)

        // Filter out jars built by this build item from the compile
        // and manifest classpaths.
        def dist = getPathVariable('dist')
        defaultCompileClassPath = defaultCompileClassPath.grep {
            new File(it).parent != dist
        }
        defaultManifestClassPath = defaultManifestClassPath.grep {
            new File(it).parent != dist
        }
    }

    def compile(Map attributes)
    {
        def srcdirs = attributes.remove('srcdirs')
        srcdirs.addAll(attributes.remove('extrasrcdirs'))

        srcdirs = srcdirs.grep { dir -> new File(dir).isDirectory() }
        if (! srcdirs)
        {
            return
        }

        // Remove attributes that are handled specially
        def compileClassPath = attributes.remove('classpath')
        def includes = attributes.remove('includes')
        def excludes = attributes.remove('excludes')
        def compilerargs = attributes.remove('compilerargs')

        def javacAttrs = attributes
        javacAttrs['classpath'] = compileClassPath.join(pathSep)
        ant.mkdir('dir' : attributes['destdir'])
        ant.javac(javacAttrs) {
            srcdirs.each { dir -> src('path' : dir) }
            compilerargs?.each { arg -> compilerarg('value' : arg) }
            includes?.each { include('name' : it) }
            excludes?.each { exclude('name' : it) }
        }
    }

    def compileTarget()
    {
        def defaultAttrs = [
            'srcdirs': ['src', 'generatedSrc'].collect {getPathVariable(it) },
            'extrasrcdirs' : getPathListVariable('extraSrc'),
            'destdir': getPathVariable('classes'),
            'classpath': this.defaultCompileClassPath,
            // Would be nice to turn path warnings back on
            'compilerargs': ['-Xlint', '-Xlint:-path'],
            'debug': 'true',
            'deprecation': 'on',
            'includeantruntime':
                abuild.resolveAsString('java.includeAntRuntime')
        ]
        abuild.runActions('java.compile', this.&compile, defaultAttrs)
    }

    def packageJarGeneral(Map attributes, String namekey)
    {
        // Remove keys that we will handle expicitly
        def jarname = attributes.remove(namekey)
        if (! jarname)
        {
            return
        }

        def distdir = attributes.remove('distdir')
        def classesdir = attributes.remove('classesdir')
        def resourcesdirs = attributes.remove('resourcesdirs')
        resourcesdirs.addAll(attributes.remove('extraresourcesdirs'))
        def metainfdirs = attributes.remove('metainfdirs')
        metainfdirs.addAll(attributes.remove('extrametainfdirs'))
        def mainclass = attributes.remove('mainclass')
        def manifestClassPath = attributes.remove('manifestclasspath')
        def extramanifestkeys = attributes.remove('extramanifestkeys')
        def filesToPackage = attributes.remove('filestopackage')

        // Take only last path element for each manifest class path
        manifestClassPath = manifestClassPath.collect { new File(it).name }

        // Filter out non-existent directories
        def filesets = [classesdir, resourcesdirs].flatten().grep {
            new File(it).isDirectory()
        }
        metainfdirs = metainfdirs.grep {
            new File(it).isDirectory()
        }

        ant.mkdir('dir' : distdir)
        def jarAttrs = attributes
        jarAttrs['destfile'] = "${distdir}/${jarname}"
        ant.jar(jarAttrs) {
            metainfdirs.each { metainf('dir': it) }
            filesets.each { fileset('dir': it) }
            filesToPackage?.each {
                File f = new File(it)
                if (! f.isAbsolute())
                {
                    f = new File(abuild.sourceDirectory, it)
                }
                if (f.absolutePath !=
                    new File("${distdir}/${jarname}").absolutePath)
                {
                    fileset('file': f.absolutePath)
                }
            }
            manifest {
                if (manifestClassPath)
                {
                    attribute('name' : 'Class-Path',
                              'value' : manifestClassPath.join(' '))
                }
                if (mainclass)
                {
                    attribute('name' : 'Main-Class', 'value' : mainclass)
                }
                extramanifestkeys.each() {
                    key, value -> attribute('name' : key, 'value' : value)
                }
            }
        }
    }

    def packageJar(Map attributes)
    {
        packageJarGeneral(attributes, 'jarname')
    }

    def packageJarTarget()
    {
        def defaultAttrs =
        [
            'jarname': abuild.resolveAsString('java.jarName'),
            'mainclass' : abuild.resolveAsString('java.mainClass'),
            'manifestclasspath' : defaultManifestClassPath,
        ]
        archiveAttributes.each { k, v -> defaultAttrs[k] = v }

        abuild.runActions('java.packageJar', this.&packageJar, defaultAttrs)
    }

    def signJars(Map attributes)
    {
        def alias = attributes.remove('alias')
        def storepass = attributes.remove('storepass')

        if (! (alias && storepass))
        {
            return
        }

        def jarsToSign = attributes.remove('jarstosign')
        def signdir = new File(attributes.remove('signdir'))
        if (! (jarsToSign || signdir.isDirectory()))
        {
            return
        }

        ant.mkdir('dir': signdir)
        jarsToSign.each {
            def src = new File(it)
            if ((src.parent != signdir.absolutePath) &&
                (src.name =~ /(?i:\.jar)$/))
            {
                def dest = new File(signdir, src.name)
                ant.copy('file': src.absolutePath,
                         'tofile': dest.absolutePath)
            }
        }

        def keystore = attributes.remove('keystore')
        def keypass = attributes.remove('keypass')
        if (keystore && (! new File(keystore).absolutePath))
        {
            keystore =
                new File(abuild.sourceDirectory + "/$keystore").absolutePath
        }

        def includes = attributes.remove('includes')
        def signjarAttrs = attributes
        signjarAttrs['alias'] = alias
        signjarAttrs['storepass'] = storepass
        if (keystore)
        {
            signjarAttrs['keystore'] = keystore
        }
        if (keypass)
        {
            signjarAttrs['keypass'] = keypass
        }

        ant.signjar(signjarAttrs) {
            fileset('dir': signdir.absolutePath, 'includes': includes)
        }
    }

    def signJarsTarget()
    {
        def defaultAttrs = [
            'includes': '*.jar',
            'signdir': getPathVariable('signedJars'),
            'jarstosign' : abuild.resolve('java.jarsToSign'),
            'alias': abuild.resolve('java.sign.alias'),
            'storepass': abuild.resolve('java.sign.storepass'),
            'keystore': abuild.resolve('java.sign.keystore'),
            'keypass': abuild.resolve('java.sign.keypass'),
            'lazy': true
        ]

        abuild.runActions('java.signJars', this.&signJars, defaultAttrs)
    }

    def packageHighLevelArchive(Map attributes)
    {
        packageJarGeneral(attributes, 'highlevelarchivename')
    }

    def packageHighLevelArchiveTarget()
    {
        def defaultAttrs = [
            'highlevelarchivename':
                abuild.resolveAsString('java.highLevelArchiveName'),
            'filestopackage' : defaultPackageClassPath,
        ]
        archiveAttributes.each { k, v -> defaultAttrs[k] = v }

        abuild.runActions('java.packageHighLevelArchive',
                          this.&packageHighLevelArchive, defaultAttrs)
    }

    def packageWar(Map attributes)
    {
        // Remove keys that we will handle expicitly
        def warname = attributes.remove('warname')
        def webxml = attributes.remove('webxml')
        if (! (warname && webxml))
        {
            return
        }

        if (! new File(webxml).isAbsolute())
        {
            webxml = new File(abuild.sourceDirectory, webxml).absolutePath
        }

        def distdir = attributes.remove('distdir')
        def resourcesdirs = attributes.remove('resourcesdirs')
        resourcesdirs.addAll(attributes.remove('extraresourcesdirs'))
        resourcesdirs << attributes.remove('classesdir')
        def webdirs = attributes.remove('webdirs')
        webdirs.addAll(attributes.remove('extrawebdirs'))
        webdirs << attributes.remove('signedjars')
        def metainfdirs = attributes.remove('metainfdirs')
        metainfdirs.addAll(attributes.remove('extrametainfdirs'))
        def extramanifestkeys = attributes.remove('extramanifestkeys')
        def webinfdirs = attributes.remove('webinfdirs')
        webinfdirs.addAll(attributes.remove('extrawebinfdirs'))
        def libfiles = attributes.remove('libfiles')
        def filesToPackage = attributes.remove('filestopackage')

        // Filter out non-existent directories
        resourcesdirs = resourcesdirs.grep { new File(it).isDirectory() }
        webdirs = webdirs.grep { new File(it).isDirectory() }
        metainfdirs = metainfdirs.grep { new File(it).isDirectory() }
        webinfdirs = webinfdirs.grep { new File(it).isDirectory() }

        ant.mkdir('dir' : distdir)
        def warAttrs = attributes
        warAttrs['destfile'] = "${distdir}/${warname}"
        warAttrs['webxml'] = webxml
        ant.war(warAttrs) {
            webinfdirs.each { webinf('dir': it) }
            metainfdirs.each { metainf('dir': it) }
            webdirs.each { fileset('dir': it) }
            resourcesdirs.each { classes('dir': it) }
            libfiles.each {
                File f = new File(it)
                if (f.absolutePath !=
                    new File("${distdir}/${warname}").absolutePath)
                {
                    lib('file': f.absolutePath)
                }
            }
            filesToPackage?.each {
                File f = new File(it)
                if (! f.isAbsolute())
                {
                    f = new File(abuild.sourceDirectory, it)
                }
                if (f.absolutePath !=
                    new File("${distdir}/${warname}").absolutePath)
                {
                    fileset('file': f.absolutePath)
                }
            }
            manifest {
                extramanifestkeys.each() {
                    key, value -> attribute('name' : key, 'value' : value)
                }
            }
        }
    }

    def packageWarTarget()
    {
        def defaultAttrs = [
            'warname': abuild.resolveAsString('java.warName'),
            'webxml': abuild.resolveAsString('java.webxml'),
            'webdirs': [getPathVariable('webContent'),
                        getPathVariable('generatedWebContent')],
            'extrawebdirs' : getPathListVariable('extraWebContent'),
            'webinfdirs' : [getPathVariable('webinf'),
                            getPathVariable('generatedWebinf')],
            'extrawebinfdirs' : getPathListVariable('extraWebinf'),
            'signedjars' : getPathVariable('signedJars'),
            'libfiles' : abuild.resolveAsList('java.warLibJars')
        ]
        archiveAttributes.each { k, v -> defaultAttrs[k] = v }

        abuild.runActions('java.packageWar', this.&packageWar, defaultAttrs)
    }

    def packageEar(Map attributes)
    {
        // Remove keys that we will handle expicitly
        def earname = attributes.remove('earname')
        def appxml = attributes.remove('appxml')
        if (! (earname && appxml))
        {
            return
        }
        if (! new File(appxml).isAbsolute())
        {
            appxml = new File(abuild.sourceDirectory, appxml).absolutePath
        }

        def distdir = attributes.remove('distdir')
        def resourcesdirs = attributes.remove('resourcesdirs')
        resourcesdirs.addAll(attributes.remove('extraresourcesdirs'))
        def metainfdirs = attributes.remove('metainfdirs')
        metainfdirs.addAll(attributes.remove('extrametainfdirs'))
        def extramanifestkeys = attributes.remove('extramanifestkeys')
        def filesToPackage = attributes.remove('filestopackage')

        // Filter out non-existent directories
        resourcesdirs = resourcesdirs.grep { new File(it).isDirectory() }
        metainfdirs = metainfdirs.grep { new File(it).isDirectory() }

        ant.mkdir('dir' : distdir)
        def earAttrs = attributes
        earAttrs['destfile'] = "${distdir}/${earname}"
        earAttrs['appxml'] = appxml
        ant.ear(earAttrs) {
            metainfdirs.each { metainf('dir': it) }
            resourcesdirs.each { fileset('dir': it) }
            filesToPackage.each {
                File f = new File(it)
                if (! f.isAbsolute())
                {
                    f = new File(abuild.sourceDirectory, it)
                }
                if (f.absolutePath !=
                    new File("${distdir}/${earname}").absolutePath)
                {
                    fileset('file': f.absolutePath)
                }
            }
            manifest {
                extramanifestkeys.each() {
                    key, value -> attribute('name' : key, 'value' : value)
                }
            }
        }
    }

    def packageEarTarget()
    {
        def defaultAttrs = [
            'earname': abuild.resolveAsString('java.earName'),
            'appxml': abuild.resolveAsString('java.appxml'),
            'filestopackage' : defaultPackageClassPath,
        ]
        archiveAttributes.each { k, v -> defaultAttrs[k] = v }
        defaultAttrs.remove('classesdir')

        abuild.runActions('java.packageEar', this.&packageEar, defaultAttrs)
    }

    def javadoc(Map attributes)
    {
        def srcdirs = attributes.remove('srcdirs')
        srcdirs.addAll(attributes.remove('extrasrcdirs'))
        srcdirs = srcdirs.grep { dir -> new File(dir).isDirectory() }
        if (! srcdirs)
        {
            return
        }

        def javadocAttrs = attributes
        javadocAttrs['sourcepath'] = srcdirs.join(pathSep)
        javadocAttrs['classpath'] = attributes['classpath'].join(pathSep)
        ant.javadoc(javadocAttrs)
    }

    def javadocTarget()
    {
        def title = abuild.resolveAsString('java.javadocTitle')
        // case of Doctitle and Windowtitle are for consistency with
        // ant task
        def defaultAttrs = [
            'Doctitle': title,
            'Windowtitle': title,
            'srcdirs': ['src', 'generatedSrc'].collect {getPathVariable(it) },
            'classpath': this.defaultCompileClassPath,
            'extrasrcdirs': getPathListVariable('extraSrc'),
            'access': abuild.resolveAsString('java.doc.accessLevel',
                                             'protected'),
            'destdir': getPathVariable('generatedDoc')
        ]

        abuild.runActions('java.javadoc', this.&javadoc, defaultAttrs)
    }

    def wrapper(Map attributes)
    {
        def wrapperName = attributes['name']
        def mainClass = attributes['mainclass']
        def jarName = attributes['jarname']
        if (! (wrapperName && mainClass))
        {
            return
        }
        def wrapperDir = attributes['dir']
        def wrapperPath = new File("$wrapperDir/$wrapperName").absolutePath
        def distDir = attributes['distdir']
        def wrapperClassPath = attributes['classpath']
        if (jarName)
        {
            wrapperClassPath << new File("$distDir/$jarName").absolutePath
        }
        wrapperClassPath = wrapperClassPath.join(pathSep)

        // The wrapper script has different contents on Windows and
        // UNIX.  This has the unfortunate side effect of making it
        // impossible to run wrapper scripts in an OS other than the
        // one on which they were generated.  However, since wrapper
        // scripts contain paths to things that may themselves be
        // system dependent, this doesn't really add any new problems.
        // As such, wrapper script generation is done unconditionally,
        // so if you run abuild wrapper on two different systems,
        // they'll each leave behind their own versions of the wrapper
        // script.
        if (Util.inWindows)
        {
            ant.echo('file' : "${wrapperPath}.bat", """@echo off
java -classpath ${wrapperClassPath} ${mainClass} %1 %2 %3 %4 %5 %6 %7 %8 %9
""")
            // In case we're in Cygwin...
            ant.echo('file' : wrapperPath, '''#!/bin/sh
exec `dirname $0`/`basename $0`.bat ${1+"$@"}
''')
        }
        else
        {
            ant.echo('file' : wrapperPath,
                     """#!/bin/sh
exec java -classpath ${wrapperClassPath} ${mainClass} \${1+\"\$@\"}
""")
        }
        ant.chmod('file' : wrapperPath, 'perm' : 'a+x')
    }

    def wrapperTarget()
    {
        def defaultAttrs = [
            'name': abuild.resolveAsString('java.wrapperName'),
            'mainclass': abuild.resolveAsString('java.mainClass'),
            'jarname': abuild.resolveAsString('java.jarName'),
            'dir': abuild.buildDirectory.absolutePath,
            'distdir': getPathVariable('dist'),
            'classpath': defaultWrapperClassPath
        ]

        abuild.runActions('java.wrapper', this.&wrapper, defaultAttrs)
    }

    def testJunit(Map attributes)
    {
        def testsuite = attributes.remove('testsuite')
        def batchIncludes = attributes.remove('batchincludes')
        def batchExcludes = attributes.remove('batchexcludes')
        if (! (testsuite || batchIncludes))
        {
            return
        }
        def distdir = attributes.remove('distdir')
        def classesdir = attributes.remove('classesdir')
        def junitdir = attributes.remove('junitdir')
        def reportdir = attributes.remove('reportdir')
        def testClassPath = attributes.remove('classpath')

        ant.mkdir('dir': junitdir)
        def junitAttrs = attributes
        // Make sure we run junitreport even if junit fails and
        // haltonfailure is set.
        try
        {
            ant.junit(junitAttrs) {
                classpath {
                    testClassPath.each {
                        pathelement('location': it)
                    }
                    fileset('dir': distdir, 'includes': '*.jar')
                }
                if (testsuite)
                {
                    test('name': testsuite,
                         'todir': junitdir) {
                        formatter('type': 'xml')
                    }
                }
                if (batchIncludes)
                {
                    batchtest('todir': junitdir) {
                        fileset('dir': classesdir) {
                            include('name': batchIncludes)
                            if (batchExcludes)
                            {
                                exclude('name': batchExcludes)
                            }
                        }
                        formatter('type': 'xml')
                    }
                }
            }
        }
        finally
        {
            ant.junitreport('todir': junitdir) {
                fileset('dir': junitdir, 'includes':  'TEST-*.xml')
                report('format': 'frames', 'todir': reportdir)
            }
        }
    }

    def testJunitTarget()
    {
        def defaultAttrs = [
            'testsuite': abuild.resolveAsString('java.junitTestsuite'),
            'batchincludes': abuild.resolveAsString('java.junitBatchIncludes'),
            'batchexcludes': abuild.resolveAsString('java.junitBatchExcludes'),
            'classpath': defaultWrapperClassPath,
            'classesdir': getPathVariable('classes'),
            'distdir': getPathVariable('dist'),
            'junitdir': getPathVariable('junit'),
            'reportdir': getPathVariable('junitHtml'),
            'printsummary': 'yes',
            'haltonfailure': 'yes',
            'fork': 'true'
        ]

        abuild.runActions('java.junit', this.&testJunit, defaultAttrs)
    }

}

def javaRules = new JavaRules(abuild, ant)

abuild.addTargetClosure('init', javaRules.&initTarget)
abuild.addTargetClosure('test-junit', javaRules.&testJunitTarget)
abuild.addTargetDependencies('all', ['package', 'wrapper'])
abuild.addTargetDependencies('package', ['package-ear'])
abuild.addTargetDependencies('generate', ['init'])
abuild.addTargetDependencies('doc', ['javadoc'])
abuild.addTargetDependencies('test-only', ['test-junit'])
abuild.configureTarget('compile', 'deps' : ['generate'],
                       javaRules.&compileTarget)
abuild.configureTarget('package-jar', 'deps' : ['compile'],
                       javaRules.&packageJarTarget)
abuild.configureTarget('sign-jars', 'deps' : ['package-jar'],
                       javaRules.&signJarsTarget)
abuild.configureTarget('package-high-level-archive', 'deps' : ['sign-jars'],
                       javaRules.&packageHighLevelArchiveTarget)
abuild.configureTarget('package-war', 'deps' : ['sign-jars'],
                       javaRules.&packageWarTarget)
abuild.configureTarget('package-ear', 'deps' : ['package-high-level-archive',
                           'package-war'],
                       javaRules.&packageEarTarget)
abuild.configureTarget('javadoc', 'deps' : ['compile'],
                       javaRules.&javadocTarget)
abuild.configureTarget('wrapper', 'deps' : ['package-jar'],
                       javaRules.&wrapperTarget)
