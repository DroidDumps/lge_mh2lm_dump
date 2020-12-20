#!/system/bin/sh

rm /data/logger/time_in_state
cat /sys/devices/system/cpu/cpu7/cpufreq/stats/time_in_state /sys/devices/system/cpu/cpu6/cpufreq/stats/time_in_state \
    /sys/devices/system/cpu/cpu5/cpufreq/stats/time_in_state /sys/devices/system/cpu/cpu4/cpufreq/stats/time_in_state \
    /sys/devices/system/cpu/cpu3/cpufreq/stats/time_in_state /sys/devices/system/cpu/cpu2/cpufreq/stats/time_in_state \
    /sys/devices/system/cpu/cpu1/cpufreq/stats/time_in_state /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state \
> /data/logger/time_in_state
chmod -h 644 /data/logger/time_in_state
