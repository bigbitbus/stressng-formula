{% from "stressng/map.jinja" import stress as stress_map with context %}

{% set package = stress_map.get('package', 'stress-ng') -%}
{% if stress_map.get(install_from_source,'False')==False %}
install_stress_package:
  pkg.installed:
    - name: {{ package }}
{% else %}
install_prereqs:
  pkg.latest:
    - pkgs: {{ stress_map.get('prereq_packages'.[]) }}

download_source:
  cmd.run:
    - names: 
      - wget {{ stress_map.get('stressng_source_url','url-needed') }}
      - tar xf tar -xf stress-ng-*
    -cwd: /tmp
compile_source:
  requires:
    - install_prereqs
    - download_source
  cmd.script:
    - name: compileinstall.sh
    - source: salt://stressng/files/compileinstall.sh
    - stateful: True
{% endif %}
    
    

