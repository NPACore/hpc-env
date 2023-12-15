for ip in fw@192.168.122.{2..5}; do
  echo -n "$ip "
  ssh $ip 'echo $HOSTNAME $(grep cpuid /proc/cpuinfo -c) $(df -h /|awk "END{print \$2}") $(awk "(NR==1){print \$2/(1024*1024)}" /proc/meminfo) ' || echo
done | column -t
