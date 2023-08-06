# Display SDL

### To use SDL acceleration, you must change your Display Spice to be the same as below (Change USERNAME to yours)
    <graphics type="sdl" display=":0" xauth="/home/USERNAME/.Xauthority">
      <gl enable="yes"/>
    </graphics>

### At the end, before </domain> add these command lines (Change USERNAME to yours)
    <qemu:commandline>
      <qemu:env name="DISPLAY" value=":0"/>
      <qemu:env name="XAUTHORITY" value="/home/USERNAME/.Xauthority"/>
    </qemu:commandline>

### At the beginning change <domain type="kvm"> to
    <domain xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0" type="kvm">

### You must also remove everything that uses SpiceVMC whic are the USB redirectors ( #1, #2, etc ), Spice Channel ( com.redhat.spice.0 spice agent ) and Audio ( <audio id="1" type="none"/> )
