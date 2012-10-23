# glusterfs::client::config.pp

define glusterfs::client::config(
    $servers  = [],
    $mountpath,
    $username = 'gluster',
    $password,
    $owner    = "root",
    $group    = "root"
) {
	include glusterfs::client

    if empty($servers) {
        $real_servers = split(getvar("gluster_servers_${name}"), ' ')
    } else {
        $real_servers = $servers
    }

    file { $mountpath:
        ensure  => directory,
        owner   => $owner,
        group   => $group,
    }
	
	$conffile = "/etc/glusterfs/glusterfs.${name}.vol"
	
	file { "${conffile}":
		owner => root,
		group => root,
		mode => 644,
		content => template("glusterfs/client.config.erb"),
		notify => Mount["${mountpath}"],
		require => Package["glusterfs-client"],
	}
	
	mount { $mountpath:
		atboot => true,
		device => $conffile,
		ensure => mounted,
		fstype => "glusterfs",
		options => "noatime,_netdev",
		require => [ File["${conffile}"], File["${mountpath}"] ],
		remounts => false,
	}

    file { "/etc/glusterfs/${name}":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 0755,
    }

    File <<| tag == "${name}-gluster-client" |>>

}
