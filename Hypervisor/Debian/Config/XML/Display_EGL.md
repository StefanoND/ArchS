# Display EGL

## Do not follow this if using SDL

### To use EGL acceleration, you must change your Display Spice as well as adding egl-headless like shown bellow

    <graphics type="spice">
      <listen type="none"/>
      <image compression="off"/>
      <gl enable="no"/>
    </graphics>
    <graphics type="egl-headless">
      <gl rendernode="/dev/dri/renderD128"/>
    </graphics>
