# Class: dspace
#
# This class does the following:
# - installs pre-requisites for DSpace (Java, Maven, Ant, Tomcat)
#
# Tested on:
# - Ubuntu 12.04
# - Ubuntu 14.04
#
# Parameters:
# - $java => version of Java (6 or 7)
#
# Sample Usage:
# include dspace
#
class dspace ($java_version = "7")
{
    # Default to requiring all packages be installed
    Package {
      ensure => installed,
    }

    # Java installation directory
    $install_dir = "/usr/lib/jvm"

    # OpenJDK directory name (NOTE: $architecture is a "fact")
    $dir_name = "java-${java_version}-openjdk-${architecture}"

    # Install Java, based on set $java_version (passed to Puppet in VagrantFile)
    package { "java":
      name => "openjdk-${java_version}-jdk",  # Install OpenJDK package (as Oracle JDK tends to require a more complex manual download & unzip)
    }

 ->

    # Set Java defaults to point at OpenJDK
    # NOTE: $architecture is a "fact" automatically set by Puppet's 'facter'.
    exec { "Update alternatives to OpenJDK Java ${java_version}":
      command => "update-java-alternatives --set java-1.${java_version}.0-openjdk-${architecture}",
      unless  => "test \$(readlink /etc/alternatives/java) = '${install_dir}/${dir_name}/jre/bin/java'",
      path    => "/usr/bin:/usr/sbin:/bin",
    }
 
 ->

    # Create a "default-java" symlink (for easier JAVA_HOME setting). Overwrite if existing.
    exec { "Symlink OpenJDK to '${install_dir}/default-java'":
      cwd     => $install_dir,
      command => "ln -sfn ${dir_name} default-java",
      unless  => "test \$(readlink ${install_dir}/default-java) = '${dir_name}'",
      path    => "/usr/bin:/usr/sbin:/bin",
    }

 ->

    # Install Maven & Ant which are required to build & deploy, respectively
    # For Maven, do NOT install "recommended" apt-get packages, as this will
    # install OpenJDK 6 and always set it as the default Java alternative
    package { 'maven':
      install_options => ['--no-install-recommends'],
    }

 ->

    package { "ant":
    }
    
 ->

    # Install Git, needed for any DSpace development
    package { "git":
    }
}
