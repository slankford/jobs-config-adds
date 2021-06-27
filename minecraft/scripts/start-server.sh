#!/bin/sh
. './env.sh'

## Helptext
helptext() {
    echo 'Starts up the SettleScape Minecraft server.'
    echo '  -d  Run as a daemon'
    echo '  -i  Run interactively'
    echo '  -h  Print this helptext'
}

## Check input
case "$1" in
    '-d') DAEMON=1           ;;
    '-i') INTERACTIVE=1      ;;
    '-h') helptext && exit 0 ;;
       *) helptext && exit 1 ;;
esac

## Figure out which Java to use.  (Proprietary Java preferred.)
I=4
until [ -f "$JAVA" ]; do
    case $I in
    ## Java 8 is an LTS release.
    1) JAVA='/lib/jvm/java-8-jdk/jre/bin/java'     ;;
    2) JAVA='/lib/jvm/java-8-openjdk/jre/bin/java' ;;
    3) JAVA='/lib/jvm/jre-8-openjdk/bin/java'      ;;
    ## Java 11 is an LTS release.
    4) JAVA='/lib/jvm/java-11-jdk/bin/java'     ;;
    5) JAVA='/lib/jvm/java-11-openjdk/bin/java' ;;
    6) JAVA='/lib/jvm/jre-11-openjdk/bin/java'  ;;
    ## Java 17 is an LTS release.
    7) JAVA='/lib/jvm/java-17-jdk/bin/java'     ;;
    8) JAVA='/lib/jvm/java-17-openjdk/bin/java' ;;
    9) JAVA='/lib/jvm/jre-17-openjdk/bin/java'  ;;
    ## If none of the above worked, try using the system's default java.
    *) JAVA=`which java` ;;
    esac
    I=`expr $I + 1`
done

## Official 1.14.4 client options.
# VANILLA_OPTS=$(echo                    \
#     '-Xmx2G'                           \
#     '-XX:+UnlockExperimentalVMOptions' \
#     '-XX:+UseG1GC'                     \
#     '-XX:G1NewSizePercent=20'          \
#     '-XX:G1ReservePercent=20'          \
#     '-XX:MaxGCPauseMillis=50'          \
#     '-XX:G1HeapRegionSize=32M'         \
# | xargs)

## Aikar's tuned server options.
## https://aikar.co/2018/07/02/tuning-the-jvm-g1gc-garbage-collector-flags-for-minecraft
# AIKAR_OPTS=$(echo                          \
#     '-Xms6G'                               \
#     '-Xmx6G'                               \
#     '-XX:+UnlockExperimentalVMOptions'     \
#     '-XX:+AlwaysPreTouch'                  \
#     '-XX:+ParallelRefProcEnabled'          \
#     '-XX:+DisableExplicitGC'               \
#     '-XX:+UseG1GC'                         \
#     '-XX:G1MixedGCLiveThresholdPercent=35' \
#     '-XX:G1NewSizePercent=50'              \
#     '-XX:G1MaxNewSizePercent=80'           \
#     '-XX:TargetSurvivorRatio=90'           \
#     '-XX:MaxGCPauseMillis=100'             \
#     '-Dusing.aikars.flags=mcflags.emc.gs'  \
# | xargs)

## Mixes the above options.
## The percentages in these flags have been changed from their original values to better-align with duodecimal percentages.
JAVA_OPTS=$(echo                           \
    '-Xmx2G'                               \
    '-XX:+UnlockExperimentalVMOptions'     \
    '-XX:+AlwaysPreTouch'                  \
    '-XX:+ParallelRefProcEnabled'          \
    '-XX:+DisableExplicitGC'               \
    '-XX:+UseG1GC'                         \
    '-XX:G1HeapRegionSize=32M'             \
    '-XX:G1ReservePercent=25'              \
    '-XX:G1NewSizePercent=33'              \
    '-XX:G1MaxNewSizePercent=75'           \
    '-XX:G1MixedGCLiveThresholdPercent=33' \
    '-XX:TargetSurvivorRatio=92'           \
    '-XX:MaxGCPauseMillis=50'              \
    '-Dusing.aikars.flags=mcflags.emc.gs'  \
| xargs)
# echo $JAVA_OPTS && exit

## Start the server
cd "$ENV_SERVER_ROOT"
CMD="screen -DmS '$ENV_SCREEN_NAME' '$JAVA' $JAVA_OPTS -jar './$ENV_SERVER_JAR' --nogui" #--forceUpgrade
[ ! -z $DAEMON ] && exec eval "$CMD"
eval "$CMD"
#NOTE: Type `screen -r 'SettleScape'` to attach to the SettleScape screen.
#NOTE: Press Ctrl+A, Ctrl+D to detatch from the SettleScape screen.
#NOTE: Type `screen -S 'SettleScape' -X stuff "$COMMAND\n"` to send a command to the SettleScape screen.
[ ! -z $INTERACTIVE ] && exec screen -r "$ENV_SCREEN_NAME"
exit 0
