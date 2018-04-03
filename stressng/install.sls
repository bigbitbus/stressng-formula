{% from "stressng/map.jinja" import stress as stress_map with context %}

{% set package = stress_map.get('package', 'stress-ng') -%}
install_stress_package:
  pkg.installed:
    - name: {{ package }}

    
    

