# CPU Pinning

### I'll give details at a later date
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
      <emulatorpin cpuset="1-7,9-15"/>
    </cputune>
