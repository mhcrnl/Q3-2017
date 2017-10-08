parameters {
    abuild.rules = 'java'
    def dist = new File(abuild.resolve('java.dir.dist'))
    def unsigned = new File(dist, 'ear-code.jar.unsigned')
    def signed = new File(dist, 'ear-code.jar')
    java.jarName = unsigned.name
    java.earName = 'ear-example.ear'
    java.appxml = 'application.xml'
    java.packageJar << [:]
    java.packageJar << {
        ant.copy('file': unsigned.absolutePath,
                 'tofile': signed.absolutePath)
    }
    java.signJars << ['signdir': signed.parent, 'includes': 'ear-code.jar']
}
