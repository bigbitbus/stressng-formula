{% from "stressng/map.jinja" import stress as stress_map with context %}
{% set package = stress_map.get('package', 'stress-ng') %}
{% set install_from_source = stress_map.get('install_from_source', False) %}

{% if install_from_source==False %}
install_stress_package:
  pkg.installed:
    - name: {{ package }}
{% else %}
{% set prereqs = stress_map.get('prereq_packages',[]) %}
{% set stressurl = stress_map.get('stressng_source_url','url_needed')  %}

install_prereqs:
  pkg.latest:
    - pkgs: {{ prereqs }}

download_source:
  cmd.run:
    - names: 
      - rm -rf stress*
      - wget {{ stressurl }}
    - cwd: /tmp

compile_source:
  cmd.script:
    - name: compileinstall.sh
    - source: salt://stressng/files/compileinstall.sh
    - requires:
      - install_prereqs
      - download_source

{% endif %}
    
    

