# Palworld Server

Docker Compose stack for a Palworld dedicated server (`thijsvanloef/palworld-server-docker`), reachable privately over NetBird on the `services` network.

**Runs on:** the OCI host (must share the `services` network with netbird-server)

## Prerequisites

- [NetBird Client](../../networking/netbird-client/README.md) running on the host (it routes the `services` network).
- A NetBird policy allowing UDP `8211` and `27015` to the `services` resource.

## Setup

```bash
cp .env.example .env
# set PALWORLD_IP and the server settings, then:
docker compose up -d
```

The [gaming Ansible playbooks](../../ansible/gaming/README.md) can deploy this stack too.

## Configuration

Network:

- `PALWORLD_IP` - Static IP on the `services` network (e.g. `10.110.2.41`). Required.

Server (see the [image documentation](https://github.com/thijsvanloef/palworld-server-docker) for every option):

- `TZ` - Timezone.
- `PUID`, `PGID` - User and group the server runs as.
- `PLAYERS` - Max players.
- `PORT` - Game port (`8211`).
- `QUERY_PORT` - Query port (`27015`).
- `SERVER_NAME`, `SERVER_DESCRIPTION` - Shown in the server browser.
- `SERVER_PASSWORD` - Password to join.
- `ADMIN_PASSWORD` - Admin password.
- `COMMUNITY` - List on the community server browser (`false`).
- `PUBLIC_IP`, `PUBLIC_PORT` - Advertised address for community listing (blank here).
- `MULTITHREADING` - Enable multithreading.
- `RCON_ENABLED`, `RCON_PORT` - Remote console (off).
- `UPDATE_ON_BOOT` - Update the server on container start.
- `BACKUP_ENABLED`, `BACKUP_CRON_EXPRESSION` - Scheduled backups (daily at midnight).
- `DELETE_OLD_BACKUPS`, `OLD_BACKUP_DAYS` - Backup retention.
- `AUTO_UPDATE_ENABLED`, `AUTO_UPDATE_CRON_EXPRESSION`, `AUTO_UPDATE_WARN_MINUTES` - Scheduled updates (off).
- `AUTO_REBOOT_ENABLED`, `AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE` - Scheduled reboots (off).
- `AUTO_REBOOT_WARN_MINUTES`, `AUTO_REBOOT_CRON_EXPRESSION`, `AUTO_PAUSE_ENABLED`, `AUTO_PAUSE_TIMEOUT_EST`, `AUTO_PAUSE_LOG`, `AUTO_PAUSE_DEBUG`, `ENABLE_PLAYER_LOGGING`, `PLAYER_LOGGING_POLL_PERIOD`, `LOG_FILTER_ENABLED`, `LOG_FORMAT_TYPE` - Reboot warnings and schedule, auto-pause when empty, and player/log output settings.

Gameplay settings mirror `PalWorldSettings.ini` and are left at the game's defaults (rates at `1.000000`). Change them to tune the world: `DIFFICULTY`, `RANDOMIZER_TYPE`, `RANDOMIZER_SEED`, `DAYTIME_SPEEDRATE`, `NIGHTTIME_SPEEDRATE`, `EXP_RATE`, `PAL_CAPTURE_RATE`, `PAL_SPAWN_NUM_RATE`, `PAL_DAMAGE_RATE_ATTACK`, `PAL_DAMAGE_RATE_DEFENSE`, `PLAYER_DAMAGE_RATE_ATTACK`, `PLAYER_DAMAGE_RATE_DEFENSE`, `PLAYER_STOMACH_DECREASE_RATE`, `PLAYER_STAMINA_DECREASE_RATE`, `PLAYER_AUTO_HP_REGEN_RATE`, `PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP`, `PAL_STOMACH_DECREASE_RATE`, `PAL_STAMINA_DECREASE_RATE`, `PAL_AUTO_HP_REGEN_RATE`, `PAL_AUTO_HP_REGEN_RATE_IN_SLEEP`, `BUILD_OBJECT_HP_RATE`, `BUILD_OBJECT_DAMAGE_RATE`, `BUILD_OBJECT_DETERIORATION_DAMAGE_RATE`, `COLLECTION_DROP_RATE`, `COLLECTION_OBJECT_HP_RATE`, `COLLECTION_OBJECT_RESPAWN_SPEED_RATE`, `ENEMY_DROP_ITEM_RATE`, `DEATH_PENALTY`, `ENABLE_PLAYER_TO_PLAYER_DAMAGE`, `ENABLE_FRIENDLY_FIRE`, `ENABLE_INVADER_ENEMY`, `ACTIVE_UNKO`, `ENABLE_AIM_ASSIST_PAD`, `ENABLE_AIM_ASSIST_KEYBOARD`, `DROP_ITEM_MAX_NUM`, `DROP_ITEM_MAX_NUM_UNKO`, `BASE_CAMP_MAX_NUM`, `BASE_CAMP_WORKER_MAX_NUM`, `DROP_ITEM_ALIVE_MAX_HOURS`, `AUTO_RESET_GUILD_NO_ONLINE_PLAYERS`, `AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS`, `GUILD_PLAYER_MAX_NUM`, `BASE_CAMP_MAX_NUM_IN_GUILD`, `PAL_EGG_DEFAULT_HATCHING_TIME`, `WORK_SPEED_RATE`, `AUTO_SAVE_SPAN`, `IS_MULTIPLAY`, `IS_PVP`, `HARDCORE`, `CHARACTER_RECREATE_IN_HARDCORE`, `PAL_LOST`, `CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP`, `ENABLE_NON_LOGIN_PENALTY`, `ENABLE_FAST_TRAVEL`, `IS_START_LOCATION_SELECT_BY_MAP`, `EXIST_PLAYER_AFTER_LOGOUT`, `ENABLE_DEFENSE_OTHER_GUILD_PLAYER`, `INVISIBLE_OTHER_GUILD_BASE_CAMP_AREA_FX`, `BUILD_AREA_LIMIT`, `ITEM_WEIGHT_RATE`, `COOP_PLAYER_MAX_NUM`, `REGION`, `USEAUTH`, `BAN_LIST_URL`, `REST_API_ENABLED`, `REST_API_PORT`, `SHOW_PLAYER_LIST`, `CHAT_POST_LIMIT_PER_MINUTE`, `ENABLE_PREDATOR_BOSS_PAL`, `MAX_BUILDING_LIMIT_NUM`, `SERVER_REPLICATE_PAWN_CULL_DISTANCE`, `SERVER_REPLICATE_PAWN_CULL_DISTANCE_IN_BASE_CAMP`, `CROSSPLAY_PLATFORMS`, `USE_BACKUP_SAVE_DATA`, `USE_DEPOT_DOWNLOADER`, `INSTALL_BETA_INSIDER`, `ALLOW_GLOBAL_PALBOX_EXPORT`, `ALLOW_GLOBAL_PALBOX_IMPORT`, `EQUIPMENT_DURABILITY_DAMAGE_RATE`, `ITEM_CONTAINER_FORCE_MARK_DIRTY_INTERVAL`, `ITEM_CORRUPTION_MULTIPLIER`, `PHYSICS_ACTIVE_DROP_ITEM_MAX_NUM`, `ALLOW_CLIENT_MOD`, `PLAYER_DATA_PAL_STORAGE_UPDATE_CHECK_TICK_INTERVAL`, `IS_SHOW_JOIN_LEFT_MESSAGE`, `MONSTER_FARM_ACTION_SPEED_RATE`, `DENY_TECHNOLOGY_LIST`, `GUILD_REJOIN_COOLDOWN_MINUTES`, `AUTO_TRANSFER_MASTER_CHECK_INTERVAL_SECONDS`, `AUTO_TRANSFER_MASTER_THRESHOLD_DAYS`, `MAX_GUILDS_PER_FRAME`, `BLOCK_RESPAWN_TIME`, `RESPAWN_PENALTY_DURATION_THRESHOLD`, `RESPAWN_PENALTY_TIME_SCALE`, `DISPLAY_PVP_ITEM_NUM_ON_WORLD_MAP_BASE_CAMP`, `DISPLAY_PVP_ITEM_NUM_ON_WORLD_MAP_PLAYER`, `ADDITIONAL_DROP_ITEM_WHEN_PLAYER_KILLING_IN_PVP_MODE`, `ADDITIONAL_DROP_ITEM_NUM_WHEN_PLAYER_KILLING_IN_PVP_MODE`, `ADDITIONAL_DROP_ITEM_WHEN_PLAYER_KILLING_IN_PVP_MODE_ENABLED`, `ENABLE_VOICE_CHAT`, `VOICE_CHAT_MAX_VOLUME_DISTANCE`, `VOICE_CHAT_ZERO_VOLUME_DISTANCE`, `ALLOW_ENHANCE_STAT_HEALTH`, `ALLOW_ENHANCE_STAT_ATTACK`, `ALLOW_ENHANCE_STAT_STAMINA`, `ALLOW_ENHANCE_STAT_WEIGHT`, `ALLOW_ENHANCE_STAT_WORK_SPEED`, `ENABLE_BUILDING_PLAYER_UID_DISPLAY`, `BUILDING_NAME_DISPLAY_CACHE_TTL_SECONDS`.

ARM64 only (Box64 emulation tuning; adjust if the server keeps crashing): `BOX64_DYNAREC_STRONGMEM`, `BOX64_DYNAREC_BIGBLOCK`, `BOX64_DYNAREC_SAFEFLAGS`, `BOX64_DYNAREC_FASTROUND`, `BOX64_DYNAREC_FASTNAN`, `BOX64_DYNAREC_X87DOUBLE`.

## Routing & Ports

- No published ports. The container joins the external `services` network at `PALWORLD_IP`; players connect through NetBird to that address.
- `8211/udp` - Game port.
- `27015/udp` - Query port.
- See the [Gaming README](../README.md#remote-access) for shared remote access guidance.

## Data & Backups

- `./data` → `/palworld/` - Server files, saves, and the image's built-in backups. Back this up.

## Troubleshooting

- `docker compose up` fails with "set PALWORLD_IP in .env": copy `.env.example` and set the IP.
- Players can't connect: check the NetBird policy allows UDP 8211 and that netbird-client routes `services`.
