# Features

### Will update

### Currently using
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

## Possible options will have to study more (informations/tests about these are welcome)
    <features>
      <pae/>
      <acpi/>
      <apic/>
      <hap/>
      <privnet/>
      <hyperv mode='custom'>
        <relaxed state='on'/>
        <vapic state='on'/>
        <spinlocks state='on' retries='4096'/>
        <vpindex state='on'/>
        <runtime state='on'/>
        <synic state='on'/>
        <stimer state='on'>
          <direct state='on'/>
        </stimer>
        <reset state='on'/>
        <vendor_id state='on' value='KVM Hv'/>
        <frequencies state='on'/>
        <reenlightenment state='on'/>
        <tlbflush state='on'/>
        <ipi state='on'/>
        <evmcs state='on'/>
      </hyperv>
      <kvm>
        <hidden state='on'/>
        <hint-dedicated state='on'/>
        <poll-control state='on'/>
        <pv-ipi state='off'/>
        <dirty-ring state='on' size='4096'/>
      </kvm>
      <xen>
        <e820_host state='on'/>
        <passthrough state='on' mode='share_pt'/>
      </xen>
      <pvspinlock state='on'/>
      <gic version='2'/>
      <ioapic driver='qemu'/>
      <hpt resizing='required'>
        <maxpagesize unit='MiB'>16</maxpagesize>
      </hpt>
      <vmcoreinfo state='on'/>
      <smm state='on'>
        <tseg unit='MiB'>48</tseg>
      </smm>
      <htm state='on'/>
      <ccf-assist state='on'/>
      <msrs unknown='ignore'/>
      <cfpc value='workaround'/>
      <sbbc value='workaround'/>
      <ibs value='fixed-na'/>
      <tcg>
        <tb-cache unit='MiB'>128</tb-cache>
      </tcg>
    </features>
