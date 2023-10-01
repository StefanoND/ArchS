# Commandlines

### Will update soon
#### Beginning of XML config (1st line)
    <domain type="kvm" xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0">

### End of XML config (Before "\</domain>" section)
    <qemu:commandline>
      <qemu:env name="QEMU_AUDIO_DRV" value="pa"/>
      <qemu:env name="QEMU_PA_SERVER" value="/run/user/1000/pulse/native"/>
      <qemu:env name="QEMU_PA_SAMPLES" value="8192"/>
      <qemu:env name="QEMU_AUDIO_TIMER_PERIOD" value="99"/>
      <qemu:arg value='-overcommit'/>
      <qemu:arg value='cpu-pm=on'/>
    </qemu:commandline>
