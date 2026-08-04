# Luanti

Luanti (formerly Minetest) is a free and open-source voxel game engine with its own distribution platform and client. Players, creators, server hosts, and engine developers can find more information here about how to get started with Luanti.

wikipedia.org/wiki/Luanti

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Minetest_logo.svg/250px-Minetest_logo.svg.png" width="30%" height="auto" alt="Luanti logo">

## How to use this Makejail

### Standalone

Before starting the container:

* (optional) download a configuration file:

  ```console
  $ fetch -o minetest.conf https://github.com/luanti-org/luanti/blob/master/minetest.conf.example?raw=true
  ```

* create the necessary directories:

  ```console
  $ mkdir -p games mods data/.minetest/games data/.minetest/mods
  ```

* install the game you want to play in `./games/`. Follow [this guide](https://content.luanti.org/help/installing/#installing-using-the-command-line). For example, to install `voxelibre` using `git`

  ```console
  $ git clone https://git.minetest.land/VoxeLibre/VoxeLibre ./games/voxelibre/
  ```

* start the container

  ```console
  $ appjail oci run -Pd \
      -e PUID=15000 \ # arbitrary
      -e PGID=15000 \ # arbitrary
      -o overwrite=force \
      -o virtualnet=":<random> default" \
      -o nat \
      -o fstab="$PWD/minetest.conf usr/local/etc/minetest.conf nullfs ro" \
      -o fstab="$PWD/data /var/db/minetest" \
      -o fstab="$PWD/games /var/db/minetest/.minetest/games nullfs ro" \
      -o fstab="$PWD/mods /var/db/minetest/.minetest/mods nullfs ro" \
      -o expose="30000 proto:udp" \
      ghcr.io/appjail-makejails/luanti luanti \
      --config /usr/local/etc/minetest.conf --gameid voxelibre --worldname world
  ```

`./data/.minetest/` has the directory `worlds/`, where the world will be saved.

### Deploy using `appjail-director`

**appjail-director.yml**:

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:
  - container: 'args:--pull' 

services:
  luanti:
    name: luanti
    makejail: gh+AppJail-makejails/minetest
    volumes:
      - config: usr/local/etc/minetest.conf
      - data: /var/db/minetest
      - games: /var/db/minetest/.minetest/games
      - mods: /var/db/minetest/.minetest/mods
    oci:
      environment:
        - PUID: 15000
        - PGID: 15000
      arguments: ["--config", "/usr/local/etc/minetest.conf", "--gameid", "voxelibre", "--worldname", "world"]
    options:
      - expose: '30000 proto:udp'

default_volume_type: nullfs

volumes:
  config:
    device: !ENV '${PWD}/minetest.conf'
  data:
    device: !ENV '${PWD}/data'
  games:
    device: !ENV '${PWD}/games'
    options: ro
  mods:
    device: !ENV '${PWD}/mods'
    options: ro
```

### Arguments (stage: build)

* `luanti_from` (default: `ghcr.io/appjail-makejails/luanti`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `luanti_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).

### Environment (OCI image)

* `PGID` (default: `1000`): Equivalent to `PUID` but for the Process Group ID.
* `PUID` (default: `1000`): Process User ID for the container's main process, allowing you to match the owner of files written to mounted host volumes to your host system's user. Writable volumes are changed based on this environment variable.

### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-1e8ed96e87-var_db_minetest | `${PUID}` | `${PGID}` | - | - | /var/db/minetest |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1
      containerfile: Containerfile
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```
