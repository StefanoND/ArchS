# Clock

### Will update later

## Linux
    <clock offset='utc'>
     <timer name="rtc" present="no" tickpolicy="catchup"/>
     <timer name="pit" present="no" tickpolicy="delay"/>
     <timer name="hpet" present="no"/>
     <timer name="kvmclock" present="no"/>
     <timer name="tsc" present="yes" mode="native"/>
    </clock>


## Windows (Change offset from "UTC" to "Localtime" Add "hypervclock")
    <clock offset="localtime">
     <timer name="rtc" present="no" tickpolicy="catchup"/>
     <timer name="pit" present="no" tickpolicy="delay"/>
     <timer name="hpet" present="no"/>
     <timer name="kvmclock" present="no"/>
     <timer name="hypervclock" present="yes"/>
     <timer name="tsc" present="yes" mode="native"/>
    </clock>
