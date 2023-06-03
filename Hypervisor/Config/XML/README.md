# XML configs

## SCSI Controller
    <driver queues="4" iothread="1"/>

## SCSI Disk (in "type" change "qcow2" to "raw" according to your disk image)
    <driver name="qemu" type="raw" cache="none" io="threads" discard="unmap"/>

## Patched GPU ".rom" (If using NVidia GPU)
    <rom file="/usr/share/vgabios/patched.rom"/>

### All XML configs condensed here (Separated by "...")

    <domain type="kvm" xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0"><qemu:commandline>
      ...
      <iothreads>1</iothreads>
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
        <iothreadpin iothread="1" cpuset="1-2,9-10"/>
      </cputune>
      ...
      <features>
        <acpi/>
        <apic/>
        <hyperv mode="custom">
          <relaxed state="on"/>
          <vapic state="on"/>
          <spinlocks state="on" retries="8191"/>
          <vpindex state="on"/>
          <synic state="on"/>
          <stimer state="on"/>
          <reset state="on"/>
          <vendor_id state="on" value="randomid"/>
          <frequencies state="on"/>
        </hyperv>
        <kvm>
          <hidden state="on"/>
          <hint-dedicated state="on"/>
        </kvm>
        <vmport state="off"/>
        <ioapic driver="kvm"/>
        <msrs unknown="ignore"/>
      </features>
      <cpu mode="host-passthrough" check="none" migratable="on">
        <topology sockets="1" cores="8" threads="2"/>
        <cache mode="passthrough"/>
        <feature policy="require" name="topoext"/>
        <feature policy="require" name="svm"/>
        <feature policy="require" name="apic"/>
        <feature policy="require" name="hypervisor"/>
        <feature policy="require" name="invtsc"/>
      </cpu>
      <clock offset="localtime">
        <timer name="rtc" present="no" tickpolicy="catchup"/>
        <timer name="pit" present="no" tickpolicy="delay"/>
        <timer name="hpet" present="no"/>
        <timer name="kvmclock" present="no"/>
        <timer name="hypervclock" present="yes"/>
        <timer name="tsc" present="yes" mode="native"/>
      </clock>
      ...
      <qemu:env name="QEMU_AUDIO_DRV" value="pa"/>
        <qemu:env name="QEMU_PA_SERVER" value="/run/user/1000/pulse/native"/>
        <qemu:env name="QEMU_PA_SAMPLES" value="8192"/>
        <qemu:env name="QEMU_AUDIO_TIMER_PERIOD" value="99"/>
        <qemu:arg value='-overcommit'/>
        <qemu:arg value='cpu-pm=on'/>
      </qemu:commandline>
    </domain>
