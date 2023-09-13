# CPU Mode

### Will update Later
    <cpu mode="host-passthrough" check="none" migratable="on">
      <topology sockets="1" cores="8" threads="2"/>
      <cache mode="passthrough"/>
      <feature policy="require" name="topoext"/>
      <feature policy="require" name="svm"/>
      <feature policy="require" name="apic"/>
      <feature policy="require" name="hypervisor"/>
      <feature policy="require" name="invtsc"/>
    </cpu>
