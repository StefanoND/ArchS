# CPU Pinning

### I'll update soon
### Leave at least threads 0 and 8 for the host (Linux likes thread 0, and 8 is 0's sibling, in my case, check)
    <cputune>
      <vcpupin vcpu="0" cpuset="0"/>
      <vcpupin vcpu="1" cpuset="8"/>
      <vcpupin vcpu="2" cpuset="1"/>
      <vcpupin vcpu="3" cpuset="9"/>
      <vcpupin vcpu="4" cpuset="2"/>
      <vcpupin vcpu="5" cpuset="10"/>
      <vcpupin vcpu="6" cpuset="3"/>
      <vcpupin vcpu="7" cpuset="11"/>
      <vcpupin vcpu="8" cpuset="4"/>
      <vcpupin vcpu="9" cpuset="12"/>
      <vcpupin vcpu="10" cpuset="5"/>
      <vcpupin vcpu="11" cpuset="13"/>
      <vcpupin vcpu="12" cpuset="6"/>
      <vcpupin vcpu="13" cpuset="14"/>
      <vcpupin vcpu="14" cpuset="7"/>
      <vcpupin vcpu="15" cpuset="15"/>
      <emulatorpin cpuset="0,8"/>
    </cputune>

## CPU Siblings/Cousins
### CPU Siblings are threads in of the same core, and CPU cousins are threads from different cores
### In the illustration below, thread 0 and thread 8 are siblings be cause they share the same core (Core 1)
### Thread 3 and 11 are siblings be cause they share the same core (Core 4) and so on
### Thread 0 and thread 1 are cousins be cause they're in different cores (Core 1 and 2 respectively)
### Thread 9 and thread 12 are cousins be cause they're in different cores (Core 2 and 5 respectively)
        ____________________________________________________________________________
        |                                    CPU                                    |
        |  ___________________________________ ___________________________________  |
        | |               CCX 1               |             CCX 2                 | |
        | |  ______________   ______________  | ______________   ______________   | |
        | | |    CORE 1    | |    CORE 2    | | |    CORE 5    | |    CORE 6    | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD 0 | | | | THREAD 1 | | | | | THREAD 4 | | | | THREAD 5 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD 8 | | | | THREAD 9 | | | | | THREAD12 | | | | THREAD13 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | |--------------| |--------------| | |--------------| |--------------| | |
        | |  ______________   ______________  |  ______________   ______________  | |
        | | |    CORE 3    | |    CORE 4    | | |    CORE 7    | |    CORE 8    | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD 2 | | | | THREAD 3 | | | | | THREAD 6 | | | | THREAD 7 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | | | THREAD10 | | | | THREAD11 | | | | | THREAD14 | | | | THREAD15 | | | |
        | | | |----------| | | |----------| | | | |----------| | | |----------| | | |
        | | |--------------| |--------------| | |--------------| |--------------| | |
        | |-----------------------------------|-----------------------------------| |
        |---------------------------------------------------------------------------|
