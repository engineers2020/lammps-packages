folder('rpms/daily')

def scripts = ['centos_6', 'centos_7']

scripts.each { name ->
    pipelineJob("rpms/daily/${name}") {
        triggers {
            cron('@midnight')
        }

        logRotator(30)

        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            github('lammps/lammps-packages')
                            credentials('lammps-jenkins')
                        }

                        branches('rpm-build')

                        configure { gitScm ->
                            gitScm / 'extensions' << 'hudson.plugins.git.extensions.impl.PathRestriction' {
                              includedRegions("jenkins/${name}.groovy")
                              excludedRegions('.*')
                          }
                        }
                    }
                }
                scriptPath("jenkins/${name}.groovy")
            }
        }
    }
}
